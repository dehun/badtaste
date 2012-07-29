package com.exponentum.apps.flirt.controller
{
import com.exponentum.apps.flirt.controller.net.AppSocket;
import com.exponentum.apps.flirt.controller.net.ServerConfig;
import com.exponentum.apps.flirt.controller.net.ServerConnector;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Model;
import com.junkbyte.console.Cc;

import flash.events.Event;

public class Controller
{
	private var model:Model;

	//user
	public static const AUTHENTICATE:String = "Authenticate";
	public static const AUTHENTICATED:String = "Authenticated";
	public static const TOUCH_USER_INFO:String = "TouchUserInfo";
	public static const TOUCH_USER_INFO_RESULT:String = "TouchUserInfoResult";
	public static const GET_USER_INFO:String = "GetUserInfo";
	public static const GOT_USER_INFO:String = "OnGotUserInfo";
	public static const TOUCH_USER_INFO_BY_USER:String = "TouchUserInfoByUser";
	public static const TOUCH_USER_INFO_BY_USER_RESULT:String = "TouchUserInfoByUserResult";

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
		socket.addEventListener(TOUCH_USER_INFO_RESULT, onTouchUserInfoResult);
		socket.addEventListener(GOT_USER_INFO, onGotUserInfo);
		socket.addEventListener(TOUCH_USER_INFO_BY_USER_RESULT, touchUserInfoByUserResult);

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

	}

	//------------------------------------------------------------------------------------------------------------------
	// Commands
	//------------------------------------------------------------------------------------------------------------------
	//user
	public function touchUserInfo(userInfo:String):void
	{
		ServerConnector.call(TOUCH_USER_INFO, userInfo);
	}

	public function authenticate(login:String, password:String):void
	{
		var requestObject:Object = new Object();
		requestObject[AUTHENTICATE] = {};
		requestObject[AUTHENTICATE]["login"] = login;
		requestObject[AUTHENTICATE]["password"] = password;
		socket.sendRequest(requestObject);
	}

	public function getUserInfo(guid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_USER_INFO] = {};
		requestObject[GET_USER_INFO].targetUserGuid = guid;
		socket.sendRequest(requestObject);
	}

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
	private function onAuthenticated(e:ObjectEvent):void
	{
		model.owner.guid = e.data.guid;
	}

	private function onTouchUserInfoResult(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	private function onGotUserInfo(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	private function touchUserInfoByUserResult(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	//room
	private function onJoinedToMainRoomQueue(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	private function onJoinedToRoom(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	private function onRoomStateChanged(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	private function onRoomUserListChanged(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	private function onRoomIsFull(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	private function onRoomIsFool(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	private function onAlreadyInRoom(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	private function onRoomDeath(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	//chat
	private function onGotChatMessageFromRoom(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
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
}
}