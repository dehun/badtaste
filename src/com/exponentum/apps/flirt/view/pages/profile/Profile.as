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
import com.exponentum.apps.flirt.view.common.DialogWindow;
import com.exponentum.apps.flirt.view.common.InfoWindow;
import com.exponentum.apps.flirt.view.controlls.Align;
import com.exponentum.apps.flirt.view.controlls.preloader.BlockerPreloader;
import com.exponentum.apps.flirt.view.pages.*;
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.pages.profile.presents.Present;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.display.TriangleCulling;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.ui.Keyboard;

import org.casalib.events.LoadEvent;
import org.casalib.layout.Distribution;
import org.casalib.load.ImageLoad;
import org.casalib.ui.Key;

import ru.cleptoman.net.UnsecurityDisplayLoader;

public class Profile extends BackGroundedPage
{
	private var tasksButton:SimpleButton = new TasksButton();
	private var ratingsButton:RatingsButton = new RatingsButton();
	private var zodiacSign:ZodiacSign;
	private var shelf:Shelf = new Shelf();
	private var achievementsPanel:AchievementsPanel = new AchievementsPanel();
	private var playButton:PlayButton = new PlayButton();

	private var profileDetails:ProfileDetails;
	private var profileAvatar:ProfileAvatar;
	private var fans:Fans;
	private var _bottomPanel:BottomPanel;

	private var presentsContainer:Distribution;
	private var user:User;

	private var bp:BlockerPreloader;

	public function Profile()
	{
		Model.instance.addEventListener(Controller.GOT_USER_INFO, onGotUserInfo);
		Controller.instance.getUserInfo(Model.instance.owner.guid);

		createView();
	}

	private function onGotUserInfo(e:ObjectEvent):void
	{
		user = e.data as User;
		if(user.guid != Model.instance.owner.guid) return;

		//zodiac
		zodiacSign.gotoAndStop(user.zodiac);

		//details
		updateProfileDetailsButtons();

		profileDetails.sexIndicator.gotoAndStop(user.sex + 1);
		profileDetails.nameText.text = user.name;
		var i:int = 0;
		while (profileDetails.nameText.textWidth > 120) {
			profileDetails.nameText.text = user.name.substr(0, profileDetails.nameText.text.length - i) + "...";
			i++;
		}
		profileDetails.ageText.text = user.birthDate;
		profileDetails.cityText.text = (user.city == "hidden")?"Скрыто":user.city;
		profileDetails.playInCityCheckBox.gotoAndStop(int(Model.instance.owner.playInCity) + 1);

		profileDetails.nameText.addEventListener(FocusEvent.FOCUS_IN, onNameTFFocusIn);
		profileDetails.nameText.addEventListener(FocusEvent.FOCUS_OUT, onNameTFFocusOut);

		var req:URLRequest = new URLRequest(user.photoLinkMedium);
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void{
			profileAvatar.photo = loader;
		});
		loader.load(req);

