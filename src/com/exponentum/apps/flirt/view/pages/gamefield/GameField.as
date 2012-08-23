/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/11/12
 * Time: 4:14 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.gamefield
{
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.controlls.tabbar.TabBar;
import com.exponentum.apps.flirt.view.controlls.tabbar.TabButton;
import com.exponentum.apps.flirt.view.pages.BackGroundedPage;
import com.exponentum.apps.flirt.view.pages.gamefield.chat.Chat;
import com.exponentum.utils.centerX;
import com.exponentum.utils.centerY;
import com.greensock.TweenMax;
import com.greensock.easing.Bounce;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.Event;
import flash.geom.Point;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.load.SwfLoad;

public class GameField extends BackGroundedPage
{
	private var tableLoad:SwfLoad;
	private var tableContainer:CasaSprite = new CasaSprite();
	private var doubleArrow:DoubleArrow = new DoubleArrow();

	private var chatBG:MovieClip = new MovieClip();
	private var chat:Chat = new Chat();

	private var tabBar:TabBar = new TabBar();

	private var bottle:Bottle = new Bottle();

	private static const CHANGE_TABLE:String = "changeTable";
	private static const HELP:String = "help";

	
	private const avatarCoordinates:Array = [
		{x:125, y:89},
		{x:260, y:80},
		{x:395, y:80},
		{x:526, y:89},
		{x:576, y:240},
		{x:536, y:395},
		{x:395, y:404},
		{x:260, y:404},
		{x:130, y:394},
		{x:73, y:240}];
	private var avatarHolders:Vector.<PlayerAvatar> = new Vector.<PlayerAvatar>();

	private const kissersPlacesCoords:Array = [new Point(210, 240), new Point(440, 240)];
	private const celebrityAvatarCoords:Array = [new Point(490, 584), new Point(596, 584)];

	private var celebrityAvatars:Vector.<CelebrityAvatar> = new Vector.<CelebrityAvatar>();

	public function GameField()
	{
		setBackground(1);
		setTable(2);

		createView();

		createTabBar();
		createAvatars();
		createKisserPlaces();
		createCelebrityAvatars();
		createBottle();
		createArrow();
		createChat();
	}

	private function createChat():void
	{
		chat.x = chatBG.x;
		chat.y = chatBG.y;
		addChild(chat);
	}

	private function createArrow():void
	{
		addChild(doubleArrow);
		doubleArrow.x = bottle.x;
		doubleArrow.y = bottle.y;
		doubleArrow.visible = false;
		addChild(doubleArrow);
	}

	private function createBottle():void
	{
		addChild(bottle);
		centerX(bottle, 760);
		bottle.y = 315;
		bottle.addEventListener(Bottle.BOTTLE_STOPPED, onBottleStopped);
		bottle.setBottle(1);
	}

	private function onBottleStopped(e:Event):void
	{
		showKiss(avatarHolders[0], avatarHolders[1]);
	}

	private const numCelebrities:int = 2;

	private function createCelebrityAvatars():void
	{
		for (var i:int = 0; i < numCelebrities; i++)
		{
			celebrityAvatars.push(new CelebrityAvatar());
			celebrityAvatars[i].x = celebrityAvatarCoords[i].x;
			celebrityAvatars[i].y = celebrityAvatarCoords[i].y;
			addChild(celebrityAvatars[i]);
		}
	}

	private function createKisserPlaces():void
	{
		for (var i:int = 0; i < kissersPlacesCoords.length; i++)
		{
			var bap:BlankAvatarPlace = new BlankAvatarPlace();
			bap.x = kissersPlacesCoords[i].x;
			bap.y = kissersPlacesCoords[i].y;
			addChild(bap);
		}
	}

	private function createAvatars():void
	{
		for (var i:int = 0; i < avatarCoordinates.length; i++)
		{
			var bap:BlankAvatarPlace = new BlankAvatarPlace();
			bap.x = avatarCoordinates[i].x;
			bap.y = avatarCoordinates[i].y;
			addChild(bap);
		}
	}

	private function createTabBar():void
	{
		tabBar.y = 41;
		addChild(tabBar);
		tabBar.addTab(new TabButton(new ChangeTableButton()), "", CHANGE_TABLE, 50);
		tabBar.addTab(new TabButton(new HomeButton()), "", Config.PROFILE, 50);
		tabBar.addTab(new TabButton(new RatingsTabButton()), "", Config.RATINGS, 50);
		tabBar.addTab(new TabButton(new HelpButton()), "", HELP, 50);

		centerX(tabBar, 760);

		tabBar.addEventListener(CHANGE_TABLE, onChangeTable);
		tabBar.addEventListener(Config.PROFILE, onHome);
		tabBar.addEventListener(Config.RATINGS, onRatings);
		tabBar.addEventListener(HELP, onHelp);
	}

	//tab buttons hanlers
	private function onChangeTable(e:Event):void
	{

	}

	private function onHome(e:Event):void
	{
		dispatchEvent(new Event(Config.PROFILE));
	}

	private function onRatings(e:Event):void
	{
		dispatchEvent(new Event(Config.RATINGS));
	}

	private function onHelp(e:Event):void
	{
		
	}

	private function createView():void
	{
		chatBG = new BackGround();
		chatBG.x = 0;
		chatBG.y = -130;
		addChild(chatBG);
	}

	public function setTable(tableId:int):void
	{
		if(!contains(tableContainer)) addChild(tableContainer);
		tableLoad = new SwfLoad(Config.RESOURCES_SERVER + "tables/table" + tableId + ".swf");
		tableLoad.addEventListener(LoadEvent.COMPLETE, onBgLoaded);
		tableLoad.start();
	}

	private function onBgLoaded(e:LoadEvent):void
	{
		tableContainer.removeChildren(true, true);
		tableContainer.addChild(tableLoad.contentAsMovieClip);
		tableContainer.y = 67;
		centerX(tableContainer, 760);
	}

	//------------------------------------------------------------------------------------------------------------------
	// Game functionality
	//------------------------------------------------------------------------------------------------------------------
	public function addPlayerToTable(player:User, place:int):void
	{
		var userAvatar:PlayerAvatar = new PlayerAvatar(player.photoLink);
		userAvatar.x = avatarCoordinates[place].x;
		userAvatar.y = avatarCoordinates[place].y;
		addChild(userAvatar);
		avatarHolders.push(userAvatar);
	}

	private function showKiss(player1Avatar:PlayerAvatar, player2Avatar:PlayerAvatar):void
	{
		TweenMax.to(player1Avatar, .5, {x:kissersPlacesCoords[0].x, y:kissersPlacesCoords[0].y});
		TweenMax.to(player2Avatar, .5, {x:kissersPlacesCoords[1].x, y:kissersPlacesCoords[1].y});

		doubleArrow.visible = true;
		doubleArrow.scaleX = doubleArrow.scaleY = .4;
		TweenMax.to(doubleArrow, .5, {scaleX:1, scaleY:1, ease:Bounce.easeInOut});
	}

	private function showKissDialog():void
	{

	}

}
}
