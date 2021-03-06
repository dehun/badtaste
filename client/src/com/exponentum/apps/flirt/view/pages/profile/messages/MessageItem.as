/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/12/12
 * Time: 4:40 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile.messages
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;

import flash.events.MouseEvent;

import mx.states.State;

import org.casalib.display.CasaSprite;

public class MessageItem extends CasaSprite
{
	private var asset:MessageItemAsset = new MessageItemAsset();

	private var _messageGuid:String = "";
	private var _messageText:String = "";
	private var _senderName:String = "";
	private var _message:Object;
	
	private var _sender:User;

	public function MessageItem(message:Object)
	{
		_message = message.Mail;
		addChild(asset);

		this.messageGuid = _message.mailGuid;
		this.messageText = _message.subject;

		Model.instance.addEventListener(Controller.GOT_USER_INFO, onSenderProfile);
		Controller.instance.getUserInfo(_message.senderGuid);

		//asset.replyButton.visible = (_message.isRead == "false")?true:false;
		if(_message.type == "news") asset.replyButton.visible = false;

		asset.replyButton.addEventListener(MouseEvent.CLICK, onReply);
	}

	private function onSenderProfile(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(user.guid != _message.senderGuid) return;
		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onSenderProfile);
		this.senderName = user.name;
		_sender = user;
	}

	private function onReply(e:MouseEvent):void
	{
		Model.instance.view.showMessageWindow(_message, Model.instance.owner, _sender);
		Controller.instance.markMailAsRead(_message.mailGuid);
		//Controller.instance.checkMailbox();
	}

	public function get messageGuid():String
	{
		return _messageGuid;
	}

	public function set messageGuid(value:String):void
	{
		_messageGuid = value;
	}

	public function get messageText():String
	{
		return _messageText;
	}

	public function set messageText(value:String):void
	{
		_messageText = value;
		asset.textTf.text = value;
	}

	public function get senderName():String
	{
		return _senderName;
	}

	public function set senderName(value:String):void
	{
		_senderName = value;
		asset.nameTf.text = value;
	}

	override public function destroy():void
	{
		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onSenderProfile);
		super.destroy();
	}
}
}