		configureListeners();

		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onGotUserInfo);

		Controller.instance.getDecorationFor(user.guid);
		Controller.instance.getVipPoints(Model.instance.owner.guid);
		trace("--------------------------------------------------------");
		Controller.instance.getUserFollowers(user.guid);
		Controller.instance.getMyGifts();
		Controller.instance.getUserRate(user.guid);
		Controller.instance.getUserCompletedJobs(user.guid);

		bp.partsLoaded++;
	}

	private function onNameTFFocusIn(e:FocusEvent):void
	{
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	private function onNameTFFocusOut(e:FocusEvent):void
	{
		this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	private function onKeyDown(e:KeyboardEvent):void
	{
		if(e.keyCode == Keyboard.ENTER)
		{
			this.stage.focus = null;
			Controller.instance.touchUserInfoByUser({
				name:profileDetails.nameText.text,
				hideSocialInfo:"0",
				hideBirthDate:user.isAgeHidden.toString(),
				hideCity:user.isCityHidden.toString()
			});
		}
	}

	private function createView():void
	{
		playButton.x = 231;
		playButton.y = -4;
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
			profileDetails.y = 133;
			addChild(profileDetails);

			profileDetails.hideAgeButton.buttonMode = profileDetails.hideAgeButton.useHandCursor = true;
			profileDetails.hideCityButton.buttonMode = profileDetails.hideCityButton.useHandCursor = true;
			profileDetails.playInCityCheckBox.buttonMode = profileDetails.playInCityCheckBox.useHandCursor = true;
			profileDetails.playInCityCheckBox.addEventListener(MouseEvent.CLICK, onPlayInCityClick);
			profileDetails.hideAgeButton.gotoAndStop(1);
			profileDetails.hideCityButton.gotoAndStop(1);
			profileDetails.playInCityCheckBox.gotoAndStop(1);
			profileDetails.sexIndicator.gotoAndStop(1);
		}

		if(!profileAvatar)
		{
			profileAvatar = new ProfileAvatar();
			profileAvatar.x = 56;
			profileAvatar.y = 133;
			addChild(profileAvatar);
		}

		if(achievementsPanel)
		{
			achievementsPanel = new AchievementsPanel();
			achievementsPanel.x = 250;
			achievementsPanel.y = 270;
			addChild(achievementsPanel);
			achievementsPanel.giftsText.text = "0";
			achievementsPanel.ratingText.text = "0";
			achievementsPanel.medalsText.text = "0";
		}

		if(!_bottomPanel)
		{
			_bottomPanel = new BottomPanel();
			_bottomPanel.x = -5;
			_bottomPanel.y = 548;
			_bottomPanel.width+=5;
			addChild(_bottomPanel);
		}

		if(!fans)
		{
			fans = new Fans();
			fans.x = 532;
			fans.y = 113;
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
		
		bp = new BlockerPreloader(this, this.width, this.height, .4);
		bp.preload(8);

		createBankIndicator();
	}

	private var becameVIPButton:BecameVIPButton = new BecameVIPButton();
	private function createBecameVip():void
	{
		if(Model.instance.owner.vipPoints == 0){
			becameVIPButton.x = 85;
			becameVIPButton.y = 53;
			addChild(becameVIPButton);
			becameVIPButton.addEventListener(MouseEvent.CLICK, onBecameVIP);
		}
	}

	private function onBecameVIP(e:MouseEvent):void
	{
		bp = new BlockerPreloader(this, this.width, this.height);
		Model.instance.view.showDialogWindow(new DialogWindow("Вы уверенны что хотите купить статус VIP? С вашего счета будут списаны монеты", "Внимание!", "Да", "Нет", function():void{
			Model.instance.addEventListener(Controller.ON_VIP_POINTS_BUY_SUCCESS, onBecameVIPSuccess);
			Model.instance.addEventListener(Controller.ON_VIP_POINTS_BUY_FAIL, onBecameVIPFail);
			Controller.instance.buyVIPPoints();
			bp.preload(1);
		}));

	}

	private function onBecameVIPSuccess(e:ObjectEvent):void
	{
		Model.instance.view.showInfoWindow(new InfoWindow("Вы успешно приобрели статус VIP", "Успех!"));
		Model.instance.removeEventListener(Controller.ON_VIP_POINTS_BUY_SUCCESS, onBecameVIPSuccess);
		Model.instance.removeEventListener(Controller.ON_VIP_POINTS_BUY_FAIL, onBecameVIPFail);
		bp.partsLoaded++;
		becameVIPButton.visible = false;
	}

	private function onBecameVIPFail(e:ObjectEvent):void
	{
		Model.instance.view.showInfoWindow(new InfoWindow("Произошла ошибка. Попробуйте позже", "Ошибка!"));
		Model.instance.removeEventListener(Controller.ON_VIP_POINTS_BUY_SUCCESS, onBecameVIPSuccess);
		Model.instance.removeEventListener(Controller.ON_VIP_POINTS_BUY_FAIL, onBecameVIPFail);
		bp.partsLoaded++;
	}

	private var bankIndicator:BankIndicatorAsset = new BankIndicatorAsset();
	private function createBankIndicator():void
	{
		bankIndicator.x = 536;
		bankIndicator.y = 31;
		addChild(bankIndicator);

		bankIndicator.moeyTF.text = Model.instance.owner.coins.toString();

		Model.instance.addEventListener(Controller.ON_BANK_BALANCE_CHANGED, onBankBalanceChanged);
		Model.instance.addEventListener(Controller.ON_BANK_BALANCE_CHECKED, onBankBalanceChecked);
		bankIndicator.addMoneyButton.addEventListener(MouseEvent.CLICK, onAddMoneyClick);
		Controller.instance.checkBankBalance();
	}

	private function onAddMoneyClick(e:MouseEvent):void
	{
		Model.instance.view.showShop(Model.instance.owner.guid, true);
	}

	private function onBankBalanceChecked(e:ObjectEvent):void
	{
		bankIndicator.moeyTF.text = e.data.gold;
		bp.partsLoaded++;
	}

	private function onBankBalanceChanged(e:ObjectEvent):void
	{
		bankIndicator.moeyTF.text = e.data.newGold;
	}

	private function configureListeners():void
	{
		Model.instance.addEventListener(Controller.ON_GOT_VIP_POINTS, onGotVipPoints);
		Model.instance.addEventListener(Controller.ON_GOT_DECORATIONS, onGotDecorations);
		Model.instance.addEventListener(Controller.ON_GOT_USER_FOLLOWERS, onGotUserFollowers);
		Model.instance.addEventListener(Controller.ON_GOT_MY_GIFTS, onGotMyGifts);
		Model.instance.addEventListener(Controller.ON_GOT_USER_RATE, onGotUserRate);
		Model.instance.addEventListener(Controller.ON_GOT_USER_COMPLETED_JOBS, onGotUserCompletedJobs);
	}

	private function updateProfileDetailsButtons():void
	{
		Controller.instance.touchUserInfoByUser({
			name:user.name,
			hideSocialInfo:"0",
			hideBirthDate:user.isAgeHidden.toString(),
			hideCity:user.isCityHidden.toString()
		});
		
		profileDetails.hideAgeButton.gotoAndStop(int(user.isAgeHidden) + 1);
		profileDetails.hideCityButton.gotoAndStop(int(user.isCityHidden) + 1);

		if(!profileDetails.hideAgeButton.hasEventListener(MouseEvent.CLICK))
			profileDetails.hideAgeButton.addEventListener(MouseEvent.CLICK, onHideAgeClick);
		if(!profileDetails.hideCityButton.hasEventListener(MouseEvent.CLICK))
			profileDetails.hideCityButton.addEventListener(MouseEvent.CLICK, onHideCityClick);
	}

	private function onHideAgeClick(e:MouseEvent):void
	{
		user.isAgeHidden = !user.isAgeHidden;
		updateProfileDetailsButtons();
	}

	private function onHideCityClick(e:MouseEvent):void
	{
		user.isCityHidden = !user.isCityHidden;
		updateProfileDetailsButtons();
	}

	private function onPlayInCityClick(e:MouseEvent):void
	{
		Model.instance.owner.playInCity = !Model.instance.owner.playInCity;
		profileDetails.playInCityCheckBox.gotoAndStop(int(Model.instance.owner.playInCity) + 1);
	}

	private function onGotVipPoints(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if((e.data as User).guid != Model.instance.owner.guid) return;

		profileAvatar.isVIP = user.vipPoints > 0;
		if(user.vipPoints == 0) createBecameVip();
		bp.partsLoaded++;
	}

	private function onGotDecorations(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if((e.data as User).guid != Model.instance.owner.guid) return;

		setBackground(user.profileBackground);
		profileAvatar.frame = user.avatarFrame;
		bp.partsLoaded++;
	}

	private function onGotUserFollowers(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if((e.data as User).guid != Model.instance.owner.guid) return;

		fans.update(user.followers);
		bp.partsLoaded++;
	}

	private function onGotMyGifts(e:Event):void
	{

		const presentsShown:int = 6;
		presentsContainer.removeChildren(true, true);
		for (var i:int = 0; i < Math.min(user.presents.length, presentsShown); i++)
		{
			var present:Present = new Present(user.presents[i], Model.instance.owner);
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

		achievementsPanel.giftsText.text = user.presents.length.toString();
//		achievementsPanel.ratingText.text = user.placeInRating.toString();
		//bp.partsLoaded++;
	}

	private function onGotUserCompletedJobs(e:ObjectEvent):void
	{
		if(e.data.ownerGuid == Model.instance.owner.guid)
		{
			Model.instance.owner.jobsCompleted = (e.data.completedJobs as Array);
			achievementsPanel.medalsText.text = (e.data.completedJobs as Array).length.toString();
		}

		bp.partsLoaded++;
	}

	private function onGotUserRate(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if((e.data as User).guid != Model.instance.owner.guid) return;

		profileAvatar.mark = user.userRate
		profileAvatar.isRated = true;
		bp.partsLoaded++;
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
		if(this.stage) this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		profileDetails.nameText.removeEventListener(FocusEvent.FOCUS_IN, onNameTFFocusIn);
		profileDetails.nameText.removeEventListener(FocusEvent.FOCUS_OUT, onNameTFFocusOut);

		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onGotUserInfo);
		Model.instance.removeEventListener(Controller.ON_GOT_VIP_POINTS, onGotVipPoints);
		Model.instance.removeEventListener(Controller.ON_GOT_DECORATIONS, onGotDecorations);
		Model.instance.removeEventListener(Controller.ON_GOT_USER_FOLLOWERS, onGotUserFollowers);
		Model.instance.removeEventListener(Controller.ON_GOT_MY_GIFTS, onGotMyGifts);
		Model.instance.removeEventListener(Controller.ON_GOT_USER_RATE, onGotUserRate);
		Model.instance.removeEventListener(Controller.ON_GOT_USER_COMPLETED_JOBS, onGotUserCompletedJobs);

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
