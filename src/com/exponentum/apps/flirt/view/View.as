package com.exponentum.apps.flirt.view
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.controller.net.ServerConnector;
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.view.pages.gamefield.GameField;
import com.exponentum.apps.flirt.view.pages.profile.Profile;
import com.exponentum.apps.flirt.view.prizetasks.PrizeTasksWindow;
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

	private var foreground:ForegroundProfile = new ForegroundProfile();

	public function View(aModel:Model, aController:Controller)
	{
		model = aModel;
		controller = aController;

		addChild(pageContainer);
		foreground.x = -10;
		foreground.y = -10;
		addChild(foreground);
		foreground.mouseChildren = foreground.mouseEnabled = false;
	}

	private function showPage(pageId:String):void
	{
		switch(pageId)
		{
			case Config.GAMEFIELD:
					showGameField();
				break;
			case Config.PROFILE:
					showProfile();
				break;
			case Config.TASKS:
					showTasks();
				break;
			case Config.RATINGS:
					showRatings();
				break;
		}
	}

	public function showProfile(e:Event = null):void
	{
		pageContainer.removeChildren(true, true);
		profile = new Profile(model.owner);
		profile.addEventListener(Config.GAMEFIELD, showGameField);
		profile.addEventListener(Config.TASKS, showTasks);
		profile.addEventListener(Config.RATINGS, showRatings);
		pageContainer.addChild(profile);
	}

	public function showGameField(e:Event = null):void
	{
		pageContainer.removeChildren(true, true);
		gameField = new GameField();
		gameField.addEventListener(Config.PROFILE, showProfile);
		gameField.addEventListener(Config.RATINGS, showRatings);

		gameField.addPlayerToTable(model.owner, 0);
		gameField.addPlayerToTable(model.owner, 3);
		gameField.addPlayerToTable(model.owner, 4);
		gameField.addPlayerToTable(model.owner, 7);

		pageContainer.addChild(gameField);
	}

	private function showRatings(e:Event = null):void
	{

	}

	public function showTasks(e:Event = null):void
	{
		prizeTasks = new PrizeTasksWindow();
		centerX(prizeTasks, 760);
		centerY(prizeTasks, 760);
		pageContainer.addChild(prizeTasks);
	}
}
}