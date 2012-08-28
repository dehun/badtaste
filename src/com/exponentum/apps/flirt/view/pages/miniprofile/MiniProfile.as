/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/26/12
 * Time: 5:51 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.miniprofile
{
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.pages.BackGroundedPage;
import com.exponentum.apps.flirt.view.pages.profile.Fans;
import com.exponentum.apps.flirt.view.pages.profile.ProfileAvatar;
import com.exponentum.apps.flirt.view.pages.profile.presents.Present;
import com.exponentum.utils.centerX;
import com.exponentum.utils.centerY;

import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.layout.Distribution;
import org.casalib.load.ImageLoad;

public class MiniProfile extends CasaSprite
{
	private var bg:BackGroundedPage = new BackGroundedPage();
	private var profileMask:ProfileMask = new ProfileMask();

	private var tasksButton:SimpleButton = new TasksButton();
	private var ratingsButton:RatingsButton = new RatingsButton();
	private var zodiacSign:ZodiacSign = new ZodiacSign();
	private var shelf:Shelf = new Shelf();
	private var achievementsPanel:AchievementsPanel = new AchievementsPanel();
	private var playButton:PlayButton = new PlayButton();

	private var profileDetails:ProfileDetails = new ProfileDetails();
	private var profileAvatar:ProfileAvatar = new ProfileAvatar();
	private var fans:Fans = new Fans();

	private var presentsContainer:Distribution = new Distribution();

	private var _user:User;

	private var profileInfoContainer:CasaSprite = new CasaSprite();


	public function MiniProfile(user:User)
	{
		_user = user;

		createMask();
		createCloseButton();
		createCorners();

		createBecameFanButton();
		createGiftButton();

		profileInfoContainer.y = 75;
		addChild(profileInfoContainer);

		createProfileDetails();
		createAchievementsPanel();
		createProfileAvatar();
		createFansBlock();
		createPresents();
	}

	//
	private function createPresents():void
	{
		shelf.x = 60;
		shelf.y = 455;
		profileInfoContainer.addChild(shelf);

		if(!contains(presentsContainer)){
			presentsContainer.x = shelf.x;
			presentsContainer.y = shelf.y + 25;
			profileInfoContainer.addChild(presentsContainer);
		}
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

	private function createProfileAvatar():void
	{
		zodiacSign.x = 215;
		zodiacSign.y = 195;
		profileInfoContainer.addChild(zodiacSign);
		zodiacSign.gotoAndStop(_user.zodiac);

		profileAvatar.x = 56;
		profileAvatar.y = 133;
		profileAvatar.frame = _user.profileAvatarFrame;
		profileAvatar.sex = _user.sex;
		profileAvatar.isVIP = _user.isVIP;
		profileInfoContainer.addChild(profileAvatar);

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
		profileInfoContainer.addChild(achievementsPanel);
	}

	private function createProfileDetails():void
	{
		profileDetails.x = 312;
		profileDetails.y = 133;
		profileInfoContainer.addChild(profileDetails);

		profileDetails.sexIndicator.gotoAndStop(_user.sex);
		profileDetails.nameText.text = _user.name;
		profileDetails.ageText.text = _user.birthDate;
		profileDetails.cityText.text = _user.city;
		profileDetails.playInCityCheckBox.gotoAndStop(1);
		profileDetails.hideAgeButton.gotoAndStop(1);
		profileDetails.hideCityButton.gotoAndStop(1);
	}

	private function createFansBlock():void
	{
		fans.x = 532;
		fans.y = 113;
		profileInfoContainer.addChild(fans);
	}

	//

	private function createBecameFanButton():void
	{
		var becomeFanButton:BecameFunButton = new BecameFunButton();
		becomeFanButton.x = profileMask.x + (profileMask.width - becomeFanButton.width) / 2;
		becomeFanButton.y = profileMask.y;
		becomeFanButton.addEventListener(MouseEvent.CLICK, onBecameFan);
		addChild(becomeFanButton);
	}

	private function createGiftButton():void
	{
		var sendGiftButton:SendGiftButton = new SendGiftButton();
		sendGiftButton.y = profileMask.y + profileMask.height - sendGiftButton.height - 35;
		sendGiftButton.x = 240;
		sendGiftButton.addEventListener(MouseEvent.CLICK, onSendGift);
		addChild(sendGiftButton);
	}

	private function createCloseButton():void
	{
		var closeButton:CloseButton = new CloseButton();
		closeButton.x = profileMask.x + profileMask.width - 30;
		closeButton.y = profileMask.y + 35;
		addChild(closeButton);
		closeButton.addEventListener(MouseEvent.CLICK, onClose);
	}

	private function createCorners():void
	{
		var corners:Corners = new Corners();
		corners.x = profileMask.x - 3;
		corners.y = profileMask.y + profileMask.height - corners.height + 4;
		corners.mouseEnabled = corners.mouseChildren = false;
		addChild(corners);
	}

	private function createMask():void
	{
		bg.setBackground(3);
		addChild(bg);
		addChild(profileMask);
		centerX(profileMask, 760);
		profileMask.y = 100;
		bg.mask = profileMask;
	}

	private function onBecameFan(e:MouseEvent):void
	{
		trace("so fan!");
	}

	private function onClose(e:MouseEvent):void
	{
		trace("soClose!");
	}

	private function onSendGift(e:MouseEvent):void
	{
		trace("so send!");
	}
}
}
