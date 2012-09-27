/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/11/12
 * Time: 4:14 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.gamefield
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.controlls.Align;
import com.exponentum.apps.flirt.view.controlls.preloader.BlockerPreloader;
import com.exponentum.apps.flirt.view.controlls.tabbar.TabBar;
import com.exponentum.apps.flirt.view.controlls.tabbar.TabButton;
import com.exponentum.apps.flirt.view.pages.BackGroundedPage;
import com.exponentum.apps.flirt.view.pages.gamefield.chat.Chat;
import com.exponentum.apps.flirt.view.pages.profile.Profile;
import com.exponentum.apps.flirt.view.pages.profile.ProfileAvatar;
import com.exponentum.utils.centerX;
import com.exponentum.utils.centerY;
import com.greensock.TweenMax;
import com.greensock.easing.Bounce;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.utils.Dictionary;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.load.SwfLoad;
import org.osmf.metadata.IFacet;

import ru.cleptoman.net.UnsecurityDisplayLoader;

public class GameField extends BackGroundedPage
{
	private var tableLoad:SwfLoad;
	private var tableContainer:CasaSprite = new CasaSprite();
	private var doubleArrow:DoubleArrow = new DoubleArrow();

	private var chatBG:MovieClip = new MovieClip();
	private var chat:Chat;

	private var tabBar:TabBar = new TabBar();

	private var bottle:Bottle = new Bottle();

	private static const CHANGE_TABLE:String = "changeTable";
	private static const HELP:String = "help";

	private var placesOccupied:Dictionary = new Dictionary();
	//private var tablePlayers:Dictionary = new Dictionary();
	
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
		setBackground(Model.instance.owner.profileBackground);
		setTable(3);

		createView();
		createBecameVip();
		createBankIndicator();
		createTabBar();
		createAvatars();
		createKisserPlaces();
		createCelebrityAvatars();
		createBottle();
		createArrow();

		Model.instance.addEventListener(Controller.ON_JOINED_TO_MAIN_ROOM_QUEUE, onJoinedToRoomQueue);
		Model.instance.addEventListener(Controller.ON_JOINED_TO_TAGGED_ROOM_QUEUE, onJoinedToRoomQueue);
		Model.instance.addEventListener(Controller.ON_JOINED_TO_ROOM, onJoinedToRoom);
		Model.instance.addEventListener(Controller.ROOM_STATE_CHANGED, onRoomStateChanged);
		Model.instance.addEventListener(Controller.ROOM_DEATH, onRoomDeath);
		Model.instance.addEventListener(Controller.ROOM_USER_LIST_CHANGED, onUserListChanged);
		Model.instance.addEventListener(Controller.ROOM_IS_FULL, onRoomIsFool);
		Model.instance.addEventListener(Controller.ALREADY_IN_THIS_ROOM, onAlreadyInThisRoom);


		Model.instance.addEventListener(Controller.BOTTLE_SWINGED, onBottleSwinged);
		Model.instance.addEventListener(Controller.KISSED, onKissed);
		Model.instance.addEventListener(Controller.REFUSED_TO_KISS, onRefusedToKiss);
		Model.instance.addEventListener(Controller.NEW_BOTTLE_SWINGER, onNewBottleSwinger);



