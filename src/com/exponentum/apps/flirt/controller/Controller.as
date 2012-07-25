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

	public static const AUTHENTICATE:String = "Authenticate";
	public static const AUTHENTICATED:String = "Authenticated";

	public static const TOUCH_USER_INFO:String = "TouchUserInfo";
	public static const TOUCH_USER_INFO_RESULT:String = "TouchUserInfoResult";

	public static const JOIN_TO_MAIN_ROOM_QUEUE:String = "JoinMainRoomQueue";
	public static const JOINED_TO_MAIN_ROOM_QUEUE:String = "OnJoinedToMainRoomQueue";
	public static const JOINED_TO_ROOM:String = "OnJoinedToRoom";
	public static const ROOM_DEATH:String = "OnRoomDeath";
	public static const ROOM_USER_LIST_CHANGED:String = "OnRoomUserListChanged";
	public static const ROOM_STATE_CHANGED:String = "OnRoomStateChaned";

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
		socket.addEventListener(JOINED_TO_MAIN_ROOM_QUEUE, onJoinedToMainRoomQueue);
		socket.addEventListener(JOINED_TO_ROOM, onJoinedToRoom);
		socket.addEventListener(ROOM_DEATH, onRoomDeath);
		socket.addEventListener(ROOM_USER_LIST_CHANGED, onRoomUserListChanged);
		socket.addEventListener(ROOM_STATE_CHANGED, onRoomStateChanged);
		socket.addEventListener(GOT_CHAT_MESSAGE_FROM_ROOM, onGotChatMessageFromRoom);
	}

	//------------------------------------------------------------------------------------------------------------------
	// Commands
	//------------------------------------------------------------------------------------------------------------------

	public function authenticate(login:String, password:String):void
	{
		var requestObject:Object = new Object();
		requestObject[AUTHENTICATE] = {};
		requestObject[AUTHENTICATE]["login"] = login;
		requestObject[AUTHENTICATE]["password"] = password;
		socket.sendRequest(requestObject);
	}

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

	public function touchUserInfo(userInfo:Object):void
	{
		var requestObject:Object = new Object();
		requestObject[TOUCH_USER_INFO] = {};
		requestObject[TOUCH_USER_INFO].userInfo = userInfo;
		socket.sendRequest(requestObject);
	}

	//------------------------------------------------------------------------------------------------------------------
	// Handlers
	//------------------------------------------------------------------------------------------------------------------

	private function onGotChatMessageFromRoom(e:ObjectEvent):void
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

	private function onRoomDeath(e:ObjectEvent):void
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

	private function onJoinedToMainRoomQueue(e:ObjectEvent):void
	{
		Cc.log(" ~ " + e.type + " ~ ");
		for (var key:String in e.data)
		{
			Cc.log(key + ":" + e.data[key]);
		}
	}

	private function onAuthenticated(e:ObjectEvent):void
	{
		model.guid = e.data.guid;
	}
}
}