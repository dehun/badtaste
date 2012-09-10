/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/24/12
 * Time: 8:33 AM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile.messages
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;

import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.load.ImageLoad;

import ru.cleptoman.net.UnsecurityDisplayLoader;

public class MessageWindow extends CasaSprite
{
	private var asset:MessageWindowAsset = new MessageWindowAsset();
	private var _message:Object;
	private var _sender:User;

	public function MessageWindow(message:Object, sender:User)
	{
		_message = message;
		_sender = sender;
		
		addChild(asset);
		asset.message.text = message.body;
		asset.closeButton.addEventListener(MouseEvent.CLICK, onClose);
		asset.replyButton.addEventListener(MouseEvent.CLICK, onReply);
		asset.senderName.text = sender.name;
		asset.messageInput.text = "";

//		var imageLoad:ImageLoad = new ImageLoad(sender.photoLink);
//		imageLoad.addEventListener(LoadEvent.COMPLETE, function(e:LoadEvent){
//			if(imageLoad.contentAsBitmap){
//				var bmp:Bitmap = imageLoad.contentAsBitmap;
//				bmp.width = asset.senderAvatarContainer.width;
//				bmp.scaleY = bmp.scaleX;
//				bmp.smoothing = true;
//				asset.senderAvatarContainer.holder.addChild(bmp);
//			}
//		});
//		imageLoad.start();
		var loader:UnsecurityDisplayLoader = new UnsecurityDisplayLoader();
		loader.addEventListener(Event.INIT, function(e:Event):void {
			var loader:UnsecurityDisplayLoader = e.target as UnsecurityDisplayLoader;
			var bmp:Bitmap = (new Bitmap((loader.content as Bitmap).bitmapData));
			bmp.width = asset.senderAvatarContainer.width;
			bmp.scaleY = bmp.scaleX;
			bmp.smoothing = true;
			asset.senderAvatarContainer.holder.addChild(bmp);
		});
		var req:URLRequest = new URLRequest(Model.instance.owner.photoLink);
		loader.load(req);
	}

	private function onReply(e:MouseEvent):void
	{
		if(asset.messageInput.text != "")
		{
			Controller.instance.sendMail(_sender.guid, "RE:" + _message.subject, asset.messageInput.text);
		}
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
