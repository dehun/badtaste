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

	private var _followers:Array;
	private var _followersAvatars:Vector.<FansAvatarSmall> = new Vector.<FansAvatarSmall>();
	
	public function Fans()
	{
		addChild(fansBlock);
	}

	public function update(followers:Array):void
	{
		_followers = followers;

		Model.instance.addEventListener(Model.USER_PROFILE_UPDATED, onAddFollower);
		for (var i:int = 0; i < _followers.length; i++)
			Controller.instance.getUserInfo(_followers[i]);
	}

	private function onAddFollower(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(!user) return;
		if(_followers.indexOf(user.guid) == -1) return;

		if(!contains(pastFollowersContainer))
		{
			addChild(pastFollowersContainer);
			pastFollowersContainer.x = 40;
			pastFollowersContainer.y = 168;
		}

		trace(user.guid)

		var followerAvatar:FansAvatarSmall = new FansAvatarSmall();
		var avatarLoad:ImageLoad = new ImageLoad(user.photoLink);
		avatarLoad.addEventListener(LoadEvent.COMPLETE, function(e:LoadEvent){
			if(avatarLoad.contentAsBitmap){
				var bmp:Bitmap = avatarLoad.contentAsBitmap;
				bmp.width = followerAvatar.width;
				bmp.scaleY = bmp.scaleX;
				bmp.smoothing = true;
				followerAvatar.avatarHolder.addChild(bmp);
				_followersAvatars.push(followerAvatar);
			}
		});
		avatarLoad.start();
		
		updatePastFollowersView();
	}

	private static const SPACE:int = 2;

	private function updatePastFollowersView():void
	{
		pastFollowersContainer.removeChildren(true, true);
		for (var i:int = 0; i < _followersAvatars.length; i++)
			pastFollowersContainer.addChildWithDimensions(_followersAvatars[i], _followersAvatars[i].width + SPACE);

		pastFollowersContainer.position();
	}
}
}
