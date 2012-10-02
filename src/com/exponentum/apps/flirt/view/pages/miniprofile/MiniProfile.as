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
import com.exponentum.apps.flirt.view.controlls.preloader.BlockerPreloader;
import com.exponentum.apps.flirt.view.pages.*;
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.pages.profile.BottomPanel;
import com.exponentum.apps.flirt.view.pages.profile.Fans;
import com.exponentum.apps.flirt.view.pages.profile.ProfileAvatar;
import com.exponentum.apps.flirt.view.pages.profile.presents.Present;
import com.exponentum.utils.centerX;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;

import org.casalib.events.LoadEvent;
import org.casalib.layout.Distribution;
import org.casalib.load.ImageLoad;

import ru.cleptoman.net.UnsecurityDisplayLoader;

import flash.filters.DropShadowFilter;

public class MiniProfile extends BackGroundedPage
{
	private var zodiacSign:ZodiacSign;
	private var shelf:Shelf = new Shelf();
	private var achievementsPanel:AchievementsPanel;

	private var profileDetails:ProfileDetails;
	private var profileAvatar:ProfileAvatar;
	private var fans:Fans;

	private var presentsContainer:Distribution;

	private var becomeFanButton:BecameFunButton;

	private var sidePanel:SidePanel = new SidePanel();

	private var _user:User;

	private var bp:BlockerPreloader;

	public function MiniProfile(user:User)
	{
		_user = user;

		Model.instance.addEventListener(Controller.GOT_USER_INFO, onGotUserInfo);
		Controller.instance.getUserInfo(_user.guid);

		createView();
		this.filters = [new DropShadowFilter(0, 45, 0x0, 1, 30, 30, 1, 3)];
	}

	private function createView():void
	{
		createMask();
		createCloseButton();
		createCorners();

		if(!zodiacSign)
		{
			zodiacSign = new ZodiacSign();
			zodiacSign.x = 215;
			zodiacSign.y = 195;
			addChild(zodiacSign);
			zodiacSign.gotoAndStop(1);
		}

		if(!profileDetails)
		{
			profileDetails = new ProfileDetails();
			profileDetails.x = 312;
			profileDetails.y = 183;
			addChild(profileDetails);

			profileDetails.hideAgeButton.buttonMode = profileDetails.hideAgeButton.useHandCursor = true;
			profileDetails.hideCityButton.buttonMode = profileDetails.hideCityButton.useHandCursor = true;
			profileDetails.playInCityCheckBox.buttonMode = profileDetails.playInCityCheckBox.useHandCursor = true;
			profileDetails.hideAgeButton.gotoAndStop(1);
			profileDetails.hideCityButton.gotoAndStop(1);
			profileDetails.playInCityCheckBox.gotoAndStop(1);
			profileDetails.sexIndicator.gotoAndStop(1);

			profileDetails.hideAgeButton.visible = false;
			profileDetails.hideCityButton.visible = false;
			profileDetails.playInCityCheckBox.visible = false;
			profileDetails.playInYourCityText.visible = false;

		}

		if(!profileAvatar)
		{
			profileAvatar = new ProfileAvatar();
			profileAvatar.x = 56;
			profileAvatar.y = 133;
			addChild(profileAvatar);
		}

		if(!achievementsPanel)
		{
			achievementsPanel = new AchievementsPanel();
			achievementsPanel.x = 250;
			achievementsPanel.y = 290;
			addChild(achievementsPanel);
			achievementsPanel.giftsText.text = "0";
			achievementsPanel.ratingText.text = "0";
			achievementsPanel.medalsText.text = "0";
		}

		if(!fans)
		{
			fans = new Fans();
			fans.x = 532;
			fans.y = 133;
			addChild(fans);
		}

		if(!presentsContainer)
		{
			shelf.x = 60;
			shelf.y = 455;
			addChild(shelf);

			presentsContainer = new Distribution();
			presentsContainer.x = shelf.x;
			presentsContainer.y = shelf.y + 25;
			addChild(presentsContainer);
		}

		var sendGiftButton:SendGiftButton = new SendGiftButton();
		sendGiftButton.y = profileMask.y + profileMask.height - sendGiftButton.height - 35;
		sendGiftButton.x = 180;
		sendGiftButton.addEventListener(MouseEvent.CLICK, onSendGift);
		addChild(sendGiftButton);

		sidePanel.x = 465;
		sidePanel.y = sendGiftButton.y + 5;
		addChild(sidePanel);
		sidePanel.sendMailButton.addEventListener(MouseEvent.CLICK, onShowSendMailWindow);

		bp = new BlockerPreloader(this, profileMask.width, profileMask.height, .3);
		bp.x = profileMask.x;
		bp.y = profileMask.y;
		bp.preload(7);

		createBecameFanButton();
	}

