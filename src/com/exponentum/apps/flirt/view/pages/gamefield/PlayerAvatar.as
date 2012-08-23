/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/2/12
 * Time: 11:16 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.gamefield
{
import flash.display.Bitmap;


import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.load.ImageLoad;

public class PlayerAvatar extends CasaSprite
{
	private var avatarHolder:AvatarHolder = new AvatarHolder();
	private var _photo:Bitmap;
	private var _isVIP:Boolean;
	
	private var avatarLoad:ImageLoad;

	public function PlayerAvatar(photoURL:String)
	{
		addChild(avatarHolder);
		avatarLoad = new ImageLoad(photoURL);
		avatarLoad.addEventListener(LoadEvent.COMPLETE, onLoadComplete);
		avatarLoad.start();
	}

	private function onLoadComplete(e:LoadEvent):void
	{
		this.photo = avatarLoad.contentAsBitmap;
	}

	private function set photo(value:Bitmap):void
	{
		_photo = value;
		_photo.width = avatarHolder.avatarContainer.width;
		_photo.scaleY = _photo.scaleX;
		_photo.smoothing = true;
		while(avatarHolder.avatarContainer.numChildren) avatarHolder.avatarContainer.removeChildAt(0);
		avatarHolder.avatarContainer.addChild(_photo);
	}

	public function set isVIP(value:Boolean):void
	{
		_isVIP = value;
		avatarHolder.vipMarker.visible = _isVIP;
	}
}
}
