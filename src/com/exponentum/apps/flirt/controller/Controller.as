package com.exponentum.apps.flirt.controller
{
import com.exponentum.apps.flirt.controller.net.AppSocket;
import com.exponentum.apps.flirt.controller.net.ServerConfig;
import com.exponentum.apps.flirt.controller.net.ServerConnector;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Model;
import com.junkbyte.console.Cc;

import flash.events.Event;

import mx.states.State;

import ru.evast.integration.core.SocialProfileVO;

public class Controller
{
	private var model:Model;

	//room
	public static const JOIN_TO_MAIN_ROOM_QUEUE:String = "JoinMainRoomQueue";
	public static const JOINED_TO_MAIN_ROOM_QUEUE:String = "OnJoinedToMainRoomQueue";
	public static const JOINED_TO_ROOM:String = "OnJoinedToRoom";
	public static const ROOM_DEATH:String = "OnRoomDeath";
	public static const ROOM_USER_LIST_CHANGED:String = "OnRoomUserListChanged";
	public static const ROOM_STATE_CHANGED:String = "OnRoomStateChaned";
	public static const ROOM_IS_FULL:String = "OnRoomIsFull";
	public static const ALREADY_IN_THIS_ROOM:String = "OnAlreadyInThisRoom";

	//game
	public static const SWING_BOTTLE:String = "SwingBottle";
	public static const BOTTLE_SWINGED:String = "OnBottleSwinged";
	public static const KISS:String = "Kiss";
	public static const REFUSE_TO_KISS:String = "RefuseToKiss";
	public static const KISSED:String = "OnKiss";
	public static const REFUSED_TO_KISS:String = "OnRefuseToKiss";
	public static const NEW_BOTTLE_SWINGER:String = "OnNewBottleSwinger";

	//chat
	public static const SEND_CHAT_MESSAGE_TO_ROOM:String = "SendChatMessageToRoom";
	public static const GOT_CHAT_MESSAGE_FROM_ROOM:String = "OnGotChatMessageFromRoom";

	private var socket:AppSocket;

	public function Controller()
	{
		model = Model.instance;

		init();
	}

	private function init():void
	{
		socket = new AppSocket(ServerConfig.SERVER, ServerConfig.SOCKET_PORT);

		startListenSocket();
	}

	private function startListenSocket():void
	{
		socket.addEventListener(AUTHENTICATED, onAuthenticated);
		socket.addEventListener(GOT_CHAT_MESSAGE_FROM_ROOM, onGotChatMessageFromRoom);
		socket.addEventListener(GOT_USER_INFO, onGotUserInfo);
		socket.addEventListener(TOUCH_USER_INFO_RESULT, onTouchUserInfoResult);
		socket.addEventListener(TOUCH_USER_INFO_BY_USER_RESULT, touchUserInfoByUserResult);
		socket.addEventListener(ON_GOT_MY_GIFTS, onGotMyGifts);
		socket.addEventListener(ON_GOT_USER_SYMPATHIES, onGotUserSympathies);
		socket.addEventListener(ON_GOT_DECORATIONS, onGotDecorations);
		socket.addEventListener(ON_GOT_USER_RATE, onGotUserRate);

		//room
		socket.addEventListener(JOINED_TO_MAIN_ROOM_QUEUE, onJoinedToMainRoomQueue);
		socket.addEventListener(JOINED_TO_ROOM, onJoinedToRoom);
		socket.addEventListener(ROOM_DEATH, onRoomDeath);
		socket.addEventListener(ROOM_USER_LIST_CHANGED, onRoomUserListChanged);
		socket.addEventListener(ROOM_STATE_CHANGED, onRoomStateChanged);
		socket.addEventListener(ROOM_IS_FULL, onRoomIsFool);
		socket.addEventListener(ALREADY_IN_THIS_ROOM, onAlreadyInRoom);

		//game
		socket.addEventListener(BOTTLE_SWINGED, onBottleSwinged);
		socket.addEventListener(KISSED, onKissed);
		socket.addEventListener(REFUSED_TO_KISS, onRefusedToKiss);
		socket.addEventListener(NEW_BOTTLE_SWINGER, onNewBottleSwinger);

		//mail
		socket.addEventListener(ON_GOT_MAILBOX, onGotMailbox);
		socket.addEventListener(ON_GOT_NEW_MAIL, onGotNewMail);

		//followers
		socket.addEventListener(ON_GOT_USER_FOLLOWERS, onGotUserFollowers);
		socket.addEventListener(ON_FOLLOWING_BOUGHT, onFollowingBought);

	}

	//------------------------------------------------------------------------------------------------------------------
	// Commands
	//------------------------------------------------------------------------------------------------------------------
	//user



	public function touchUserInfoByUser(changes:Object):void
	{
		var requestObject:Object = new Object();
		requestObject[TOUCH_USER_INFO_BY_USER] = {};
		for (var key:String in changes)
		{
			requestObject[TOUCH_USER_INFO_BY_USER][key] = changes[key];
		}
		socket.sendRequest(requestObject);
	}

	//room
	public function joinToMainRoomQueue():void
	{
		var requestObject:Object = new Object();
		requestObject[JOIN_TO_MAIN_ROOM_QUEUE] = {};
		socket.sendRequest(requestObject);
	}

	public function sendMessageToRoom(messageText:String):void
	{
		var requestObject:Object = new Object();
		requestObject[SEND_CHAT_MESSAGE_TO_ROOM] = {};
		requestObject[SEND_CHAT_MESSAGE_TO_ROOM].message = messageText;
		socket.sendRequest(requestObject);
	}

	//game
	public function swingBottle():void
	{
		var requestObject:Object = new Object();
		requestObject[SWING_BOTTLE] = {};
		socket.sendRequest(requestObject);
	}

	public function kiss():void
	{
		var requestObject:Object = new Object();
		requestObject[KISS] = {};
		socket.sendRequest(requestObject);
	}

	public function refuseToKiss():void
	{
		var requestObject:Object = new Object();
		requestObject[REFUSE_TO_KISS] = {};
		socket.sendRequest(requestObject);
	}
	//------------------------------------------------------------------------------------------------------------------
	// Handlers
	//------------------------------------------------------------------------------------------------------------------
	//user


	private function touchUserInfoByUserResult(e:ObjectEvent):void
	{

	}

	//room
	private function onJoinedToMainRoomQueue(e:ObjectEvent):void
	{
	}

	private function onJoinedToRoom(e:ObjectEvent):void
	{
	}

	private function onRoomStateChanged(e:ObjectEvent):void
	{
	}

	private function onRoomUserListChanged(e:ObjectEvent):void
	{
	}

	private function onRoomIsFull(e:ObjectEvent):void
	{
	}

	private function onRoomIsFool(e:ObjectEvent):void
	{
	}

	private function onAlreadyInRoom(e:ObjectEvent):void
	{
	}

	private function onRoomDeath(e:ObjectEvent):void
	{
	}

	//chat
	private function onGotChatMessageFromRoom(e:ObjectEvent):void
	{
	}

	//game
	private function onBottleSwinged(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	private function onKissed(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	private function onRefusedToKiss(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	private function onNewBottleSwinger(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	// USER PROFILE INFO
	//------------------------------------------------------------------------------------------------------------------
	public static const AUTHENTICATE:String = "Authenticate";
	public static const AUTHENTICATED:String = "Authenticated";
	public static const TOUCH_USER_INFO:String = "TouchUserInfo";
	public static const TOUCH_USER_INFO_RESULT:String = "TouchUserInfoResult";
	public static const GET_USER_INFO:String = "GetUserInfo";
	public static const GOT_USER_INFO:String = "OnGotUserInfo";
	public static const TOUCH_USER_INFO_BY_USER:String = "TouchUserInfoByUser";
	public static const TOUCH_USER_INFO_BY_USER_RESULT:String = "TouchUserInfoByUserResult";
	public static const GET_MY_GIFTS:String = "GetMyGifts";
	public static const ON_GOT_MY_GIFTS:String = "OnGotMyGifts";
	public static const GET_USER_SYMPATHIES:String = "GetUserSympathies";
	public static const ON_GOT_USER_SYMPATHIES:String = "OnGotUserSympathies";
	public static const GET_USER_FOLLOWERS:String = "GetUserFollowers";
	public static const ON_GOT_USER_FOLLOWERS:String = "OnGotUserFollowers";
	public static const BUY_FOLLOWING:String = "BuyFollowing";
	public static const ON_FOLLOWING_BOUGHT:String = "OnFollowingBought";
	public static const BUY_DECORE:String = "BuyDecore";
	public static const GET_DECORATION_FOR:String = "GetDecorationsFor";
	public static const ON_GOT_DECORATIONS:String = "OnGotDecorations";
	public static const GET_USER_RATE:String = "GetUserRate";
	public static const ON_GOT_USER_RATE:String = "OnGotUserRate";
	public static const GET_FRIEND_INFO:String = "GetUserInfo";

	private var sessionStart:Boolean = false;

	public function userLogin(firstSession:Boolean = false):void//TODO: not only owner support
	{
//		if(sessionStart)
//			authenticate(model.owner.id, "");
//		return;
//		touchUserInfo('{"userInfo" : { "UserInfo" : ' +
//				'{"userId" : "' + model.owner.id + '",' +
//				'"name" : "' + model.owner.name + '",' +
//				'"profileUrl" : "' + model.owner.profileLink + '",' +
//				'"isMan" : "' + model.owner.sex + '",' +
//				'"birthDate" : "' + model.owner.birthDate + '",' +
//				'"city" : "' + model.owner.city + '",' +
//				'"avatarUrl" : "' + model.owner.photoLink + '", ' +
//				'"hideSocialInfo":"0", ' +
//				'"hideName":"0", ' +
//				'"hideCity":"0"}}}');

		sessionStart = firstSession;
		authenticate(model.owner.id, "");
	}

	public function touchUserInfo(userInfo:String):void
	{
		ServerConnector.instance.addEventListener(TOUCH_USER_INFO_RESULT, onTouchUserInfoResult);
		ServerConnector.call(TOUCH_USER_INFO, userInfo);
	}

	private function onTouchUserInfoResult(e:ObjectEvent):void
	{
		if(sessionStart)
			authenticate(model.owner.id, "");
		else
			getUserInfo(model.owner.guid);
	}

	public function authenticate(login:String, password:String):void
	{
		var requestObject:Object = new Object();
		requestObject[AUTHENTICATE] = {};
		requestObject[AUTHENTICATE]["login"] = login;
		requestObject[AUTHENTICATE]["password"] = password;
		socket.sendRequest(requestObject);
	}

	private function onAuthenticated(e:ObjectEvent):void
	{
		model.owner.guid = e.data.guid;
		getUserInfo(model.owner.guid);
	}

	private function getUserInfo(guid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_USER_INFO] = {};
		requestObject[GET_USER_INFO].targetUserGuid = guid;
		socket.sendRequest(requestObject);
	}

	private function onGotUserInfo(e:ObjectEvent):void
	{
		model.owner.id = e.data.userId;
		model.owner.guid = e.data.infoOwnerGuid;
		model.owner.name = e.data.name;
		model.owner.city = e.data.city;
		model.owner.photoLink = e.data.pictureUrl;
		model.owner.profileLink = e.data.profileUrl;
		model.owner.birthDate = e.data.birthDate;
		model.owner.sex = e.data.sex;
		model.owner.isOnline = e.data.isOnline;

		model.owner.isLinkHidden = e.data.isSocialInfoHidden;
		model.owner.isAgeHidden = e.data.isCityHidden;
		model.owner.isCityHidden = e.data.isNameHidden;

		model.owner.coins = e.data.coins;
		model.owner.kisses = e.data.kisses;

		if(sessionStart)
			getUserSympathies(model.owner.guid);
		else
			model.userInfoUpdated();

		model.basicUserInfoCollected();
	}

	private function getUserSympathies(guid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_USER_SYMPATHIES] = {};
		requestObject[GET_USER_SYMPATHIES].targetUserGuid = guid;
		socket.sendRequest(requestObject);
	}

	private function onGotUserSympathies(e:ObjectEvent):void
	{
		model.owner.sympathies = e.data.sympathies;
		if(sessionStart)
			getMyGifts();
	}

	private function getMyGifts():void
	{
		var requestObject:Object = new Object();
		requestObject[GET_MY_GIFTS] = {};
		socket.sendRequest(requestObject);
	}

	private function onGotMyGifts(e:ObjectEvent):void
	{
		model.owner.presents = e.data.gifts;
		if(sessionStart)
			getUserFollowers(model.owner.guid);
	}

	private function getUserFollowers(userGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_USER_FOLLOWERS] = {};
		requestObject[GET_USER_FOLLOWERS].targetUserGuid = userGuid;
		socket.sendRequest(requestObject);
	}

	private function onGotUserFollowers(e:ObjectEvent):void
	{
		model.owner.followers = e.data.followers;
		model.owner.rebuyPrice = e.data.rebuyPrice;

		if(sessionStart)
			getDecorationFor(model.owner.guid);
	}

	private function getDecorationFor(userGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_DECORATION_FOR] = {};
		requestObject[GET_DECORATION_FOR].targetUserGuid = userGuid;
		socket.sendRequest(requestObject);
	}

	private function onGotDecorations(e:ObjectEvent):void
	{
		model.owner.decorations = e.data.decorations;
		if(sessionStart)
			getUserRate(model.owner.guid);
	}

	private function getUserRate(userGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_USER_RATE] = {};
		requestObject[GET_USER_RATE].targetUserGuid = userGuid;
		socket.sendRequest(requestObject);
	}

	private function onGotUserRate(e:ObjectEvent):void
	{
		model.owner.userRate = e.data.averateRate;
		model.owner.lastRaters = e.data.lastRaters;


		sessionStart = false;
	}

	private function buyFollowing(userGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[BUY_FOLLOWING] = {};
		requestObject[BUY_FOLLOWING].targetUserGuid = userGuid;
		socket.sendRequest(requestObject);
	}

	private function onFollowingBought(e:ObjectEvent):void
	{

	}

	private function buyDecore(decoreGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[BUY_DECORE] = {};
		requestObject[BUY_DECORE].decoreGuid = decoreGuid;
		socket.sendRequest(requestObject);
	}

	public function getUsersInfos(guids:Array):void
	{
		for (var i:int = 0; i < guids.length; i++)
		{
			getFriendInfo(guids[i]);
		}
	}

	//------------------------------------------------------------------------------------------------------------------
	// DIRECT MESSAGES
	//------------------------------------------------------------------------------------------------------------------
	public static const CHECK_MAILBOX:String = "CheckMailbox";
	public static const ON_GOT_MAILBOX:String = "OnGotMailbox";
	public static const SEND_MAIL:String = "SendMail";
	public static const ON_GOT_NEW_MAIL:String = "OnGotNewMail";
	public static const MARK_MAIL_AS_READ:String = "MarkMailAsRead";
	public static const ON_MESSAGE_MARKED_AS_READ:String = "OnMessageMarkedAsRead";

	public function checkMailbox():void
	{
		var requestObject:Object = new Object();
		requestObject[CHECK_MAILBOX] = {};
		socket.sendRequest(requestObject);
	}

	private function onGotMailbox(e:ObjectEvent):void
	{
		model.mail = e.data.mails as Array;
	}

	public function sendMail(receiverGuid:String, subject:String, body:String):void
	{
		var requestObject:Object = new Object();
		requestObject[SEND_MAIL] = {};
		requestObject[SEND_MAIL].receiverGuid = receiverGuid;
		requestObject[SEND_MAIL].subject = subject;
		requestObject[SEND_MAIL].body = body;
		socket.sendRequest(requestObject);
	}

	private function onGotNewMail(e:ObjectEvent):void
	{

	}	

	public function markMailAsRead(mailGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[MARK_MAIL_AS_READ] = {};
		requestObject[MARK_MAIL_AS_READ].targetMailGuid = mailGuid;
		socket.sendRequest(requestObject);
	}

	private function onMessageMarkedAsRead(e:ObjectEvent):void
	{

	}

	private function getFriendInfo(friendGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_FRIEND_INFO] = {};
		requestObject[GET_FRIEND_INFO].targetUserGuid = friendGuid;
		socket.sendRequest(requestObject);
	}
}
}