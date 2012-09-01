/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 7/31/12
 * Time: 10:09 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.view.pages.*;
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.pages.profile.presents.Present;

import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;

import org.casalib.events.LoadEvent;
import org.casalib.layout.Distribution;
import org.casalib.load.ImageLoad;

public class Profile extends BackGroundedPage
{
	private var tasksButton:SimpleButton = new TasksButton();
	private var ratingsButton:RatingsButton = new RatingsButton();
	private var zodiacSign:ZodiacSign = new ZodiacSign();
	private var shelf:Shelf = new Shelf();
	private var achievementsPanel:AchievementsPanel = new AchievementsPanel();
	private var playButton:PlayButton = new PlayButton();

	private var profileDetails:ProfileDetails = new ProfileDetails();
	private var profileAvatar:ProfileAvatar = new ProfileAvatar();
	private var fans:Fans;
	private var bottomPanel:BottomPanel;

	private var presentsContainer:Distribution = new Distribution();

	private var _user:User;
	private var _controller:Controller;

	public function Profile(user:User, controller:Controller)
	{
		_user = user;
		_controller = controller;

		init();
	}

	public function update():void
	{
		init();
	}

	private function init():void
	{
		setBackground(_user.profileBackground);
		
		if(!contains(playButton))
		{
			playButton.x = 231;
			playButton.y = -1;
			addChild(playButton);
			playButton.addEventListener(MouseEvent.CLICK, onPlayClick);
		}

		if(!contains(tasksButton))
		{
			tasksButton.x = -5;
			tasksButton.y = 176;
			addChild(tasksButton);
			tasksButton.addEventListener(MouseEvent.CLICK, onTasksClick);
		}

		if(!contains(ratingsButton))
		{
			ratingsButton.x = tasksButton.x;
			ratingsButton.y = 312;
			addChild(ratingsButton);
			ratingsButton.addEventListener(MouseEvent.CLICK, onRatingsClick);
		}

		if(!contains(zodiacSign))
		{
			zodiacSign.x = 215;
			zodiacSign.y = 195;
			addChild(zodiacSign);
			zodiacSign.gotoAndStop(_user.zodiac);
		}

		createProfileDetails();
		createAchievementsPanel();
		createProfileAvatar();
		createFansBlock();
		createBottomPanel();
		createPresents();
	}

