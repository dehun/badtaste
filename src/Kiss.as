package
{
import com.adobe.serialization.json.JSON;
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.View;
import com.junkbyte.console.Cc;
import com.junkbyte.console.ConsoleConfig;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.Security;

import org.osmf.events.LoaderEvent;

import ru.evast.integration.IntegrationProxy;
import ru.evast.integration.core.SocialNetworkTypes;
import ru.evast.integration.core.SocialProfileVO;

[Frame(factoryClass="Preloader")]
[SWF(width="760", height="760", backgroundColor="0xFFFFFF")]

public class Kiss extends Sprite
{
	private var model:Model;
	private var controller:Controller;
	private var view:View;

	public function Kiss()
	{
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function onAddedToStage(e:Event):void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		init();
	}

	private function init():void
	{
		Security.allowDomain("*");

		model = Model.instance;
		controller = new Controller();
		view = new View(model, controller);
		addChild(view);

		var cc:ConsoleConfig = new ConsoleConfig();
		Cc.startOnStage(this.stage, "~");
		Cc.height = 750;
		Cc.width = 750;

		Cc.log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
		Cc.log("               Application started!");
		Cc.log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");

		initSocialIntegration();
	}

	private function initSocialIntegration():void
	{
		if(Config.DEV_MODE)
			IntegrationProxy.init(loaderInfo.parameters, SocialNetworkTypes.VKONTAKTE); //Для локальной работы
		else
		 IntegrationProxy.init(loaderInfo.parameters, SocialNetworkTypes.AUTO_DETECT);	// Для релиза

		IntegrationProxy.adapter.GetProfiles(IntegrationProxy.adapter.Me(), onGetProfiles);
	}

	private function onGetProfiles(res:Object):void
	{
		model.owner.updateSocialInfo(res[0] as SocialProfileVO);
		loadJobs();
	}

	private function loadJobs():void
	{
		var req:URLLoader = new URLLoader();
		req.addEventListener(Event.COMPLETE, onJobsLoaded);
		req.load(new URLRequest(Config.JOBS_CONFIG_URL));
	}

	private function onJobsLoaded(e:Event):void
	{
		Config.jobsData = JSON.decode(e.target.data);
		loadShopConfig();
	}

	private function loadShopConfig():void
	{
		var req:URLLoader = new URLLoader();
		req.addEventListener(Event.COMPLETE, onShopConfigLoaded);
		req.load(new URLRequest(Config.GIFT_SHOP_CONFIG_URL));
	}

	private function onShopConfigLoaded(e:Event):void
	{
		Config.giftShopData = JSON.decode(e.target.data);
		loadDecorConfig();
	}

	private function loadDecorConfig():void
	{
		var req:URLLoader = new URLLoader();
		req.addEventListener(Event.COMPLETE, onDecorConfigLoaded);
		req.load(new URLRequest(Config.DECOR_SHOP_CONFIG_URL));
	}

	private function onDecorConfigLoaded(e:Event):void
	{
		Config.decorShopData = JSON.decode(e.target.data);
		configsLoaded();
	}

	private function configsLoaded():void
	{
		model.addEventListener(Model.USER_AUTHENTICATED, onUserAuthenticated);
		controller.userLogin();
	}

	private function onUserAuthenticated(e:Event):void
	{
		model.removeEventListener(Model.USER_AUTHENTICATED, onUserAuthenticated);
		IntegrationProxy.adapter.GetAppFriends(false, onGetFriends);
	}

	private function onGetFriends(res:Object):void
	{
		model.owner.friends = res as Array;
		addChild(view);
		view.showOwnerProfile();
	}
}
}