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

import flash.display.Bitmap;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;

import org.casalib.events.LoadEvent;
import org.casalib.layout.Distribution;
import org.casalib.load.ImageLoad;

import ru.cleptoman.net.UnsecurityDisplayLoader;

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

	private var presentsContainer:Distribution = new Distribution();

	private var becomeFanButton:BecameFunButton;

	private var _user:User;

	public function MiniProfile(user:User)
	{
		_user = user;

		Model.instance.addEventListener(Controller.GOT_USER_INFO, onGotUserInfo);
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
		Model.instance.addEventListener(Controller.ON_GOT_VIP_POINTS, onGotVipPoints);
		Model.instance.addEventListener(Controller.ON_GOT_DECORATIONS, onGotDecorations);
		Model.instance.addEventListener(Controller.ON_GOT_USER_FOLLOWERS, onGotUserFollowers);
		Model.instance.addEventListener(Controller.ON_GOT_USER_GIFTS, onGotUserGifts);
		Model.instance.addEventListener(Controller.ON_GOT_USER_RATE, onGotUserRate);
		Model.instance.addEventListener(Controller.ON_GOT_IS_USER_RATED, onGotIsUserRated);
	}

	private function onGotUserInfo(e:ObjectEvent):void
	{
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
			profileDetails.y = 180;
			addChild(profileDetails);
		}

		profileDetails.hideAgeButton.visible = false;
		profileDetails.hideCityButton.visible = false;

		profileDetails.sexIndicator.gotoAndStop(_user.sex);
		profileDetails.nameText.text = _user.name;
		profileDetails.ageText.text = _user.birthDate;
		profileDetails.cityText.text = _user.city;

		profileDetails.playInCityCheckBox.visible = false;
		profileDetails.playInYourCityText.visible = false;

		if(!profileAvatar)
		{
			profileAvatar = new ProfileAvatar();
			profileAvatar.x = 56;
			profileAvatar.y = 133;
			profileAvatar.frame = 1;
			profileAvatar.sex = _user.sex;
			profileAvatar.isVIP = false;
			profileAvatar.user = _user;
			addChild(profileAvatar);

			var loader:UnsecurityDisplayLoader = new UnsecurityDisplayLoader();
			loader.addEventListener(Event.INIT, function(e:Event):void {
				var loader:UnsecurityDisplayLoader = e.target as UnsecurityDisplayLoader;
				profileAvatar.photo = (new Bitmap((loader.content as Bitmap).bitmapData));
			});
			var req:URLRequest		= new URLRequest(_user.photoLink);
			loader.load(req);
		}

		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onGotUserInfo);

		configureListeners();

		Controller.instance.getDecorationFor(_user.guid);
		Controller.instance.getVipPoints(_user.guid);
		Controller.instance.getUserFollowers(_user.guid);
		Controller.instance.getUserGifts(_user.guid);
		Controller.instance.getUserRate(_user.guid);
		Controller.instance.isUserRated(_user.guid);

		//TODO: coins, city checkbox, link to social

		if(!contains(achievementsPanel)){
			achievementsPanel.x = 250;
			achievementsPanel.y = 290;
			addChild(achievementsPanel);
		}
	}

	private function onGotVipPoints(e:ObjectEvent):void
	{
		profileAvatar.isVIP = _user.vipPoints > 0;
	}

	private function onGotDecorations(e:ObjectEvent):void
	{
		profileAvatar.frame = _user.avatarFrame;
		setBackground(_user.profileBackground);
	}

	private function onGotUserFollowers(e:ObjectEvent):void
	{
		if(_user.followers.length == 0) return;

		if(!fans)
		{
			fans = new Fans();
			fans.x = 532;
			fans.y = 133;
			addChild(fans);
		}
		fans.update(_user.followers);

		becomeFanButton.price.text = _user.rebuyPrice.toString();
		becomeFanButton.visible = true;
	}

	private function onGotUserGifts(e:Event):void
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
			var present:Present = new Present(_user.presents[i], _user);
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
		profileAvatar.mark = _user.userRate;
	}

	private function onGotIsUserRated(e:ObjectEvent):void
	{
		profileAvatar.isRated = _user.isRated == "true";
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
		Model.instance.removeEventListener(Controller.ON_GOT_USER_GIFTS, onGotUserGifts)
		Model.instance.removeEventListener(Controller.ON_GOT_USER_RATE, onGotUserRate);
		Model.instance.removeEventListener(Controller.ON_GOT_IS_USER_RATED, onGotIsUserRated);

		removeChildren();
		ratingsButton = null;
		zodiacSign = null;
		shelf = null;
		achievementsPanel = null;
		playButton = null;

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
		setBackground(_user.profileBackground);
		addChild(profileMask);
		centerX(profileMask, 760);
		profileMask.y = 100;
		background.mask = profileMask;
	}

	private function onBecameFan(e:MouseEvent):void
	{
		trace("so fan!");
	}

	private function onClose(e:MouseEvent):void
	{
		destroy();
	}

	private function onSendGift(e:MouseEvent):void
	{
		trace("so send!");
	}
}
}