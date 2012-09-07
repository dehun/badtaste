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
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;
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
	private var profileAvatar:ProfileAvatar;
	private var fans:Fans;
	private var _bottomPanel:BottomPanel;

	private var presentsContainer:Distribution = new Distribution();

	public function Profile()
	{
		configureListeners();
		Controller.instance.getUserInfo(Model.instance.owner.guid);

		createView();
	}

	private function createView():void
	{
		playButton.x = 231;
		playButton.y = -1;
		addChild(playButton);
		playButton.addEventListener(MouseEvent.CLICK, onPlayClick);

		tasksButton.x = -5;
		tasksButton.y = 176;
		addChild(tasksButton);
		tasksButton.addEventListener(MouseEvent.CLICK, onTasksClick);

		ratingsButton.x = tasksButton.x;
		ratingsButton.y = 312;
		addChild(ratingsButton);
		ratingsButton.addEventListener(MouseEvent.CLICK, onRatingsClick);
	}
	
	private function configureListeners():void
	{
		Model.instance.addEventListener(Controller.GOT_USER_INFO, onGotUserInfo);
		Model.instance.addEventListener(Controller.ON_GOT_VIP_POINTS, onGotVipPoints);
		Model.instance.addEventListener(Controller.ON_GOT_DECORATIONS, onGotDecorations);
		Model.instance.addEventListener(Controller.ON_GOT_USER_FOLLOWERS, onGotUserFollowers);
		Model.instance.addEventListener(Controller.ON_GOT_MY_GIFTS, onGotMyGifts);
		Model.instance.addEventListener(Controller.ON_GOT_USER_RATE, onGotUserRate);
	}


	private function onGotUserInfo(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(!user) return;

		//zodiac
		if(!contains(zodiacSign))
		{
			zodiacSign.x = 215;
			zodiacSign.y = 195;
			addChild(zodiacSign);
		}
		zodiacSign.gotoAndStop(Model.instance.owner.zodiac);

		//details
		if(!contains(profileDetails)){
			profileDetails.x = 312;
			profileDetails.y = 133;
			addChild(profileDetails);

			profileDetails.hideAgeButton.buttonMode = profileDetails.hideAgeButton.useHandCursor = true;
			profileDetails.hideCityButton.buttonMode = profileDetails.hideCityButton.useHandCursor = true;
			profileDetails.hideAgeButton.addEventListener(MouseEvent.CLICK, onHideAgeClick);
			profileDetails.hideCityButton.addEventListener(MouseEvent.CLICK, onHideCityClick);
			profileDetails.playInCityCheckBox.addEventListener(MouseEvent.CLICK, onPlayInCityClick);
		}

		profileDetails.hideAgeButton.gotoAndStop(int(!Model.instance.owner.isAgeHidden) + 1);
		profileDetails.hideCityButton.gotoAndStop(int(!Model.instance.owner.isCityHidden) + 1);

		profileDetails.sexIndicator.gotoAndStop(Model.instance.owner.sex);
		profileDetails.nameText.text = Model.instance.owner.name;
		profileDetails.ageText.text = Model.instance.owner.birthDate;
		profileDetails.cityText.text = Model.instance.owner.city;
		profileDetails.playInCityCheckBox.gotoAndStop(1);

		if(!profileAvatar)
		{
			profileAvatar = new ProfileAvatar();
			profileAvatar.x = 56;
			profileAvatar.y = 133;
			profileAvatar.frame = 1;
			profileAvatar.sex = Model.instance.owner.sex;
			profileAvatar.isVIP = false;
			profileAvatar.showMarkBlock(0, false);
			addChild(profileAvatar);

			var avatarLoad:ImageLoad = new ImageLoad(Model.instance.owner.photoLink);
			avatarLoad.addEventListener(LoadEvent.COMPLETE,
					function(e:LoadEvent){
						profileAvatar.photo = avatarLoad.contentAsBitmap;
					});
			avatarLoad.start();
		}

		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onGotUserInfo);

		Controller.instance.getDecorationFor(Model.instance.owner.guid);
		Controller.instance.getVipPoints(Model.instance.owner.guid);
		Controller.instance.getUserFollowers(Model.instance.owner.guid);
		Controller.instance.getMyGifts();
		Controller.instance.getUserRate(Model.instance.owner.guid);
			//TODO: coins, city checkbox, link to social

		if(!contains(achievementsPanel)){
			achievementsPanel.x = 250;
			achievementsPanel.y = 270;
			addChild(achievementsPanel);
		}

		if(!_bottomPanel)
		{
			_bottomPanel = new BottomPanel();
			_bottomPanel.x = 0;
			_bottomPanel.y = 548;
			addChild(_bottomPanel);
		}
	}

	

	private function onPlayInCityClick(e:MouseEvent):void
	{

	}

	private function onHideAgeClick(e:MouseEvent):void
	{

	}

	private function onHideCityClick(e:MouseEvent):void
	{

	}

	private function onGotVipPoints(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(!user || user.guid != Model.instance.owner.guid) return;

		profileAvatar.isVIP = Model.instance.owner.vipPoints > 0;
	}

	private function onGotDecorations(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(!user || user.guid != Model.instance.owner.guid) return;

		setBackground(user.profileBackground);
		profileAvatar.frame = user.avatarFrame;
	}

	private function onGotUserFollowers(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(!user || user.guid != Model.instance.owner.guid) return;

		if(!fans)
		{
			fans = new Fans();
			fans.x = 532;
			fans.y = 113;
			addChild(fans);
		}
		fans.update(Model.instance.owner.followers);
	}

	private function onGotMyGifts(e:Event):void
	{
		if(!contains(presentsContainer)){
			shelf.x = 60;
			shelf.y = 455;
			addChild(shelf);

			presentsContainer.x = shelf.x;
			presentsContainer.y = shelf.y + 25;
			addChild(presentsContainer);
		}
		const presentsShown:int = 6;
		presentsContainer.removeChildren(true, true);
		for (var i:int = 0; i < Math.min(Model.instance.owner.presents.length, presentsShown); i++)
		{
			var present:Present = new Present(Model.instance.owner.presents[i].SendedGift.giftGuid);
			present.addEventListener(Present.PRESENT_LOADED, onPresentLoaded);
			presentsContainer.addChildWithDimensions(present);
		}
	}

	private function onPresentLoaded(e:Event):void
	{
		presentsContainer.position();
		for (var i:int = 0; i < presentsContainer.numChildren; i++)
			presentsContainer.getChildAt(i).y -= presentsContainer.getChildAt(i).height;

		achievementsPanel.giftsText.text = Model.instance.owner.presents.length.toString();
//		achievementsPanel.medalsText.text = Model.instance.owner.tasksDone.toString();//todo:
//		achievementsPanel.ratingText.text = Model.instance.owner.placeInRating.toString();//todo:
	}

	private function onGotUserRate(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(!user || user.guid != Model.instance.owner.guid) return;

		profileAvatar.showMarkBlock(Model.instance.owner.userRate, true) //todo:
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

	override public function destroy():void
	{
		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onGotUserInfo);
		Model.instance.removeEventListener(Controller.ON_GOT_VIP_POINTS, onGotVipPoints);
		Model.instance.removeEventListener(Controller.ON_GOT_DECORATIONS, onGotDecorations);
		Model.instance.removeEventListener(Controller.ON_GOT_USER_FOLLOWERS, onGotUserFollowers);
		Model.instance.removeEventListener(Controller.ON_GOT_MY_GIFTS, onGotMyGifts);
		Model.instance.removeEventListener(Controller.ON_GOT_USER_RATE, onGotUserRate);

		removeChildren();
		ratingsButton = null;
		zodiacSign = null;
		shelf = null;
		achievementsPanel = null;
		playButton = null;

		profileDetails = null;
		profileAvatar = null;
		fans = null;
		_bottomPanel = null;

		presentsContainer = null;
		super.destroy();
	}
}
}
