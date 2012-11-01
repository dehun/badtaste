package com.exponentum.apps.flirt.view
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.controller.net.ServerConnector;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.common.DialogWindow;
import com.exponentum.apps.flirt.view.common.InfoWindow;
import com.exponentum.apps.flirt.view.pages.gifts.GiftsPage;
import com.exponentum.apps.flirt.view.pages.miniprofile.MiniProfile;
import com.exponentum.apps.flirt.view.pages.gamefield.GameField;
import com.exponentum.apps.flirt.view.pages.profile.Profile;
import com.exponentum.apps.flirt.view.pages.profile.messages.MessageWindow;
import com.exponentum.apps.flirt.view.pages.shop.ShopPage;
import com.exponentum.apps.flirt.view.pages.prizetasks.PrizeTasksWindow;
import com.exponentum.apps.flirt.view.pages.ratings.RatingsPage;
import com.exponentum.utils.centerX;
import com.exponentum.utils.centerY;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

import mx.utils.NameUtil;

import org.casalib.display.CasaSprite;

public class View extends Sprite
{
	private var model:Model;
	private var controller:Controller;

	private var pageContainer:CasaSprite = new CasaSprite();
	//pages
	private var profile:Profile;
	private var gameField:GameField;
	private var prizeTasks:PrizeTasksWindow;
	private var ratings:RatingsPage;
	private var shop:ShopPage;
	private var miniProfile:MiniProfile;
	private var giftsWindow:GiftsPage;

	private var foreground:ForegroundProfile = new ForegroundProfile();

	public function View(aModel:Model, aController:Controller)
	{
		model = aModel;
		model.view = this;
		controller = aController;

		Model.instance.addEventListener(Controller.ON_GOT_MAILBOX, onMailBox);
		Model.instance.addEventListener(Controller.ON_GOT_NEW_MAIL, onGotNewMail);

		createForeground();
	}

	private function onGotNewMail(e:ObjectEvent):void
	{
		controller.checkMailbox();
	}

	private function createForeground():void
	{
		addChild(pageContainer);
		foreground.x = -10;
		foreground.y = -10;
		addChild(foreground);
		foreground.mouseChildren = foreground.mouseEnabled = false;
	}

//----------------------------------------------------------------------------------------------------------------------
// USER PROFILE
//----------------------------------------------------------------------------------------------------------------------
	public function showOwnerProfile(e:Event = null):void
	{
		pageContainer.removeChildren(true, true);
		profile = new Profile();
		profile.addEventListener(Config.GAMEFIELD, showGameField);
		profile.addEventListener(Config.TASKS, showTasks);
		profile.addEventListener(Config.RATINGS, showRatings);
		pageContainer.addChild(profile);
		_mailNotifier = new mailNotifier();
		pageContainer.addChild(_mailNotifier);
		_mailNotifier.x = 420;
		_mailNotifier.y = 540;
		_mailNotifier.visible = false;
		controller.checkMailbox();
	}
//----------------------------------------------------------------------------------------------------------------------
// USER PROFILE
//----------------------------------------------------------------------------------------------------------------------

	public function showGameField(e:Event = null):void
	{
		pageContainer.removeChildren(true, true);
		gameField = new GameField();
		gameField.addEventListener(Config.PROFILE, showOwnerProfile);
		gameField.addEventListener(Config.RATINGS, showRatings);

		if(miniProfile) miniProfile.destroy();

		pageContainer.addChild(gameField);
	}

	public function showRatings(e:Event = null):void
	{
		pageContainer.removeChildren(true, true);
		ratings = new RatingsPage();
		if(!e || e.currentTarget is Profile) ratings.fromLocation = Config.PROFILE;
		if(e && e.currentTarget is GameField) ratings.fromLocation = Config.GAMEFIELD;
		ratings.addEventListener(Config.PROFILE, showOwnerProfile);
		ratings.addEventListener(Config.GAMEFIELD, showGameField);
		pageContainer.addChild(ratings);
	}

	public function showTasks(e:Event = null):void
	{
		if(prizeTasks) return;
		prizeTasks = new PrizeTasksWindow();
		prizeTasks.x = 0;
		prizeTasks.y = 300;
		pageContainer.addChild(prizeTasks);
	}

	public function showShop(userGuid:String, bankMode:Boolean = false):void
	{
		//if(shop) return;
		shop = new ShopPage(userGuid, bankMode);
		shop.x = 50;
		shop.y = 140;
//		centerX(shop, 760);
//		centerY(shop, 760);
		pageContainer.addChild(shop);
	}

	public function showMiniProfile(targetUser:User):void
	{
		if(miniProfile != null) miniProfile.destroy();
		miniProfile = new MiniProfile(targetUser);
		addChild(miniProfile);
	}

	public function showGiftsWindow(targetUser:User):void
	{
		if(giftsWindow)return;
		giftsWindow = new GiftsPage(targetUser);
		addChild(giftsWindow);
	}

	public function showMessageWindow(message:Object, sender:User, receiver:User):void
	{
		var messageWindow:MessageWindow = new MessageWindow(message, sender, receiver);
		messageWindow.x = messageWindow.y = 760 / 2;
		pageContainer.addChild(messageWindow);
	}

	public function showInfoWindow(window:InfoWindow):void
	{
		addChildAt(window, this.numChildren);
	}

	public function showDialogWindow(window:DialogWindow):void
	{
		addChildAt(window, this.numChildren);
	}

//----------------------------------------------------------------------------------------------------------------------
// MAIL NOTIFICATIONS
//----------------------------------------------------------------------------------------------------------------------
	private function onMailBox(e:Event):void
	{
		var numUnread:int = 0;
		for each (var object:Object in model.mailbox)
		{
			if(object.Mail.isRead == "false" && object.Mail.senderGuid != Model.instance.owner.guid) numUnread++;
		}
		alertMailNotification(numUnread);
	}
	
	private var _mailNotifier:mailNotifier;
	public function alertMailNotification(numUnreadMessages:int):void
	{
		if(!_mailNotifier) return;
		_mailNotifier.visible = numUnreadMessages > 0;
		_mailNotifier.tf.text = numUnreadMessages.toString();
		_mailNotifier.mouseChildren = _mailNotifier.mouseEnabled = false;
	}
}
}