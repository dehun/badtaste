/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/23/12
 * Time: 9:41 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.gamefield.chat
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.view.controlls.scroll.Scroll;

import flash.events.MouseEvent;
import flash.text.TextField;

import org.casalib.display.CasaSprite;

public class Chat extends CasaSprite
{
	private var messageContainer:CasaSprite = new CasaSprite();
	private var sayButton:SayButton = new SayButton();
	private var chatInput:ChatInput = new ChatInput();

	public function Chat()
	{
		createScroll();

		Model.instance.addEventListener(Controller.GOT_CHAT_MESSAGE_FROM_ROOM, onNewMessageFromRoom);
	}

	private function onNewMessageFromRoom(e:ObjectEvent):void
	{

	}

	private function createScroll():void
	{
		var scr:Scroll = new Scroll(85);
		scr.x = 470;
		scr.y = 0;
		addChild(scr);

		sayButton.x = 575;
		sayButton.y = 112;
		addChild(sayButton);
		sayButton.addEventListener(MouseEvent.CLICK, onSendMessage);

		chatInput.y = 116;
		chatInput.x = 155;
		addChild(chatInput);
	}

	private function onSendMessage(e:MouseEvent):void
	{
		Controller.instance.sendMessageToRoom(chatInput.tf.text);
	}
}
}
