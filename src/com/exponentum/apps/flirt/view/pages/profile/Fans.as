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

import flash.display.Bitmap;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.utils.Dictionary;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.layout.Distribution;
import org.casalib.load.ImageLoad;
import org.osmf.metadata.IFacet;

public class Fans extends CasaSprite
{
	private var fansBlock:FansBlock = new FansBlock();
	private var upArrow:SimpleButton = fansBlock.upArrow;
	private var downArrow:SimpleButton = fansBlock.downArrow;
	private var mainFollower:Sprite = fansBlock.fansAvatarBig;
	private var pastFollowersContainer:Distribution = new Distribution();

	private var loadedFollowers:int = 0;
	private var _followers:Array;
	private var _profiles:Dictionary = new Dictionary();
	
	public function Fans()
	{
		addChild(fansBlock);
	}

	public function update(followers:Array):void
	{
		_followers = followers;

		Model.instance.addEventListener(Model.USER_PROFILE_UPDATED, onAddFollower);
		getFollowersQueue(0);
	}

	private var numFollowers:int = 0;
	private function getFollowersQueue(followerIndex:int):void
	{
		Controller.instance.getUserInfo(_followers[followerIndex]);
	}

	private function onAddFollower(e:ObjectEvent):void
	{
		numFollowers ++;

		if(numFollowers == _followers.length - 1)
		{
			numFollowers = 0;
			trace("followers loaded");
		}else
		{
			getFollowersQueue(numFollowers);
		}

//		if(!_profiles[(e.data as User).guid]){
//			_profiles[(e.data as User).guid] = e.data;
//			//updateAvatars();
//		}
	}

	private function updateAvatars():void
	{
		if(!contains(pastFollowersContainer))
		{
			addChild(pastFollowersContainer);
			pastFollowersContainer.x = 40;
			pastFollowersContainer.y = 168;
		}

		pastFollowersContainer.removeChildren(true, true);
		for (var i:int = 0; i < _followers.length; i++)
		{
			var followerAvatar:FansAvatarSmall = new FansAvatarSmall();
			if(_profiles[_followers[i]]){
				var avatarLoad:ImageLoad = new ImageLoad(_profiles[_followers[i]].photoLink);
				avatarLoad.addEventListener(LoadEvent.COMPLETE, function(e:LoadEvent){
					if(avatarLoad.contentAsBitmap){
						var bmp:Bitmap = avatarLoad.contentAsBitmap;
						bmp.width = followerAvatar.width;
						bmp.scaleY = bmp.scaleX;
						bmp.smoothing = true;
						followerAvatar.avatarHolder.addChild(bmp);
					}
				});
				avatarLoad.start();
				pastFollowersContainer.addChildWithDimensions(followerAvatar, followerAvatar.width + 2);
			}

		}
		pastFollowersContainer.position();
	}
	
	
}
}
