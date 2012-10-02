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
import com.exponentum.apps.flirt.view.controlls.Align;
import com.exponentum.apps.flirt.view.controlls.preloader.BlockerPreloader;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.net.URLRequest;

import mx.utils.NameUtil;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.load.ImageLoad;

import ru.cleptoman.net.UnsecurityDisplayLoader;

public class MessageWindow extends CasaSprite
{
	private var asset:MessageWindowAsset = new MessageWindowAsset();
	private var _message:Object;
	private var _sender:User;
	private var _receiver:User;

	public function MessageWindow(message:Object, sender:User, receiver:User = null)
	{

		_message = message;
		_sender = sender;
		
		addChild(asset);
		asset.message.text = "...";
		if(message) asset.message.text = message.body;
		else
		{
			_message = {};
			_message.subject = "...";
		}
		asset.closeButton.addEventListener(MouseEvent.CLICK, onClose);
		asset.replyButton.addEventListener(MouseEvent.CLICK, onReply);
		asset.senderName.text = sender.name;
		asset.messageInput.text = "";

//		var loader:UnsecurityDisplayLoader = new UnsecurityDisplayLoader();
//		loader.addEventListener(Event.INIT, function(e:Event):void {
//			var loader:UnsecurityDisplayLoader = e.target as UnsecurityDisplayLoader;
//			var bmp:Bitmap = (new Bitmap((loader.content as Bitmap).bitmapData));
//			bmp.width = asset.senderAvatarContainer.width;
//			bmp.scaleY = bmp.scaleX;
//			bmp.smoothing = true;
//			asset.senderAvatarContainer.holder.addChild(bmp);
//		});
//		var req:URLRequest = new URLRequest(_sender.photoLinkMedium);
		var loader:Loader = new Loader();
		var holder:Sprite = asset.senderAvatarContainer.holder;
		var bp:BlockerPreloader = new BlockerPreloader(holder, holder.width, holder.height, 0);
		bp.preload(1);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void{
			Align.center(loader, holder);
			holder.addChild(loader);
			bp.partsLoaded++;
		});

		var req:URLRequest = new URLRequest(_sender.photoLinkMedium);
		loader.load(req);

		this.filters = [new DropShadowFilter(0, 45, 0x0, 1, 30, 30, 1, 3)];
	}

	private function onReply(e:MouseEvent):void
	{
		if(asset.messageInput.text != "")
		{
			Controller.instance.sendMail(_sender.guid, (_message.subject != "...")?"RE:" + _message.subject:"...", asset.messageInput.text);
			this.destroy();
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
