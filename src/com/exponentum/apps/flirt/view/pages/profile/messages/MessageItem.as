/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/12/12
 * Time: 4:40 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile.messages
{
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Model;

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

	public static const REPLY_TO_MESSAGE:String = "replyToMessage";
	
	public function MessageItem(message:Object)
	{
		_message = message.Mail;
		addChild(asset);

		this.messageGuid = _message.mailGuid;
		this.senderName = _message.senderGuid;
		this.messageText = _message.subject;
		
//		asset.replyButton.visible = _message.isRead;

		asset.replyButton.addEventListener(MouseEvent.CLICK, onReply);
	}

	private function onReply(e:MouseEvent):void
	{

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
		asset.nameTf.text = "Name";
	}
}
}
