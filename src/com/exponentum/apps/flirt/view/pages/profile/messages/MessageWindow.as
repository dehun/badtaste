/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/24/12
 * Time: 8:33 AM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile.messages
{
import com.exponentum.apps.flirt.model.profile.User;

import flash.events.MouseEvent;

import org.casalib.display.CasaSprite;

public class MessageWindow extends CasaSprite
{
	private var asset:MessageWindowAsset = new MessageWindowAsset();

	public function MessageWindow(message:Object, sender:User)
	{
		addChild(asset);
		asset.message.text = message.body;
		asset.closeButton.addEventListener(MouseEvent.CLICK, onClose);
		asset.replyButton.addEventListener(MouseEvent.CLICK, onReply);
	}

	private function onReply(e:MouseEvent):void
	{

	}

	private function onClose(e:MouseEvent):void
	{
		destroy();
	}

	override public function destroy():void
	{
		removeChildren(true, true);
		super.destroy();
	}
}
}
