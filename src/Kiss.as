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
		trace("Application started!");

		model = new Model();
		controller = new Controller(model);
		view = new View(model, controller);

		var cc:ConsoleConfig = new ConsoleConfig();
		Cc.startOnStage(this.stage);
		Cc.height = 750;
		Cc.width = 750;
		
		if(Config.DEV_MODE) createTestConsole();
	}

	private function createTestConsole():void
	{
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		
		Cc.log("Press '0' button to establish socket connection;");
		Cc.log("Press '1' button to authenticate;");
		Cc.log("Press '2' to send message to room;");
//		Cc.log("Press '3' button to establish socket connection;")
//		Cc.log("Press '4' button to establish socket connection;")
//		Cc.log("Press '5' button to establish socket connection;")
//		Cc.log("Press '6' button to establish socket connection;")
//		Cc.log("Press '7' button to establish socket connection;")
//		Cc.log("Press '8' button to establish socket connection;")
//		Cc.log("Press '9' button to establish socket connection;")
	}

	private function onKeyDown(e:KeyboardEvent):void
	{
		switch(e.keyCode)
		{
			case 48:
					controller.authenticate("dehun", "123");
				break;
			case 49:
					controller.joinToMainRoomQueue();
				break;
			case 50:
					controller.sendMessageToRoom("Hello World!");
				break;
			case 51:
				controller.touchUserInfo({ "UserInfo" : {
					"userId" : "dehun",
					"firstName" : "yuriy",
					"lastName" : "netesov",
					"profileUrl" : "http://vk.com/kcpc",
					"isMan" : "true",
					"smallAvatarUrl" : "netu",
					"mediumAvatarUrl" : "netu",
					"bigAvatarUrl" : "netu"
				}});
				break;
			case 52:
				break;
			case 53:
				break;
			case 54:
				break;
			case 55:
				break;
			case 56:
				break;
			case 57:
				break;

		}
	}
}
}