		if(Model.instance.owner.playInCity)
		{
			Controller.instance.joinToTaggedRoomQueue(Model.instance.owner.city);
		}
		else
		{
			Controller.instance.joinToMainRoomQueue();
		}
	}

	private function onBottleSwinged(e:ObjectEvent):void
	{
		bottle.addEventListener(Bottle.BOTTLE_STOPPED, onBottleStopped);
		bottle.showOnPlayer(getPlaceByGuid(e.data.victimGuid), int(Math.random() * 25));
	}

	private function onKissed(e:ObjectEvent):void
	{
		showKiss(getAvatarByGuid(e.data.kisserGuid), getAvatarByGuid(e.data.kissedGuid));
	}

	private function onRefusedToKiss(e:ObjectEvent):void
	{

	}

	private function onNewBottleSwinger(e:ObjectEvent):void
	{
		Controller.instance.swingBottle();
	}

	private function onBottleStopped(e:Event):void
	{
		bottle.removeEventListener(Bottle.BOTTLE_STOPPED, onBottleStopped);
		showKissDialog();
	}

	private var _kissDialog:KissDialog;
	private function showKissDialog():void
	{
		_kissDialog = new KissDialog();
		centerX(_kissDialog,  760);
		centerY(_kissDialog,  760);
		addChild(_kissDialog);
		_kissDialog.yesButton.addEventListener(MouseEvent.CLICK, onYes);
		_kissDialog.noButton.addEventListener(MouseEvent.CLICK, onNo);
		_kissDialog.tf.text = "Поцеловать?";
	}

	private function onYes(e:MouseEvent):void
	{
		Controller.instance.kiss();
		destroyKissDialog();
	}

	private function onNo(e:MouseEvent):void
	{
		Controller.instance.refuseToKiss();
		destroyKissDialog();

		putAllToTheirPlaces();
	}

	private function putAllToTheirPlaces():void
	{
		doubleArrow.visible = false;
		for (var i:int = 0; i < avatarHolders.length; i++)
		{
			var playerAvatar:PlayerAvatar = avatarHolders[i];
			TweenMax.to(playerAvatar, .5, {x:avatarCoordinates[i].x, y:avatarCoordinates[i].y});
		}
	}

	private function destroyKissDialog():void
	{
		removeChild(_kissDialog);
		_kissDialog.yesButton.removeEventListener(MouseEvent.CLICK, onYes);
		_kissDialog.noButton.removeEventListener(MouseEvent.CLICK, onNo);
		_kissDialog = null;
	}


	//handlers
	private function onJoinedToRoomQueue(e:ObjectEvent):void
	{
		trace("Joined to room queue!");
		createChat();
	}

	private function onJoinedToRoom(e:ObjectEvent):void
	{
		onUserListChanged(e);
	}

	private function onAlreadyInThisRoom(e:ObjectEvent):void
	{
		createChat();
	}


	private function onUserListChanged(e:ObjectEvent):void
	{
		placesOccupied = new Dictionary();
		for (var i:int = 0; i < avatarHolders.length; i++){
			if(contains(avatarHolders[i])) removeChild(avatarHolders[i]);
			avatarHolders[i] = null;
		}
		avatarHolders = new Vector.<PlayerAvatar>();

		for (var j:int = 0; j < e.data.users.length; j++)
			addPlayerToTable(e.data.users[j], j);
	}

	private function onRoomDeath(e:ObjectEvent):void
	{
		dispatchEvent(new Event(Config.PROFILE));
	}

	private function onRoomIsFool(e:ObjectEvent):void
	{
		dispatchEvent(new Event(Config.PROFILE));
	}

	private function nextFreePlace():int
	{
		for (var i:int = 0; i < avatarCoordinates.length; i++)
		{
			if(placesOccupied[i] == null) return i;
		}
		return 0;
	}

	private function onRoomStateChanged(e:Event):void
	{
		//???
	}
	//handlers

	private function createChat():void
	{
		chat = new Chat();
		chat.x = 0;
		chat.y = 620;
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
		bottle.setBottle(1);
	}

