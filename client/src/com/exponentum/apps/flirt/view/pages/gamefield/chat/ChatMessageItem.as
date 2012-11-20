/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/23/12
 * Time: 9:42 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.gamefield.chat
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;

import flash.text.TextFieldAutoSize;

import org.casalib.display.CasaSprite;

public class ChatMessageItem extends CasaSprite
{
	private var senderGuid:String = "";
	private var message:String = "";
	private var senderName:String = "";
	private var asset:ChatMessageItemAsset = new ChatMessageItemAsset();

	public function ChatMessageItem(data:Object)
	{
		message = data.message;
		senderGuid = data.senderGuid;

		Model.instance.addEventListener(Controller.GOT_USER_INFO, onSenderInfo);
		Controller.instance.getUserInfo(senderGuid);

		addChild(asset);
		asset.textTf.multiline = asset.textTf.wordWrap = true;
		asset.textTf.text = message;
		asset.textTf.autoSize = TextFieldAutoSize.LEFT;
		asset.textTf.width = 250;
		asset.textTf.height = asset.textTf.textHeight;
	}

	private function onSenderInfo(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(user.guid != senderGuid) return;
		senderName = user.name;
		asset.nameTf.text = senderName;
		var i = 0;
		while (asset.nameTf.textWidth > 140) {
			asset.nameTf.text = user.name.substr(0, asset.nameTf.text.length - i) + "...";
			i++;
		}
	}

	override public function destroy():void
	{
		Model.instance.removeEventListener(Controller.GET_USER_INFO, onSenderInfo);
		removeChildren();
		asset = null;
		super.destroy();
	}
}
}
