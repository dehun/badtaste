package com.exponentum.apps.flirt.view
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.controller.net.ServerConnector;
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;
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

	private var foreground:ForegroundProfile = new ForegroundProfile();

	public function View(aModel:Model, aController:Controller)
	{
		model = aModel;
		model.view = this;
		controller = aController;

		addChild(pageContainer);
		foreground.x = -10;
		foreground.y = -10;
		addChild(foreground);
		foreground.mouseChildren = foreground.mouseEnabled = false;
		
		model.addEventListener(User.USER_INFO_UPDATED, onUserInfoUpdated);
	}

	private function onUserInfoUpdated(e:Event):void
	{
		if(profile) profile.update();
	}

	private function showPage(pageId:String):void
	{
		switch(pageId)
		{
			case Config.GAMEFIELD:
					showGameField();
				break;
			case Config.PROFILE:
					showOwnerProfile();
				break;
			case Config.TASKS:
					showTasks();
				break;
			case Config.RATINGS:
					showRatings();
				break;
		}
	}

//----------------------------------------------------------------------------------------------------------------------
// USER PROFILE
//----------------------------------------------------------------------------------------------------------------------
	public function showOwnerProfile(e:Event = null):void
	{
		onUserInfoCollected();
	}

	private function onUserInfoCollected(e:Event = null):void
	{
		pageContainer.removeChildren(true, true);
		profile = new Profile(model.owner, controller);
		profile.addEventListener(Config.GAMEFIELD, showGameField);
		profile.addEventListener(Config.TASKS, showTasks);
		profile.addEventListener(Config.RATINGS, showRatings);
		pageContainer.addChild(profile);
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

		gameField.addPlayerToTable(model.owner, 0);
		gameField.addPlayerToTable(model.owner, 3);
		gameField.addPlayerToTable(model.owner, 4);
		gameField.addPlayerToTable(model.owner, 7);

		pageContainer.addChild(gameField);
	}

	public function showRatings(e:Event = null):void
	{
		pageContainer.removeChildren(true, true);
		ratings = new RatingsPage();
		ratings.addEventListener(Config.PROFILE, showOwnerProfile);
		pageContainer.addChild(ratings);
	}

	public function showTasks(e:Event = null):void
	{
		prizeTasks = new PrizeTasksWindow();
		prizeTasks.x = 0;
		prizeTasks.y = 300;
		pageContainer.addChild(prizeTasks);
	}

	public function showShop(e:Event = null):void
	{
		shop = new ShopPage();
		centerX(shop, 760);
		centerY(shop, 760);
		pageContainer.addChild(shop);
	}

	public function showMiniProfile(e:Event = null):void
	{
		miniProfile = new MiniProfile(model.owner);
//		centerX(miniProfile, 760);
//		centerY(miniProfile, 760);
		pageContainer.addChild(miniProfile);
	}

	public function showMessageWindow(message:Object):void
	{
		var messageWindow:MessageWindow = new MessageWindow(message);
		messageWindow.x = messageWindow.y = 760 / 2;
		pageContainer.addChild(messageWindow);

	}
}
}