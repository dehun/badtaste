/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/2/12
 * Time: 11:16 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.gamefield
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;

import flash.display.Bitmap;
import flash.events.Event;
import flash.net.URLRequest;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.load.ImageLoad;

import ru.cleptoman.net.UnsecurityDisplayLoader;

public class PlayerAvatar extends CasaSprite
{
	private var avatarHolder:AvatarHolder = new AvatarHolder();
	private var _photo:Bitmap;
	private var _isVIP:Boolean;

	private var _player:User = new User();

	public function PlayerAvatar(guid:String)
	{
		addChild(avatarHolder);
		Model.instance.addEventListener(Controller.GOT_USER_INFO, onUserInfo);
		Controller.instance.getUserInfo(guid);
		_player.guid = guid;
	}

	private function onUserInfo(e:ObjectEvent):void
	{
		if((e.data as User).guid != _player.guid) return;
		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onUserInfo);
		_player = e.data as User;

		var loader:UnsecurityDisplayLoader = new UnsecurityDisplayLoader();
		loader.addEventListener(Event.INIT, function(e:Event):void {
			var loader:UnsecurityDisplayLoader = e.target as UnsecurityDisplayLoader;
			photo = (new Bitmap((loader.content as Bitmap).bitmapData));
		});
		var req:URLRequest = new URLRequest(_player.photoLinkMedium);
		loader.load(req);
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

	public function get player():User
	{
		return _player;
	}
}
}