///////////////// chat avatars /////////////////////////////////////////////////////////////////////////////////////////
	private var celebrityAvatar:CelebrityAvatar = new CelebrityAvatar();
	private var chatterAvatar:CelebrityAvatar = new CelebrityAvatar();
	private function createCelebrityAvatars():void
	{
		chatterAvatar.x = celebrityAvatarCoords[0].x;
		chatterAvatar.y = celebrityAvatarCoords[0].y;
		addChild(chatterAvatar);
		chatterAvatar.vipMarker.visible = false;
		chatterAvatar.buttonMode = chatterAvatar.useHandCursor = true;
		chatterAvatar.addEventListener(MouseEvent.CLICK, onBuyChatterStatus);

		celebrityAvatar.x = celebrityAvatarCoords[1].x;
		celebrityAvatar.y = celebrityAvatarCoords[1].y;
		addChild(celebrityAvatar);

		Controller.instance.getRandomVIP();
		Model.instance.addEventListener(Controller.ON_GOT_RANDOM_VIP, onRandomVip);
		Model.instance.addEventListener(Controller.ON_GOT_RANDOM_CHATTER, onRandomChatter);
	}

	private var chatterGuid:String = "";

	private function onRandomChatter(e:ObjectEvent):void
	{
		chatterGuid = e.data.chatterGuid;
		Model.instance.addEventListener(Controller.GOT_USER_INFO, onUserInfo);
		Controller.instance.getUserInfo(chatterGuid);
	}
	private var randomVipGuid:String = "";

	private function onRandomVip(e:ObjectEvent):void
	{
		randomVipGuid = e.data.vipGuid;
		Model.instance.addEventListener(Controller.GOT_USER_INFO, onUserInfo);
		Controller.instance.getUserInfo(randomVipGuid);
	}
	private var isVipLoaded:Boolean = false;
	private function onUserInfo(e:ObjectEvent):void
	{
		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onUserInfo);
		var user:User = e.data as User;
		var req:URLRequest = new URLRequest(user.photoLinkMedium);
		var loader:Loader = new Loader();
		var holder:Sprite = new Sprite();

		if(user.guid == randomVipGuid && !isVipLoaded){
			holder = celebrityAvatar.celebrityAvatarHolder;
			isVipLoaded = true;
		}
		if(user.guid == chatterGuid){
			holder = chatterAvatar.celebrityAvatarHolder;
		}

		var bp:BlockerPreloader = new BlockerPreloader(holder, holder.width, holder.height, 0);
		bp.preload(1);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void{
			Align.center(loader, holder);
			holder.addChild(loader);
			bp.partsLoaded++;
		});
		loader.load(req);
	}

	private var chatterPrel:BlockerPreloader;
	private function onBuyChatterStatus(e:MouseEvent):void
	{
		chatterPrel = new BlockerPreloader(this, this.width, this.height);
		Model.instance.addEventListener(Controller.ON_BUY_CHATTER_STATUS_SUCCESS, buyChatterSuccess);
		Model.instance.addEventListener(Controller.ON_BUY_CHATTER_STATUS_FAIL, buyChatterFail);
		Controller.instance.buyChatterStatus();
		chatterPrel.preload(1);
	}

	private function buyChatterFail(e:ObjectEvent):void
	{
		Model.instance.removeEventListener(Controller.ON_BUY_CHATTER_STATUS_SUCCESS, buyChatterSuccess);
		Model.instance.removeEventListener(Controller.ON_BUY_CHATTER_STATUS_FAIL, buyChatterFail);
		chatterPrel.partsLoaded++;
	}

	private function buyChatterSuccess(e:ObjectEvent):void
	{
		Model.instance.removeEventListener(Controller.ON_BUY_CHATTER_STATUS_SUCCESS, buyChatterSuccess);
		Model.instance.removeEventListener(Controller.ON_BUY_CHATTER_STATUS_FAIL, buyChatterFail);
		chatterPrel.partsLoaded++;
		chatterAvatar.buttonMode = chatterAvatar.useHandCursor = false;
		chatterAvatar.removeEventListener(MouseEvent.CLICK, onBuyChatterStatus);
	}

