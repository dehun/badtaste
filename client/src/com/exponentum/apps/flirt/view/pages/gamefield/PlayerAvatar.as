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
import com.exponentum.apps.flirt.view.View;
import com.exponentum.apps.flirt.view.controlls.Align;
import com.exponentum.apps.flirt.view.pages.profile.friends.FriendListItem;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.load.ImageLoad;

import ru.cleptoman.net.UnsecurityDisplayLoader;

import spark.components.Button;

public class PlayerAvatar extends CasaSprite
{
	private var avatarHolder:AvatarHolder = new AvatarHolder();
	private var _photo:Loader;
	private var _isVIP:Boolean;

	private var _player:User = new User();

	public function PlayerAvatar(guid:String)
	{
		addChild(avatarHolder);
		Model.instance.addEventListener(Controller.GOT_USER_INFO, onUserInfo);
		Controller.instance.getUserInfo(guid);
		_player.guid = guid;

		isVIP = false;
	}

	private function onUserInfo(e:ObjectEvent):void
	{
		if((e.data as User).guid != _player.guid) return;
		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onUserInfo);
		_player = e.data as User;

		var req:URLRequest = new URLRequest(_player.photoLinkMedium);
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void{
			photo = loader;
		});
		loader.load(req);

		Model.instance.addEventListener(Controller.ON_GOT_VIP_POINTS, onGotUserVip);
		Controller.instance.getVipPoints(_player.guid);

		buttonMode = useHandCursor = (e.data as User).guid != Model.instance.owner.guid;
		if((e.data as User).guid == Model.instance.owner.guid) return;
		addEventListener(MouseEvent.CLICK, onShowMiniProfile);
	}

	private function onGotUserVip(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if((e.data as User).guid != _player.guid) return;
		Model.instance.removeEventListener(Controller.ON_GOT_VIP_POINTS, onGotUserVip);
		this.isVIP = user.vipPoints > 0;
	}

	private function onShowMiniProfile(e:MouseEvent):void
	{
		Model.instance.view.showMiniProfile(_player);
	}

	private function set photo(value:Loader):void
	{
		_photo = value;
		FriendListItem.Fill(value, avatarHolder.getBounds(avatarHolder));
		Align.center(_photo, avatarHolder.avatarContainer);
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
