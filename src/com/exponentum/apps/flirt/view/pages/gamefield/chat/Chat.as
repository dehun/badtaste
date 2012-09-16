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

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.ui.Keyboard;

import mx.containers.ControlBar;

import org.casalib.display.CasaSprite;
import org.casalib.layout.Distribution;

public class Chat extends CasaSprite
{
	private var messageContainer:CasaSprite = new CasaSprite();
	private var sayButton:SayButton = new SayButton();
	private var chatInput:ChatInput = new ChatInput();

	private var chatMessages:Array = [];

	private var messagesDistribution:Distribution = new Distribution(480);
	private var _bottomPanelMask:BottomPanelMask = new BottomPanelMask();

	public function Chat()
	{
		messagesDistribution.x = 75;
		messagesDistribution.y = -5;

		addChild(messagesDistribution);
		_bottomPanelMask.x = messagesDistribution.x;
		_bottomPanelMask.y = messagesDistribution.y;
		_bottomPanelMask.height = _bottomPanelMask.height - 50;
		addChild(_bottomPanelMask);
		messagesDistribution.mask = _bottomPanelMask;
		createScroll();

		Model.instance.addEventListener(Controller.GOT_CHAT_MESSAGE_FROM_ROOM, onNewMessageFromRoom);

		chatInput.tf.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
		chatInput.tf.addEventListener(FocusEvent.FOCUS_IN, onFocusOut);
	}

	private function onFocusIn(e:FocusEvent):void
	{
		chatInput.tf.text = "";
		addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	private function onFocusOut(e:FocusEvent):void
	{
		removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	private function onKeyDown(e:KeyboardEvent):void
	{
		if(chatInput.tf.text == "") return;
		if(e.keyCode == Keyboard.ENTER){
			Controller.instance.sendMessageToRoom(chatInput.tf.text);
			chatInput.tf.text = "";
		}
	}

	private function onNewMessageFromRoom(e:ObjectEvent):void
	{
		var message:ChatMessageItem = new ChatMessageItem(e.data);
		messagesDistribution.addChildWithDimensions(message);
		chatMessages.push(message);
		messagesDistribution.position();
		scr.setTargetAndSource(messagesDistribution, _bottomPanelMask);
	}

	private var scr:Scroll = new Scroll(85);
	private function createScroll():void
	{
		scr.x = 470;
		scr.y = 0;
		scr.setTargetAndSource(messagesDistribution, _bottomPanelMask);
		scr.step = 10;
		scr.addEventListener(Event.CHANGE, onScroll);
		addChild(scr);

		sayButton.x = 575;
		sayButton.y = 112;
		addChild(sayButton);
		sayButton.addEventListener(MouseEvent.CLICK, onSendMessage);

		chatInput.y = 116;
		chatInput.x = 155;
		addChild(chatInput);
	}

	private function onScroll(e:Event):void
	{
		var difference:Number = messagesDistribution.height - _bottomPanelMask.height;
		messagesDistribution.y = _bottomPanelMask.y + (e.currentTarget as Scroll).position * (-difference);
	}

	private function onSendMessage(e:MouseEvent):void
	{
		Controller.instance.sendMessageToRoom(chatInput.tf.text);
		chatInput.tf.text = "";
	}

	override public function destroy():void
	{
		Model.instance.removeEventListener(Controller.GOT_CHAT_MESSAGE_FROM_ROOM, onNewMessageFromRoom);
		removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		super.destroy();
	}
	
}
}
