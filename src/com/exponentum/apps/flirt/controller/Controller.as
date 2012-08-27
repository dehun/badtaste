package com.exponentum.apps.flirt.controller
{
import com.exponentum.apps.flirt.controller.net.AppSocket;
import com.exponentum.apps.flirt.controller.net.ServerConfig;
import com.exponentum.apps.flirt.controller.net.ServerConnector;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Model;
import com.junkbyte.console.Cc;

import flash.events.Event;

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

	public function Controller(aModel:Model)
	{
		model = aModel;

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
	public static const GET_DECORATION_FOR:String = "GetDecorationFor";
	public static const ON_GOT_DECORATIONS:String = "OnGotDecorations";

	public function userLogin():void
	{
		touchUserInfo('{"userInfo" : { "UserInfo" : ' +
				'{"userId" : "' + model.owner.id + '",' +
				'"name" : "' + model.owner.name + '",' +
				'"profileUrl" : "' + model.owner.profileLink + '",' +
				'"isMan" : "' + model.owner.sex + '",' +
				'"birthDate" : "' + model.owner.birthDate + '",' +
				'"city" : "' + model.owner.city + '",' +
				'"avatarUrl" : "' + model.owner.photoLink + '"}}}');
	}

	public function touchUserInfo(userInfo:String):void
	{
		ServerConnector.instance.addEventListener(TOUCH_USER_INFO_RESULT, onTouchUserInfoResult);
		ServerConnector.call(TOUCH_USER_INFO, userInfo);
	}

	private function onTouchUserInfoResult(e:ObjectEvent):void
	{
		authenticate(model.owner.id, "");
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
		//getUserSympathies(model.owner.guid);
		//getMyGifts();
		getUserFollowers(model.owner.guid);
		//getDecorationFor(model.owner.guid);
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

	private function getDecorationFor(userGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_DECORATION_FOR] = {};
		requestObject[GET_DECORATION_FOR].targetUserGuid = userGuid;
		socket.sendRequest(requestObject);
	}

	private function buyDecore(decoreGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[BUY_DECORE] = {};
		requestObject[BUY_DECORE].decoreGuid = decoreGuid;
		socket.sendRequest(requestObject);
	}

	private function onGotDecorations(e:ObjectEvent):void
	{

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

	private function checkMailbox():void
	{
		var requestObject:Object = new Object();
		requestObject[CHECK_MAILBOX] = {};
		socket.sendRequest(requestObject);
	}

	private function onGotMailbox(e:ObjectEvent):void
	{

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


}
}