	private function createPresents():void
	{
		if(!contains(presentsContainer)){
			shelf.x = 60;
			shelf.y = 455;
			addChild(shelf);
			
			presentsContainer.x = shelf.x;
			presentsContainer.y = shelf.y + 25;
			addChild(presentsContainer);
		}
		presentsContainer.removeChildren(true, true);
		for (var i:int = 0; i < _user.presents.length; i++)
		{
			var present:Present = new Present(_user.presents[i]);
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
		if(!bottomPanel)
		{
			bottomPanel = new BottomPanel(_controller);
			bottomPanel.x = 0;
			bottomPanel.y = 548;
			addChild(bottomPanel);
		}
	}

	private function createProfileAvatar():void
	{
		if(!contains(profileAvatar)){
			profileAvatar.x = 56;
			profileAvatar.y = 133;
			addChild(profileAvatar);

			var avatarLoad:ImageLoad = new ImageLoad(_user.photoLink);
			avatarLoad.addEventListener(LoadEvent.COMPLETE, function(e:LoadEvent){
				profileAvatar.photo = avatarLoad.contentAsBitmap;
			});
			avatarLoad.start();
		}

		profileAvatar.frame = _user.avatarFrame;
		profileAvatar.sex = _user.sex;
		profileAvatar.isVIP = _user.isVIP;
		profileAvatar.showMarkBlock(_user.userRate);
	}

	private function createAchievementsPanel():void
	{

		achievementsPanel.giftsText.text = _user.presents.length.toString();
		achievementsPanel.medalsText.text = _user.tasksDone.toString();//todo:???
		achievementsPanel.ratingText.text = _user.placeInRating.toString();//todo:???
		if(!contains(achievementsPanel)){
			achievementsPanel.x = 250;
			achievementsPanel.y = 270;
			addChild(achievementsPanel);
		}

	}

	//---------------------------------------------------------------------------------------------------profile details
	private function createProfileDetails():void
	{

		if(!contains(profileDetails)){
			profileDetails.x = 312;
			profileDetails.y = 133;
			addChild(profileDetails);

			profileDetails.hideAgeButton.gotoAndStop(int(!_user.isAgeHidden) + 1);
			profileDetails.hideCityButton.gotoAndStop(int(!_user.isCityHidden) + 1);

			profileDetails.hideAgeButton.buttonMode = profileDetails.hideAgeButton.useHandCursor = true;
			profileDetails.hideCityButton.buttonMode = profileDetails.hideCityButton.useHandCursor = true;
			profileDetails.hideAgeButton.addEventListener(MouseEvent.CLICK, onHideAgeClick);
			profileDetails.hideCityButton.addEventListener(MouseEvent.CLICK, onHideCityClick);
		}

		profileDetails.sexIndicator.gotoAndStop(_user.sex);
		profileDetails.nameText.text = _user.name;
		profileDetails.ageText.text = _user.birthDate;
		profileDetails.cityText.text = _user.city;
		profileDetails.playInCityCheckBox.gotoAndStop(1);
	}

	private function onHideAgeClick(e:MouseEvent):void
	{
		_controller.touchUserInfo('{"userInfo" : { "UserInfo" : ' +
				'{"userId" : "' + _user.id + '",' +
				'"name" : "' + _user.name + '",' +
				'"profileUrl" : "' + _user.profileLink + '",' +
				'"isMan" : "' + _user.sex + '",' +
				'"birthDate" : "' + _user.birthDate + '",' +
				'"city" : "' + _user.city + '",' +
				'"avatarUrl" : "' + _user.photoLink + '", ' +
				'"hideSocialInfo":"' + _user.isLinkHidden + '", ' +
				'"hideName":"' + !_user.isAgeHidden + '", ' +
				'"hideCity":"' + _user.isCityHidden + '"}}}');
	}

	private function onHideCityClick(e:MouseEvent):void
	{
		_controller.touchUserInfo('{"userInfo" : { "UserInfo" : ' +
				'{"userId" : "' + _user.id + '",' +
				'"name" : "' + _user.name + '",' +
				'"profileUrl" : "' + _user.profileLink + '",' +
				'"isMan" : "' + _user.sex + '",' +
				'"birthDate" : "' + _user.birthDate + '",' +
				'"city" : "' + _user.city + '",' +
				'"avatarUrl" : "' + _user.photoLink + '", ' +
				'"hideSocialInfo":"' + _user.isLinkHidden + '", ' +
				'"hideName":"' + _user.isAgeHidden + '", ' +
				'"hideCity":"' + !_user.isCityHidden + '"}}}');
	}
	//------------------------------------------------------------------------------------------------------------------

	private function createFansBlock():void
	{

		//_controller.getUsersInfos(_user.followers[0]);
		if(!fans)
		{
			fans = new Fans();
			fans.x = 532;
			fans.y = 113;
			addChild(fans);
		}

		//fans.update(_user.followers);
	}

	//----------------------------------------------------------------------------------
	// Button handlers
	//----------------------------------------------------------------------------------
	private function onPlayClick(e:MouseEvent):void
	{
		dispatchEvent(new Event(Config.GAMEFIELD));
	}

	private function onTasksClick(e:MouseEvent):void
	{
		dispatchEvent(new Event(Config.TASKS));
	}

	private function onRatingsClick(e:MouseEvent):void
	{
		dispatchEvent(new Event(Config.RATINGS));
	}

	/////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////

	public function updateChat():void
	{

	}
}
}
