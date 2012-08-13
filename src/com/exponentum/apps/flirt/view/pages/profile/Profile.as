/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 7/31/12
 * Time: 10:09 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile
{
import com.exponentum.apps.flirt.view.controlls.scroll.Scroll;
import com.exponentum.apps.flirt.view.pages.*;
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.User;
import com.exponentum.apps.flirt.view.pages.profile.presents.Present;

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.layout.Distribution;
import org.casalib.load.ImageLoad;
import org.casalib.load.SwfLoad;
import org.osmf.events.LoaderEvent;

public class Profile extends BackGroundedPage
{
	private var foreground:ForegroundProfile = new ForegroundProfile();
	private var tasksButton:SimpleButton = new TasksButton();
	private var ratingsButton:SimpleButton = new RatingsButton();
	private var zodiacSign:ZodiacSign = new ZodiacSign();
	private var shelf:Shelf = new Shelf();
	private var achievementsPanel:AchievementsPanel = new AchievementsPanel();
	private var playButton:PlayButton = new PlayButton();

	private var profileDetails:ProfileDetails = new ProfileDetails();
	private var profileAvatar:ProfileAvatar = new ProfileAvatar();
	private var fans:Fans = new Fans();
	private var bottomPanel:BottomPanel = new BottomPanel();

	private var presentsContainer:Distribution = new Distribution();

	private var _user:User;

	public function Profile(user:User)
	{
		_user = user;

		init();
	}

	private function init():void
	{
		setBackground(_user.profileBackground);

		playButton.x = 231;
		playButton.y = -1;
		addChild(playButton);
		playButton.addEventListener(MouseEvent.CLICK, onPlayClick);

		tasksButton.x = -5;
		tasksButton.y = 176;
		addChild(tasksButton);
		
		ratingsButton.x = tasksButton.x;
		ratingsButton.y = 312;
		addChild(ratingsButton);

		zodiacSign.x = 215;
		zodiacSign.y = 195;
		addChild(zodiacSign);
		zodiacSign.gotoAndStop(_user.zodiac);

		createProfileDetails();
		createAchievementsPanel();
		createProfileAvatar();
		createFansBlock();
		createBottomPanel();
		createPresents();

		foreground.x = -10;
		foreground.y = -10;
		addChild(foreground);
		foreground.mouseChildren = foreground.mouseEnabled = false;
	}

	private function createPresents():void
	{
		shelf.x = 60;
		shelf.y = 455;
		addChild(shelf);
		
		if(!contains(presentsContainer)){
			presentsContainer.x = shelf.x;
			presentsContainer.y = shelf.y + 25;
			addChild(presentsContainer);
		}
		for (var i:int = 0; i < _user.presentIds.length; i++)
		{
			var present:Present = new Present(_user.presentIds[i]);
			present.addEventListener(Present.PRESENT_LOADED, onPresentLoaded);
			presentsContainer.addChildWithDimensions(present);
		}
	}

	private function onPresentLoaded(e:Event):void
	{
		presentsContainer.position();
		for (var i:int = 0; i < presentsContainer.numChildren; i++)
			presentsContainer.getChildAt(i).y -= presentsContainer.getChildAt(i).height;
	}

	private function createBottomPanel():void
	{
		bottomPanel.x = 0;
		bottomPanel.y = 548;
		addChild(bottomPanel);
	}

	private function createProfileAvatar():void
	{
		profileAvatar.x = 56;
		profileAvatar.y = 133;
		profileAvatar.frame = _user.profileAvatarFrame;
		profileAvatar.sex = _user.sex;
		addChild(profileAvatar);

		var avatarLoad:ImageLoad = new ImageLoad(_user.photoLink);
		avatarLoad.addEventListener(LoadEvent.COMPLETE, function(e:LoadEvent){
			profileAvatar.photo = avatarLoad.contentAsBitmap;
		});
		avatarLoad.start();
		
	}

	private function createAchievementsPanel():void
	{
		achievementsPanel.x = 250;
		achievementsPanel.y = 270;
		achievementsPanel.giftsText.text = _user.gotGifts.toString();
		achievementsPanel.medalsText.text = _user.tasksDone.toString();
		achievementsPanel.ratingText.text = _user.placeInRating.toString();
		addChild(achievementsPanel);
	}

	private function createProfileDetails():void
	{
		profileDetails.x = 312;
		profileDetails.y = 133;
		addChild(profileDetails);

		profileDetails.sexIndicator.gotoAndStop(_user.sex);
		profileDetails.nameText.text = _user.name;
		profileDetails.ageText.text = _user.birthDate;
		profileDetails.cityText.text = _user.city;
	}

	private function createFansBlock():void
	{
		fans.x = 532;
		fans.y = 113;
		addChild(fans);
	}

	//----------------------------------------------------------------------------------
	// Button handlers
	//----------------------------------------------------------------------------------
	private function onPlayClick(e:MouseEvent):void
	{
		trace("Play click");
	}
}
}
