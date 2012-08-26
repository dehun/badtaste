package
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.view.View;
import com.junkbyte.console.Cc;
import com.junkbyte.console.ConsoleConfig;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;

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
		model = new Model();
		controller = new Controller(model);
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

		controller.touchUserInfo('{"userInfo" : { "UserInfo" : ' +
				'{"userId" : "' + model.owner.id + '",' +
				'"name" : "' + model.owner.name + '",' +
				'"profileUrl" : "' + model.owner.profileLink + '",' +
				'"isMan" : "' + model.owner.sex + '",' +
				'"birthDate" : "' + model.owner.birthDate + '",' +
				'"city" : "' + model.owner.city + '",' +
				'"avatarUrl" : "' + model.owner.photoLink + '"}}}');

		view.showProfile();
		//view.showGameField();
		//view.showTasks();
		//view.showRatings();
		//view.showShop();
		view.showMiniProfile();

		createTestConsole();
	}

	private function onGetFriends(res:Object):void
	{
		trace(res);
	}

	private function createTestConsole():void
	{

		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

		Cc.log("Press '0' Authenticate();");
		Cc.log("Press '1' JoinMainRoomQueue();");
		Cc.log("Press '2' SendChatMessageToRoom();");
		Cc.log("Press '3' GetUserInfo();");
		Cc.log("Press '4' TouchUserInfoByUser();");
		Cc.log("Press '5' ToSwingBottle();");
		Cc.log("Press '6' ToKiss();");
		Cc.log("Press '7' ToRefuseToKiss();");
	}

	private function onKeyDown(e:KeyboardEvent):void
	{
		switch(e.keyCode)
		{
			case 48:
					controller.authenticate(model.owner.id, "");
				break;
			case 49:
					controller.joinToMainRoomQueue();
				break;
			case 50:
					controller.sendMessageToRoom("Hello World!");
				break;
			case 51:
					controller.getUserInfo(model.owner.guid);
				break;
			case 52:
					controller.touchUserInfoByUser({name:"newName"});
				break;
			case 53:
					controller.swingBottle();
				break;
			case 54:
					controller.kiss();
				break;
			case 55:
					controller.refuseToKiss();
				break;
		}
	}
}
}