	private function onShowSendMailWindow(e:MouseEvent):void
	{
		Model.instance.view.showMessageWindow(null, _user);
		this.destroy();
	}

	private function configureListeners():void
	{
		Model.instance.addEventListener(Controller.ON_GOT_VIP_POINTS, onGotVipPoints);
		Model.instance.addEventListener(Controller.ON_GOT_DECORATIONS, onGotDecorations);
		Model.instance.addEventListener(Controller.ON_GOT_USER_FOLLOWERS, onGotUserFollowers);
		Model.instance.addEventListener(Controller.ON_GOT_USER_GIFTS, onGotUserGifts);
		Model.instance.addEventListener(Controller.ON_GOT_USER_RATE, onGotUserRate);
		Model.instance.addEventListener(Controller.ON_GOT_IS_USER_RATED, onGotIsUserRated);
	}

	private function onGotUserInfo(e:ObjectEvent):void
	{
		var curUser:User = e.data as User;
		if(curUser.guid != _user.guid) return;
		//zodiac
		zodiacSign.gotoAndStop(_user.zodiac);

		//details
		profileDetails.sexIndicator.gotoAndStop(_user.sex + 1);
		profileDetails.nameText.text = _user.name;
		var i = 0;
		while (profileDetails.nameText.textWidth > 120) {
			profileDetails.nameText.text = _user.name.substr(0, profileDetails.nameText.text.length - i) + "...";
			i++;
		}
		profileDetails.ageText.text = "Скрыто";
		profileDetails.cityText.text = _user.city;

		profileAvatar.sex = _user.sex;
		profileAvatar.user = _user;

		var req:URLRequest = new URLRequest(_user.photoLinkMedium);
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void{
			profileAvatar.photo = loader;
		});
		loader.load(req);

		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onGotUserInfo);

		configureListeners();

		Controller.instance.getDecorationFor(_user.guid);
		Controller.instance.getVipPoints(_user.guid);
		Controller.instance.getUserGifts(_user.guid);
		Controller.instance.getUserRate(_user.guid);
		Controller.instance.isUserRated(_user.guid);
		Controller.instance.getUserCompletedJobs(_user.guid);
		Controller.instance.getUserFollowers(_user.guid);
		bp.partsLoaded++;

	}

	private function onGotVipPoints(e:ObjectEvent):void
	{
		var curUser:User = e.data as User;
		if(curUser.guid != _user.guid) return;
		profileAvatar.isVIP = _user.vipPoints > 0;
		bp.partsLoaded++;
	}

	private function onGotDecorations(e:ObjectEvent):void
	{
		var curUser:User = e.data as User;
		if(curUser.guid != _user.guid) return;
		profileAvatar.frame = _user.avatarFrame;
		setBackground(_user.profileBackground);
		bp.partsLoaded++;
	}

	private function onGotUserFollowers(e:ObjectEvent):void
	{
		bp.partsLoaded++;
		var curUser:User = e.data as User;
		if(curUser.guid != _user.guid) return;
		//if(_user.followers.length == 0) return;
		fans.update(_user.followers);
		becomeFanButton.price.text = _user.rebuyPrice.toString();
		becomeFanButton.visible = _user.sex != Model.instance.owner.sex;
		trace(_user.sex, Model.instance.owner.sex);
	}

	private function onGotUserGifts(e:Event):void
	{
		const presentsShown:int = 6;
		presentsContainer.removeChildren(true, true);
		for (var i:int = 0; i < Math.min(_user.presents.length, presentsShown); i++)
		{
			var present:Present = new Present(_user.presents[i], _user);
			present.addEventListener(Present.PRESENT_LOADED, onPresentLoaded);
			presentsContainer.addChildWithDimensions(present);
		}
		bp.partsLoaded++;
	}

	private function onPresentLoaded(e:Event):void
	{
		presentsContainer.position();
		for (var i:int = 0; i < presentsContainer.numChildren; i++)
			presentsContainer.getChildAt(i).y -= presentsContainer.getChildAt(i).height;

		achievementsPanel.giftsText.text = _user.presents.length.toString();
//		achievementsPanel.ratingText.text = _user.placeInRating.toString();
	}

	private function onGotUserCompletedJobs(e:ObjectEvent):void
	{
		if(e.data.ownerGuid == _user.guid)
			achievementsPanel.medalsText.text = (e.data.completedJobs as Array).length.toString();

		bp.partsLoaded++;
	}


	private function onGotUserRate(e:ObjectEvent):void
	{
		var curUser:User = e.data as User;
		if(curUser.guid != _user.guid) return;
		profileAvatar.mark = _user.userRate;
		bp.partsLoaded++;
	}

	private function onGotIsUserRated(e:ObjectEvent):void
	{
		var curUser:User = e.data as User;
		if(curUser.guid != _user.guid) return;
		profileAvatar.isRated = _user.isRated;
		bp.partsLoaded++;
	}

	override public function destroy():void
	{
		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onGotUserInfo);
		Model.instance.removeEventListener(Controller.ON_GOT_VIP_POINTS, onGotVipPoints);
		Model.instance.removeEventListener(Controller.ON_GOT_DECORATIONS, onGotDecorations);
		Model.instance.removeEventListener(Controller.ON_GOT_USER_FOLLOWERS, onGotUserFollowers);
		Model.instance.removeEventListener(Controller.ON_GOT_USER_GIFTS, onGotUserGifts)
		Model.instance.removeEventListener(Controller.ON_GOT_USER_RATE, onGotUserRate);
		Model.instance.removeEventListener(Controller.ON_GOT_IS_USER_RATED, onGotIsUserRated);
		Model.instance.removeEventListener(Controller.ON_GOT_USER_COMPLETED_JOBS, onGotUserCompletedJobs);

		removeChildren();
		zodiacSign = null;
		shelf = null;
		achievementsPanel = null;

		profileDetails = null;
		profileAvatar = null;
		fans = null;

		presentsContainer = null;
		super.destroy();
	}

	private var profileMask:ProfileMask = new ProfileMask();

	private function createBecameFanButton():void
	{
		becomeFanButton = new BecameFunButton();
		becomeFanButton.x = profileMask.x + (profileMask.width - becomeFanButton.width) / 2;
		becomeFanButton.y = profileMask.y;
		becomeFanButton.addEventListener(MouseEvent.CLICK, onBecameFan);
		addChild(becomeFanButton);
		becomeFanButton.visible = false;
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
		setBackground(_user.profileBackground);
		addChild(profileMask);
		centerX(profileMask, 760);
		profileMask.y = 100;
		background.mask = profileMask;
	}

	private function onBecameFan(e:MouseEvent):void
	{
		Model.instance.addEventListener(Controller.ON_FOLLOWING_BUY_SUCCESS, onFollowingBought);
		Controller.instance.buyFollowing(_user.guid);
	}

	private function onFollowingBought(e:ObjectEvent):void
	{
		Model.instance.removeEventListener(Controller.ON_FOLLOWING_BUY_SUCCESS, onFollowingBought);
		becomeFanButton.visible = false;
	}

	private function onClose(e:MouseEvent):void
	{
		destroy();
	}

	private function onSendGift(e:MouseEvent):void
	{
		Model.instance.view.showShop();
		this.destroy();
	}
}
}