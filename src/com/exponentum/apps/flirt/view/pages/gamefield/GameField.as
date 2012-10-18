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
import com.exponentum.apps.flirt.view.common.DialogWindow;
import com.exponentum.apps.flirt.view.common.InfoWindow;
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
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.utils.setTimeout;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.load.SwfLoad;
import org.casalib.transitions.Tween;
import org.osmf.events.FacetValueChangeEvent;
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

	//private var placesOccupied:Dictionary;

	private var kissData:Dictionary;


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
	private var avatarHolders:Vector.<PlayerAvatar>;

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
			Controller.instance.joinToTaggedRoomQueue(Model.instance.owner.city);
		else
			Controller.instance.joinToMainRoomQueue();
	}

	private var kisserGuid:String = "";
	private function onNewBottleSwinger(e:ObjectEvent):void
	{
		destroyKissDialog();
		putAllToTheirPlaces();

		setTimeout(function():void{
			kisserGuid = e.data.swingerGuid;
			var swingerAvatar:PlayerAvatar = getAvatarByGuid(kisserGuid);
			TweenMax.to(swingerAvatar, 1, {x:kissersPlacesCoords[0].x, y:kissersPlacesCoords[0].y, onComplete:function():void{
				if(kisserGuid == Model.instance.owner.guid)
				{
					Controller.instance.swingBottle();
				}
			}});

			kissData = new Dictionary();
			kissData[kisserGuid] = -1;
		}, 1000);

	}

	private var victimGuid:String = "";
	private function onBottleSwinged(e:ObjectEvent):void
	{
		victimGuid = e.data.victimGuid;
		bottle.addEventListener(Bottle.BOTTLE_STOPPED, onBottleStopped);
		bottle.showOnPlayer(getPlaceByGuid(victimGuid), 5);
		kissData[victimGuid] = -1;
	}

	private function onBottleStopped(e:Event):void
	{
		bottle.removeEventListener(Bottle.BOTTLE_STOPPED, onBottleStopped);

		var victimAvatar:PlayerAvatar = getAvatarByGuid(victimGuid);
		TweenMax.to(victimAvatar, 1, {x:kissersPlacesCoords[1].x, y:kissersPlacesCoords[1].y, onComplete:function():void{
			showKissDialog();
		}});
	}

	private var _kissDialog:KissDialog;
	private function showKissDialog():void
	{
		if(Model.instance.owner.guid != kisserGuid &&  Model.instance.owner.guid != victimGuid) return;
		_kissDialog = new KissDialog();
		_kissDialog.x = 375;
		_kissDialog.y = 400;
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
	}

	private function onKissed(e:ObjectEvent):void
	{
		if(!kissData) return;
		kissData[e.data.kisserGuid] = 1;
		showKissAnimation();
	}

	private function onRefusedToKiss(e:ObjectEvent):void
	{
		if(!kissData) return;
		kissData[e.data.refuserGuid] = 0;
		showKissAnimation();
	}

	private function showKissAnimation():void
	{
		if(kissData[kisserGuid] >= 0 && kissData[victimGuid] >= 0)
		{
			if(kissData[kisserGuid] == 1)
			{
				var lips1:Lips = new Lips();
				addChild(lips1);
				lips1.x = getAvatarByGuid(kisserGuid).x + 10;
				lips1.y = getAvatarByGuid(kisserGuid).y + 10;
				TweenMax.to(lips1, 1, {x:getAvatarByGuid(victimGuid).x + 10, y:getAvatarByGuid(victimGuid).y + 10, alpha:0, onComplete:function():void{
					removeChild(lips1);
					putAllToTheirPlaces();
				}});
			}
			
			if(kissData[victimGuid] == 1)
			{
				var lips2:Lips = new Lips();
				addChild(lips2);
				lips2.x = getAvatarByGuid(victimGuid).x + 10;
				lips2.y = getAvatarByGuid(victimGuid).y + 10;
				TweenMax.to(lips2, 1, {x:getAvatarByGuid(kisserGuid).x + 10, y:getAvatarByGuid(kisserGuid).y + 10, alpha:0, onComplete:function():void{
					removeChild(lips2);
					putAllToTheirPlaces();
				}});
			}
			
			if(kissData[kisserGuid] == kissData[victimGuid] && kissData[victimGuid] == 0)
			{
				putAllToTheirPlaces();
			}
		}
	}

	private function putAllToTheirPlaces(forced:Boolean = false):void
	{
		kissData = null;
		doubleArrow.visible = false;
		for (var i:int = 0; i < avatarHolders.length; i++)
		{
			var playerAvatar:PlayerAvatar = avatarHolders[i];
			TweenMax.to(playerAvatar, 1, {x:avatarCoordinates[i].x, y:avatarCoordinates[i].y});
		}
	}

	private function destroyKissDialog():void
	{
		if(_kissDialog == null) return;
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
//		for (var i:int = 0; i < avatarHolders.length; i++){
//			if(contains(avatarHolders[i])) removeChild(avatarHolders[i]);
//			avatarHolders[i] = null;
//		}
		if(!avatarHolders) avatarHolders = new Vector.<PlayerAvatar>();

		for (var j:int = 0; j < e.data.users.length; j++)
			addPlayerToTable(e.data.users[j]);
	}

	private function onRoomDeath(e:ObjectEvent):void
	{
		dispatchEvent(new Event(Config.PROFILE));
	}

	private function onRoomIsFool(e:ObjectEvent):void
	{
		dispatchEvent(new Event(Config.PROFILE));
	}

	private function onRoomStateChanged(e:Event):void
	{
		//???
	}
	//handlers

	private function createChat():void
	{
		if(chat) return;
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

	private var timer:Timer = new Timer(1000);
	private const CHANGE_INTERVAL:int = 50;
	private var timeToNextChange:int = 0;

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

		Model.instance.addEventListener(Controller.ON_GOT_RANDOM_VIP, onRandomVip);
		Model.instance.addEventListener(Controller.ON_GOT_RANDOM_CHATTER, onRandomChatter);

		timeToNextChange = CHANGE_INTERVAL;
		timer.addEventListener(TimerEvent.TIMER, onTimer);
		timer.start();

	}

	private function onTimer(e:TimerEvent = null):void
	{
		if(timeToNextChange == CHANGE_INTERVAL) {
			timeToNextChange = 0;
			Controller.instance.getRandomVIP();
			Controller.instance.getRandomChatter();
		}
		timeToNextChange ++;
	}

	private var chatterGuid:String = "";

	private function onRandomChatter(e:ObjectEvent):void
	{
		chatterGuid = e.data.chatterGuid;
		Model.instance.addEventListener(Controller.GOT_USER_INFO, onChatterInfo);
		Controller.instance.getUserInfo(chatterGuid);
	}

	private function onChatterInfo(e:ObjectEvent):void
	{
		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onChatterInfo);
		var user:User = e.data as User;
		var req:URLRequest = new URLRequest(user.photoLinkMedium);
		var loader:Loader = new Loader();
		var holder:Sprite = new Sprite();

		if(user.guid == chatterGuid){
			holder = chatterAvatar.celebrityAvatarHolder;
		}

		var bp:BlockerPreloader = new BlockerPreloader(chatterAvatar,  100, 110, 0);
		bp.preload(1);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void{
			while(holder.numChildren){
				holder.removeChildAt(0);
			}
			Align.center(loader, holder);

			holder.addChild(loader);
			bp.partsLoaded++;
		});
		loader.load(req);
	}
	private var randomVipGuid:String = "";

	private function onRandomVip(e:ObjectEvent):void
	{
		randomVipGuid = e.data.vipGuid;
		Model.instance.addEventListener(Controller.GOT_USER_INFO, onVipInfo);
		Controller.instance.getUserInfo(randomVipGuid);
	}
	private function onVipInfo(e:ObjectEvent):void
	{
		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onVipInfo);
		var user:User = e.data as User;
		var req:URLRequest = new URLRequest(user.photoLinkMedium);
		var loader:Loader = new Loader();
		var holder:Sprite = new Sprite();

		if(user.guid == randomVipGuid){
			holder = celebrityAvatar.celebrityAvatarHolder;
		}
		var bp:BlockerPreloader = new BlockerPreloader(celebrityAvatar, 100, 110, 0);
		bp.preload(1);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void{
			while(holder.numChildren){
				holder.removeChildAt(0);
			}
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
		Model.instance.view.showDialogWindow(new DialogWindow("Вы уверенны что хотите купить это место за монеты?", "Внимание!", "Да", "Нет", function():void{
			Model.instance.addEventListener(Controller.ON_BUY_CHATTER_STATUS_SUCCESS, buyChatterSuccess);
			Model.instance.addEventListener(Controller.ON_BUY_CHATTER_STATUS_FAIL, buyChatterFail);
			Controller.instance.buyChatterStatus();
			chatterPrel.preload(1);
		}));
	}


	private function buyChatterFail(e:ObjectEvent):void
	{
		Model.instance.view.showInfoWindow(new InfoWindow("Покупка не удалась! Попробуйте позже", "Ошибка!"));
		Model.instance.removeEventListener(Controller.ON_BUY_CHATTER_STATUS_SUCCESS, buyChatterSuccess);
		Model.instance.removeEventListener(Controller.ON_BUY_CHATTER_STATUS_FAIL, buyChatterFail);
		chatterPrel.partsLoaded++;
	}

	private function buyChatterSuccess(e:ObjectEvent):void
	{
		Model.instance.view.showInfoWindow(new InfoWindow("Вы успешно приобрели это место. Ваш профиль будет виден остальным игрокам", "Успех!"));
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
		Model.instance.addEventListener(Controller.LEAVE_CURRENT_ROOM_FAIL, onLeaveRoomFail);
		Model.instance.addEventListener(Controller.LEAVE_CURRENT_ROOM_SUCCESS, onLeaveRoomSuccess);
		Controller.instance.leaveCurrentRoom();
	}

	private function onLeaveRoomFail(e:Event):void
	{
		Model.instance.removeEventListener(Controller.LEAVE_CURRENT_ROOM_FAIL, onLeaveRoomFail);
		Model.instance.removeEventListener(Controller.LEAVE_CURRENT_ROOM_SUCCESS, onLeaveRoomSuccess);

	}

	private function onLeaveRoomSuccess(e:Event):void
	{
		Model.instance.removeEventListener(Controller.LEAVE_CURRENT_ROOM_FAIL, onLeaveRoomFail);
		Model.instance.removeEventListener(Controller.LEAVE_CURRENT_ROOM_SUCCESS, onLeaveRoomSuccess);
		if(Model.instance.owner.playInCity)
			Controller.instance.joinToTaggedRoomQueue(Model.instance.owner.city);
		else
			Controller.instance.joinToMainRoomQueue();
	}

	private function onHome(e:Event):void
	{
		Controller.instance.leaveCurrentRoom();
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
	public function addPlayerToTable(playerGuid:String):void
	{
		//placesOccupied[place] = place;
		for each (var pa:PlayerAvatar in avatarHolders)
		{
			if(pa.player.guid == playerGuid) return;
		}
		
		var userAvatar:PlayerAvatar = new PlayerAvatar(playerGuid);
		userAvatar.x = avatarCoordinates[avatarHolders.length].x;
		userAvatar.y = avatarCoordinates[avatarHolders.length].y;
		addChild(userAvatar);
		avatarHolders.push(userAvatar);

		setChildIndex(bottle, getChildIndex(userAvatar));
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
		if(this.destroyed) return;
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
		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onVipInfo);
		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onChatterInfo);
		bankIndicator.addMoneyButton.removeEventListener(MouseEvent.CLICK, onAddMoneyClick);

		tableLoad = null;
		if(tableContainer)removeChild(tableContainer);
		tableContainer = null;
		if(doubleArrow)removeChild(doubleArrow);
		doubleArrow = null;

		removeChild(chat);
		chat.destroy();
		chat = null;//chat.destroy();
		if(chatBG)removeChild(chatBG);
		chatBG = null;


		removeChild(tabBar);
		tabBar = null;

		removeChild(bottle);
		bottle = null;

		super.destroy();
	}

}
}
