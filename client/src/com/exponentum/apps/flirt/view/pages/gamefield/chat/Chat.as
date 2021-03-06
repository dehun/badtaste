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
import com.exponentum.apps.flirt.view.common.InfoWindow;
import com.exponentum.apps.flirt.view.controlls.scroll.Scroll;

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import org.casalib.display.CasaSprite;
import org.casalib.layout.Distribution;

public class Chat extends CasaSprite
{
	private var sayButton:SayButton = new SayButton();
	private var chatInput:ChatInput = new ChatInput();

	private var chatMessages:Array = [];

	private var messagesDistribution:Distribution = new Distribution(480);
	private var _bottomPanelMask:BottomPanelMask = new BottomPanelMask();

	private var _vipOnly:Boolean = false;
	private var vipCB:VipCB = new VipCB;

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

		addChild(vipCB);
		vipCB.x = 75;
		vipCB.y = -67;
		vipCB.buttonMode = vipCB.useHandCursor = true;
		vipCB.cb.gotoAndStop(int(_vipOnly) + 1);
		vipCB.cb.addEventListener(MouseEvent.CLICK, onVipOnly);

	}

	private function onVipOnly(e:MouseEvent):void
	{
		if(Model.instance.owner.vipPoints <= 0) return;
		
		_vipOnly = !_vipOnly;
		vipCB.cb.gotoAndStop(int(_vipOnly) + 1);

		if(_vipOnly) {
			Model.instance.view.showInfoWindow(new InfoWindow("Если поставлена галочка, сообщения увидят только пользователи со статусом VIP!", "Информация!"));
			Model.instance.addEventListener(Controller.GOT_VIP_CHAT_MESSAGE_FROM_ROOM, onNewMessageFromRoom);
		}
	}

	private function onFocusIn(e:FocusEvent):void
	{
		if(chatInput.tf.text == "Сказать")chatInput.tf.text = "";
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	private function onFocusOut(e:FocusEvent):void
	{

	}

	private function onKeyDown(e:KeyboardEvent):void
	{

		if(e.keyCode == Keyboard.ENTER){
			if(chatInput.tf.text == "") return;
			Controller.instance.sendMessageToRoom(chatInput.tf.text);
			chatInput.tf.text = "";

			//this.stage.focus = null;
			//this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
	}

	private function onNewMessageFromRoom(e:ObjectEvent):void
	{
		var message:ChatMessageItem = new ChatMessageItem(e.data);
		messagesDistribution.addChildWithDimensions(message);
		chatMessages.push(message);
		messagesDistribution.position();
		scr.setTargetAndSource(messagesDistribution, _bottomPanelMask);
		scr.position = 1;
		var difference:Number = messagesDistribution.height - _bottomPanelMask.height;
		messagesDistribution.y = _bottomPanelMask.y + scr.position * (-difference);
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

		chatInput.y = 116;
		chatInput.x = 155;
		addChild(chatInput);

		sayButton.x = 510;
		sayButton.y = 111;
		addChild(sayButton);
		sayButton.addEventListener(MouseEvent.CLICK, onSendMessage);
	}

	private function onScroll(e:Event):void
	{
		var difference:Number = messagesDistribution.height - _bottomPanelMask.height;
		messagesDistribution.y = _bottomPanelMask.y + (e.currentTarget as Scroll).position * (-difference);
	}

	private function onSendMessage(e:MouseEvent):void
	{
		if(chatInput.tf.text == "") return;
		if(!_vipOnly)
			Controller.instance.sendMessageToRoom(chatInput.tf.text);
		else
			Controller.instance.sendMessageToVIPRoom(chatInput.tf.text);
		chatInput.tf.text = "";
	}

	override public function destroy():void
	{
		Model.instance.removeEventListener(Controller.GOT_CHAT_MESSAGE_FROM_ROOM, onNewMessageFromRoom);
		if(this.stage) this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		chatInput.tf.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
		chatInput.tf.removeEventListener(FocusEvent.FOCUS_IN, onFocusOut);
		removeChild(chatInput);
		if(sayButton)removeChild(sayButton);
		sayButton = null;
		chatInput = null;

		chatMessages = null;
		scr.removeEventListener(Event.CHANGE, onScroll);
		removeChild(scr);
		scr = null;
		messagesDistribution.removeChildrenAndDestroy();
		messagesDistribution = null;
		removeChild(_bottomPanelMask);
		_bottomPanelMask = null;

		removeChild(vipCB);
		vipCB = null;
		super.destroy();
	}

	public function set vipOnly(value:Boolean):void
	{
		_vipOnly = value;
	}
}
}
