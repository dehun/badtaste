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

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;

import org.casalib.display.CasaSprite;
import org.casalib.layout.Distribution;

public class Fans extends CasaSprite
{
	private var fansBlock:FansBlock = new FansBlock();
	private var upArrow:SimpleButton = fansBlock.upArrow;
	private var downArrow:SimpleButton = fansBlock.downArrow;
	private var mainFollower:Sprite = fansBlock.fansAvatarBig;
	private var pastFollowersContainer:Distribution = new Distribution();

	private var loadedFollowers:int = 0;
	private var _followers:Array;
	
	public function Fans()
	{
		addChild(fansBlock);
	}

	public function update(followers:Array):void
	{
		_followers = followers;
		updateAvatars();
	}

	private function onFollowerLoaded(e:Event):void
	{

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
		for (var i:int = 0; i < 3; i++)
		{
			var followerAvatar:FansAvatarSmall = new FansAvatarSmall();
			pastFollowersContainer.addChildWithDimensions(followerAvatar, followerAvatar.width + 2);
		}
		pastFollowersContainer.position();
	}
	
	
}
}
