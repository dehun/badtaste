/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/4/12
 * Time: 1:00 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;
import com.greensock.TweenMax;

import flash.display.Bitmap;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.LoaderContext;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.layout.Distribution;
import org.casalib.load.ImageLoad;

import ru.cleptoman.net.UnsecurityDisplayLoader;

public class Fans extends CasaSprite
{
	private var fansBlock:FansBlock = new FansBlock();
	private var upArrow:SimpleButton = fansBlock.upArrow;
	private var downArrow:SimpleButton = fansBlock.downArrow;
	private var pastFollowersContainer:Distribution = new Distribution(155);

	private var _followers:Array;
	private var _followersAvatars:Vector.<FansAvatarSmall> = new Vector.<FansAvatarSmall>();
	private var userMask:Sprite = fansBlock.usersMask;

	private var offset:int = 0;
	private var updatedUsers:int = 0;

	public function Fans()
	{
		addChild(fansBlock);

		upArrow.addEventListener(MouseEvent.CLICK, onUp);
		downArrow.addEventListener(MouseEvent.CLICK, onDown);
		
		userMask.visible = false;
		upArrow.visible = false;
		downArrow.visible = false;
	}

	private function onUp(e:MouseEvent):void
	{
		offset --;
		configureButtons();
		upArrow.removeEventListener(MouseEvent.CLICK, onUp);
		TweenMax.to(pastFollowersContainer, .3, {y:pastFollowersContainer.y + (new FansAvatarSmall()).height, onComplete:function():void{
			upArrow.addEventListener(MouseEvent.CLICK, onUp);
		}});
	}

	private function onDown(e:MouseEvent):void
	{
		offset ++;
		configureButtons();
		downArrow.removeEventListener(MouseEvent.CLICK, onDown);
		TweenMax.to(pastFollowersContainer, .3, {y:pastFollowersContainer.y - (new FansAvatarSmall()).height, onComplete:function():void{
			downArrow.addEventListener(MouseEvent.CLICK, onDown);
		}});
	}

	public function update(followers:Array):void
	{
		_followers = followers;

		userMask.visible = _followers.length > 0;

		updatedUsers = 0;
		offset = 0;
		Model.instance.addEventListener(Controller.GOT_USER_INFO, onUserInfo);

		for (var i:int = 0; i < _followers.length; i++)
			Controller.instance.getUserInfo(_followers[i]);

		configureButtons();
	}

	private function configureButtons():void
	{
		upArrow.visible = downArrow.visible = _followers.length > 3;
		upArrow.visible = offset > 0;
		downArrow.visible = offset < int((_followers.length - 1) / 3);
	}

	private function onUserInfo(e:ObjectEvent):void
	{
		var user:User = e.data as User;

		if(_followers.indexOf(user.guid) == -1) return;

		if(updatedUsers == 0)
		{
			fansBlock.fansAvatarBig.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				Model.instance.view.showMiniProfile(user);
			});

			var loader:UnsecurityDisplayLoader = new UnsecurityDisplayLoader();
			loader.addEventListener(Event.INIT, function(e:Event):void {
				var loader:UnsecurityDisplayLoader = e.target as UnsecurityDisplayLoader;
				var bmp:Bitmap = (new Bitmap((loader.content as Bitmap).bitmapData));
				bmp.width = fansBlock.fansAvatarBig.width;
				bmp.scaleY = bmp.scaleX;
				bmp.smoothing = true;
				fansBlock.fansAvatarBig.fansAvatarHolder.addChild(bmp);
				updatePastFollowersView();
			});
			var req:URLRequest		= new URLRequest(user.photoLink);
			loader.load(req);
			updatedUsers ++;
		}else
		{
			updatedUsers ++;

			if(updatedUsers == _followers.length)
				Model.instance.removeEventListener(Controller.GOT_USER_INFO, onUserInfo);

			if(!fansBlock.contains(pastFollowersContainer) && _followers.length > 0)
			{
				fansBlock.addChildAt(pastFollowersContainer, fansBlock.getChildIndex(userMask) - 1);
				pastFollowersContainer.x = 40;
				pastFollowersContainer.y = 168;
				pastFollowersContainer.mask = userMask;
			}

			var followerAvatar:FansAvatarSmall = new FansAvatarSmall();
			followerAvatar.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				Model.instance.view.showMiniProfile(user);
			});

			_followersAvatars.push(followerAvatar);
			var loader:UnsecurityDisplayLoader = new UnsecurityDisplayLoader();
			loader.addEventListener(Event.INIT, function(e:Event):void {
				var loader:UnsecurityDisplayLoader = e.target as UnsecurityDisplayLoader;
				var bmp:Bitmap = (new Bitmap((loader.content as Bitmap).bitmapData));
				bmp.width = followerAvatar.width;
				bmp.scaleY = bmp.scaleX;
				bmp.smoothing = true;
				followerAvatar.avatarHolder.addChild(bmp);
				updatePastFollowersView();
			});
			var req:URLRequest		= new URLRequest(user.photoLink);
			loader.load(req);
		}
	}

	private static const SPACE:int = 2;

	private function updatePastFollowersView():void
	{
		pastFollowersContainer.removeChildren();
		for (var i:int = 0; i < _followersAvatars.length; i++)
			pastFollowersContainer.addChildWithDimensions(_followersAvatars[i], 48 + SPACE, 48 + SPACE + 2);

		pastFollowersContainer.position();
	}

	override public function destroy():void
	{
		removeChildren();
		fansBlock = null;
		upArrow = null;
		downArrow = null;
		pastFollowersContainer = null;

		_followers = null;
		_followersAvatars = null;
		userMask = null;
		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onUserInfo);
		super.destroy();
	}
}
}
