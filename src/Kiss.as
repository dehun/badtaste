package
{
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
import flash.system.Security;

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
		Cc.log("--------------- Social network response ---------------");
		Cc.log(res);
		Cc.log("--------------- Social network response ---------------");

		model.owner.updateSocialInfo(res[0] as SocialProfileVO);
		model.addEventListener(Model.USER_AUTHENTICATED, onUserAuthenticated);
		controller.userLogin();
	}

	private function onUserAuthenticated(e:Event):void
	{
		model.removeEventListener(Model.USER_AUTHENTICATED, onUserAuthenticated);
		addChild(view);
		view.showOwnerProfile();
	}

	private function onGetFriends(res:Object):void
	{
		trace(res);
	}
}
}