/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 7/31/12
 * Time: 10:09 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.miniprofile
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.view.pages.*;
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.pages.profile.BottomPanel;
import com.exponentum.apps.flirt.view.pages.profile.Fans;
import com.exponentum.apps.flirt.view.pages.profile.ProfileAvatar;
import com.exponentum.apps.flirt.view.pages.profile.presents.Present;
import com.exponentum.utils.centerX;

import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;

import org.casalib.events.LoadEvent;
import org.casalib.layout.Distribution;
import org.casalib.load.ImageLoad;

public class MiniProfile extends BackGroundedPage
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
	
	private var _user:User;

	public function MiniProfile(user:User)
	{
		_user = user;
		configureListeners();
		Controller.instance.getUserInfo(_user.guid);

		createView();
	}

	private function createView():void
	{
		createMask();
		createCloseButton();
		createCorners();

		createBecameFanButton();
		createGiftButton();
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
		zodiacSign.gotoAndStop(_user.zodiac);

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

		profileDetails.hideAgeButton.gotoAndStop(int(!_user.isAgeHidden) + 1);
		profileDetails.hideCityButton.gotoAndStop(int(!_user.isCityHidden) + 1);

		profileDetails.sexIndicator.gotoAndStop(_user.sex);
		profileDetails.nameText.text = _user.name;
		profileDetails.ageText.text = _user.birthDate;
		profileDetails.cityText.text = _user.city;
		profileDetails.playInCityCheckBox.gotoAndStop(1);

		if(!profileAvatar)
		{
			profileAvatar = new ProfileAvatar();
			profileAvatar.x = 56;
			profileAvatar.y = 133;
			profileAvatar.frame = 1;
			profileAvatar.sex = _user.sex;
			profileAvatar.isVIP = false;
			profileAvatar.showMarkBlock(0, false);
			addChild(profileAvatar);

			var avatarLoad:ImageLoad = new ImageLoad(_user.photoLink);
			avatarLoad.addEventListener(LoadEvent.COMPLETE,
					function(e:LoadEvent){
						profileAvatar.photo = avatarLoad.contentAsBitmap;
					});
			avatarLoad.start();
		}

		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onGotUserInfo);

		Controller.instance.getDecorationFor(_user.guid);
		Controller.instance.getVipPoints(_user.guid);
		Controller.instance.getUserFollowers(_user.guid);
		Controller.instance.getMyGifts();
		Controller.instance.getUserRate(_user.guid);
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
		Controller.instance.touchUserInfoByUser({
			name:_user.name,
			hideSocialInfo:false,
			hideBirthDate:!_user.isAgeHidden,
			hideCity:_user.isCityHidden
		});
	}

	private function onHideCityClick(e:MouseEvent):void
	{
		Controller.instance.touchUserInfoByUser({
			name:_user.name,
			hideSocialInfo:false,
			hideBirthDate:_user.isAgeHidden,
			hideCity:!_user.isCityHidden
		});
	}

	private function onGotVipPoints(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(!user || user.guid != _user.guid) return;

		profileAvatar.isVIP = _user.vipPoints > 0;
	}

	private function onGotDecorations(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(!user || user.guid != _user.guid) return;

		setBackground(user.profileBackground);
		profileAvatar.frame = user.avatarFrame;
	}

	private function onGotUserFollowers(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(!user || user.guid != _user.guid) return;
		if(_user.followers.length == 0) return;

		if(!fans)
		{
			fans = new Fans();
			fans.x = 532;
			fans.y = 113;
			addChild(fans);
		}
		fans.update(_user.followers);
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
		for (var i:int = 0; i < Math.min(_user.presents.length, presentsShown); i++)
		{
			var present:Present = new Present(_user.presents[i].SendedGift.giftGuid);
			present.addEventListener(Present.PRESENT_LOADED, onPresentLoaded);
			presentsContainer.addChildWithDimensions(present);
		}
	}

	private function onPresentLoaded(e:Event):void
	{
		presentsContainer.position();
		for (var i:int = 0; i < presentsContainer.numChildren; i++)
			presentsContainer.getChildAt(i).y -= presentsContainer.getChildAt(i).height;

		achievementsPanel.giftsText.text = _user.presents.length.toString();
//		achievementsPanel.medalsText.text = _user.tasksDone.toString();//todo:
//		achievementsPanel.ratingText.text = _user.placeInRating.toString();//todo:
	}

	private function onGotUserRate(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(!user || user.guid != _user.guid) return;

		profileAvatar.showMarkBlock(_user.userRate, true) //todo:
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

	private var profileMask:ProfileMask = new ProfileMask();
	private var bg:BackGroundedPage = new BackGroundedPage();

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
		bg.setBackground(_user.profileBackground);
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

///**
// * Created by IntelliJ IDEA.
// * User: Exponentum
// * Date: 8/26/12
// * Time: 5:51 PM
// * To change this template use File | Settings | File Templates.
// */
//package com.exponentum.apps.flirt.view.pages.miniprofile
//{
//import com.exponentum.apps.flirt.model.Model;
//import com.exponentum.apps.flirt.model.profile.User;
//import com.exponentum.apps.flirt.view.pages.BackGroundedPage;
//import com.exponentum.apps.flirt.view.pages.profile.Fans;
//import com.exponentum.apps.flirt.view.pages.profile.ProfileAvatar;
//import com.exponentum.apps.flirt.view.pages.profile.presents.Present;
//import com.exponentum.utils.centerX;
//import com.exponentum.utils.centerY;
//
//import flash.display.SimpleButton;
//import flash.events.Event;
//import flash.events.MouseEvent;
//
//import org.casalib.display.CasaSprite;
//import org.casalib.events.LoadEvent;
//import org.casalib.layout.Distribution;
//import org.casalib.load.ImageLoad;
//
//public class MiniProfile extends CasaSprite
//{
//	private var bg:BackGroundedPage = new BackGroundedPage();
//	private var profileMask:ProfileMask = new ProfileMask();
//
//	private var tasksButton:SimpleButton = new TasksButton();
//	private var ratingsButton:RatingsButton = new RatingsButton();
//	private var zodiacSign:ZodiacSign = new ZodiacSign();
//	private var shelf:Shelf = new Shelf();
//	private var achievementsPanel:AchievementsPanel = new AchievementsPanel();
//	private var playButton:PlayButton = new PlayButton();
//
//	private var profileDetails:ProfileDetails = new ProfileDetails();
//	private var profileAvatar:ProfileAvatar = new ProfileAvatar();
//	private var fans:Fans = new Fans();
//
//	private var presentsContainer:Distribution = new Distribution();
//
//	private var _user:User;
//
//	private var profileInfoContainer:CasaSprite = new CasaSprite();
//
//
//	public function MiniProfile(user:User)
//	{
//		_user = user;
//
//		createMask();
//		createCloseButton();
//		createCorners();
//
//		createBecameFanButton();
//		createGiftButton();
//
//		profileInfoContainer.y = 75;
//		addChild(profileInfoContainer);
//
//		createProfileDetails();
//		createAchievementsPanel();
//		createProfileAvatar();
//		createFansBlock();
//		createPresents();
//	}
//
//	//
//	private function createPresents():void
//	{
//		shelf.x = 60;
//		shelf.y = 455;
//		profileInfoContainer.addChild(shelf);
//		presentsContainer.removeChildren(true, true);
//		if(!contains(presentsContainer)){
//			presentsContainer.x = shelf.x;
//			presentsContainer.y = shelf.y + 25;
//			profileInfoContainer.addChild(presentsContainer);
//		}
//		for (var i:int = 0; i < _user.presents.length; i++)
//		{
//			var present:Present = new Present(_user.presents[i]);
//			present.addEventListener(Present.PRESENT_LOADED, onPresentLoaded);
//			presentsContainer.addChildWithDimensions(present);
//		}
//	}
//
//	private function onPresentLoaded(e:Event):void
//	{
//		presentsContainer.position();
//		for (var i:int = 0; i < presentsContainer.numChildren; i++)
//			presentsContainer.getChildAt(i).y -= presentsContainer.getChildAt(i).height;
//	}
//
//	private function createProfileAvatar():void
//	{
//		zodiacSign.x = 215;
//		zodiacSign.y = 195;
//		profileInfoContainer.addChild(zodiacSign);
//		zodiacSign.gotoAndStop(_user.zodiac);
//
//		profileAvatar.x = 56;
//		profileAvatar.y = 133;
//		profileAvatar.frame = _user.avatarFrame;
//		profileAvatar.sex = _user.sex;
//		profileAvatar.isVIP = _user.vipPoints;
//		profileInfoContainer.addChild(profileAvatar);
//
//		var avatarLoad:ImageLoad = new ImageLoad(_user.photoLink);
//		avatarLoad.addEventListener(LoadEvent.COMPLETE, function(e:LoadEvent){
//			profileAvatar.photo = avatarLoad.contentAsBitmap;
//		});
//		avatarLoad.start();
//
//	}
//
//	private function createAchievementsPanel():void
//	{
//		achievementsPanel.x = 250;
//		achievementsPanel.y = 270;
//		achievementsPanel.giftsText.text = _user.presents.length.toString();
//		achievementsPanel.medalsText.text = _user.tasksDone.toString();
//		achievementsPanel.ratingText.text = _user.placeInRating.toString();
//		profileInfoContainer.addChild(achievementsPanel);
//	}
//
//	private function createProfileDetails():void
//	{
//		profileDetails.x = 312;
//		profileDetails.y = 133;
//		profileInfoContainer.addChild(profileDetails);
//
//		profileDetails.sexIndicator.gotoAndStop(_user.sex);
//		profileDetails.nameText.text = _user.name;
//		profileDetails.ageText.text = _user.birthDate;
//		profileDetails.cityText.text = _user.city;
//		profileDetails.playInCityCheckBox.gotoAndStop(1);
//		profileDetails.hideAgeButton.gotoAndStop(1);
//		profileDetails.hideCityButton.gotoAndStop(1);
//	}
//
//	private function createFansBlock():void
//	{
//		fans.x = 532;
//		fans.y = 113;
//		profileInfoContainer.addChild(fans);
//	}
//
//	//
//
//	private function createBecameFanButton():void
//	{
//		var becomeFanButton:BecameFunButton = new BecameFunButton();
//		becomeFanButton.x = profileMask.x + (profileMask.width - becomeFanButton.width) / 2;
//		becomeFanButton.y = profileMask.y;
//		becomeFanButton.addEventListener(MouseEvent.CLICK, onBecameFan);
//		addChild(becomeFanButton);
//	}
//
//	private function createGiftButton():void
//	{
//		var sendGiftButton:SendGiftButton = new SendGiftButton();
//		sendGiftButton.y = profileMask.y + profileMask.height - sendGiftButton.height - 35;
//		sendGiftButton.x = 240;
//		sendGiftButton.addEventListener(MouseEvent.CLICK, onSendGift);
//		addChild(sendGiftButton);
//	}
//
//	private function createCloseButton():void
//	{
//		var closeButton:CloseButton = new CloseButton();
//		closeButton.x = profileMask.x + profileMask.width - 30;
//		closeButton.y = profileMask.y + 35;
//		addChild(closeButton);
//		closeButton.addEventListener(MouseEvent.CLICK, onClose);
//	}
//
//	private function createCorners():void
//	{
//		var corners:Corners = new Corners();
//		corners.x = profileMask.x - 3;
//		corners.y = profileMask.y + profileMask.height - corners.height + 4;
//		corners.mouseEnabled = corners.mouseChildren = false;
//		addChild(corners);
//	}
//
//	private function createMask():void
//	{
//		bg.setBackground(_user.profileBackground);
//		addChild(bg);
//		addChild(profileMask);
//		centerX(profileMask, 760);
//		profileMask.y = 100;
//		bg.mask = profileMask;
//	}
//
//	private function onBecameFan(e:MouseEvent):void
//	{
//		trace("so fan!");
//	}
//
//	private function onClose(e:MouseEvent):void
//	{
//		trace("soClose!");
//	}
//
//	private function onSendGift(e:MouseEvent):void
//	{
//		trace("so send!");
//	}
//}
//}