///////////////// chat avatars /////////////////////////////////////////////////////////////////////////////////////////
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
		destroy();
	}

	private function onRatings(e:Event):void
	{
		dispatchEvent(new Event(Config.RATINGS));
		destroy();
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
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	private var becameVIPButton:BecameVIPButton = new BecameVIPButton();
	private function createBecameVip():void
	{
		if(Model.instance.owner.vipPoints == 0){
			becameVIPButton.x = 135;
			becameVIPButton.y = 33;
			addChild(becameVIPButton);
			becameVIPButton.addEventListener(MouseEvent.CLICK, onBecameVIP);
		}
	}

	private var bp:BlockerPreloader;
	private function onBecameVIP(e:MouseEvent):void
	{
		bp = new BlockerPreloader(this, this.width, this.height);
		Model.instance.addEventListener(Controller.ON_VIP_POINTS_BUY_SUCCESS, onBecameVIPSuccess);
		Model.instance.addEventListener(Controller.ON_VIP_POINTS_BUY_FAIL, onBecameVIPFail);
		Controller.instance.buyVIPPoints();
		bp.preload(1);
	}

	private function onBecameVIPSuccess(e:ObjectEvent):void
	{
		Model.instance.removeEventListener(Controller.ON_VIP_POINTS_BUY_SUCCESS, onBecameVIPSuccess);
		Model.instance.removeEventListener(Controller.ON_VIP_POINTS_BUY_FAIL, onBecameVIPFail);
		bp.partsLoaded++;
		becameVIPButton.visible = false;
	}

	private function onBecameVIPFail(e:ObjectEvent):void
	{
		Model.instance.removeEventListener(Controller.ON_VIP_POINTS_BUY_SUCCESS, onBecameVIPSuccess);
		Model.instance.removeEventListener(Controller.ON_VIP_POINTS_BUY_FAIL, onBecameVIPFail);
		bp.partsLoaded++;
	}

	private var bankIndicator:BankIndicatorAsset = new BankIndicatorAsset();
	private function createBankIndicator():void
	{
		bankIndicator.x = 520;
		bankIndicator.y = 9;
		addChild(bankIndicator);

		bankIndicator.moeyTF.text = Model.instance.owner.coins.toString();

		Model.instance.addEventListener(Controller.ON_BANK_BALANCE_CHANGED, onBankBalanceChanged);
		bankIndicator.addMoneyButton.addEventListener(MouseEvent.CLICK, onAddMoneyClick);
	}

	private function onAddMoneyClick(e:MouseEvent):void
	{

	}

	private function onBankBalanceChanged(e:ObjectEvent):void
	{
		bankIndicator.moeyTF.text = e.data.newGold;
	}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
	public function addPlayerToTable(playerGuid:String, place:int = 0):void
	{
		placesOccupied[place] = place;
		var userAvatar:PlayerAvatar = new PlayerAvatar(playerGuid);
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
		TweenMax.to(doubleArrow, .5, {scaleX:1, scaleY:1, ease:Bounce.easeInOut, onComplete:function():void{
			putAllToTheirPlaces();
		}});
	}

	private function getAvatarByGuid(guid:String):PlayerAvatar
	{
		for (var i:int = 0; i < avatarHolders.length; i++)
			if(avatarHolders[i].player.guid == guid) return avatarHolders[i];
		return null;
	}

	private function getPlaceByGuid(guid:String):int
	{
		for (var i:int = 0; i < avatarHolders.length; i++)
			if(avatarHolders[i].player.guid == guid) return i;
		return -1;
	}

	override public function destroy():void
	{
		Model.instance.removeEventListener(Controller.ON_BANK_BALANCE_CHANGED, onBankBalanceChanged);
		Model.instance.removeEventListener(Controller.ON_JOINED_TO_MAIN_ROOM_QUEUE, onJoinedToRoomQueue);
		Model.instance.removeEventListener(Controller.ON_JOINED_TO_TAGGED_ROOM_QUEUE, onJoinedToRoomQueue);
		Model.instance.removeEventListener(Controller.ON_JOINED_TO_ROOM, onJoinedToRoom);
		Model.instance.removeEventListener(Controller.ROOM_STATE_CHANGED, onRoomStateChanged);
		Model.instance.removeEventListener(Controller.ROOM_DEATH, onRoomDeath);
		Model.instance.removeEventListener(Controller.ROOM_USER_LIST_CHANGED, onUserListChanged);
		Model.instance.removeEventListener(Controller.ROOM_IS_FULL, onRoomIsFool);
		Model.instance.removeEventListener(Controller.ALREADY_IN_THIS_ROOM, onAlreadyInThisRoom);

		Model.instance.removeEventListener(Controller.BOTTLE_SWINGED, onBottleSwinged);
		Model.instance.removeEventListener(Controller.KISSED, onKissed);
		Model.instance.removeEventListener(Controller.REFUSED_TO_KISS, onRefusedToKiss);
		Model.instance.removeEventListener(Controller.NEW_BOTTLE_SWINGER, onNewBottleSwinger);
		Model.instance.removeEventListener(Controller.ON_BUY_CHATTER_STATUS_SUCCESS, buyChatterSuccess);
		Model.instance.removeEventListener(Controller.ON_BUY_CHATTER_STATUS_FAIL, buyChatterFail);
		Model.instance.removeEventListener(Controller.ON_GOT_RANDOM_VIP, onRandomVip);
		Model.instance.removeEventListener(Controller.ON_GOT_RANDOM_CHATTER, onRandomChatter);
		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onUserInfo);
		bankIndicator.addMoneyButton.removeEventListener(MouseEvent.CLICK, onAddMoneyClick);
		removeChildren(true, true);
		super.destroy();
	}

}
}
