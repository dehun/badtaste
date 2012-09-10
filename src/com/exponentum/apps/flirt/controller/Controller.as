package com.exponentum.apps.flirt.controller
{
import com.exponentum.apps.flirt.controller.net.AppSocket;
import com.exponentum.apps.flirt.controller.net.ServerConfig;
import com.exponentum.apps.flirt.controller.net.ServerConnector;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;
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

	private static var _instance:Controller;
	public static function get instance():Controller
	{
		return _instance;
	}

	public function Controller()
	{
		model = Model.instance;
		_instance = this;
		init();
	}

	private function init():void
	{
		socket = new AppSocket(ServerConfig.SERVER, ServerConfig.SOCKET_PORT);

		startListenSocket();
	}

	private function startListenSocket():void
	{
		socket.addEventListener(AUTHENTICATED, model.onAuthenticated);
		socket.addEventListener(GOT_CHAT_MESSAGE_FROM_ROOM, model.onGotChatMessageFromRoom);
		socket.addEventListener(GOT_USER_INFO, model.onGotUserInfo);
		socket.addEventListener(ON_GOT_USER_INFO_BY_SOCIAL_ID, model.onGotUserInfoBySocial);
		socket.addEventListener(TOUCH_USER_INFO_RESULT, model.onTouchUserInfoResultSocket);
		socket.addEventListener(TOUCH_USER_INFO_BY_USER_RESULT, model.touchUserInfoByUserResult);
		socket.addEventListener(ON_GOT_MY_GIFTS, model.onGotMyGifts);
		socket.addEventListener(ON_GOT_USER_GIFTS, model.onGotUserGifts);
		socket.addEventListener(ON_GOT_USER_SYMPATHIES, model.onGotUserSympathies);
		socket.addEventListener(ON_GOT_DECORATIONS, model.onGotDecorations);
		socket.addEventListener(ON_GOT_USER_RATE, model.onGotUserRate);
		socket.addEventListener(ON_GOT_IS_USER_RATED, model.onGotIsUserRated);
		socket.addEventListener(ON_GOT_VIP_POINTS, model.onGotVipPoints);

		//room
		socket.addEventListener(JOINED_TO_MAIN_ROOM_QUEUE, model.onJoinedToMainRoomQueue);
		socket.addEventListener(JOINED_TO_ROOM, model.onJoinedToRoom);
		socket.addEventListener(ROOM_DEATH, model.onRoomDeath);
		socket.addEventListener(ROOM_USER_LIST_CHANGED, model.onRoomUserListChanged);
		socket.addEventListener(ROOM_STATE_CHANGED, model.onRoomStateChanged);
		socket.addEventListener(ROOM_IS_FULL, model.onRoomIsFool);
		socket.addEventListener(ALREADY_IN_THIS_ROOM, model.onAlreadyInRoom);

		//game
		socket.addEventListener(BOTTLE_SWINGED, model.onBottleSwinged);
		socket.addEventListener(KISSED, model.onKissed);
		socket.addEventListener(REFUSED_TO_KISS, model.onRefusedToKiss);
		socket.addEventListener(NEW_BOTTLE_SWINGER, model.onNewBottleSwinger);

		//mail
		socket.addEventListener(ON_GOT_MAILBOX, model.onGotMailbox);
		socket.addEventListener(ON_GOT_NEW_MAIL, model.onGotNewMail);

		//followers
		socket.addEventListener(ON_GOT_USER_FOLLOWERS, model.onGotUserFollowers);
		socket.addEventListener(ON_FOLLOWING_BOUGHT, model.onFollowingBought);

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
	public static const GET_USER_GIFTS:String = "GetUserGifts";
	public static const ON_GOT_USER_GIFTS:String = "OnGotUserGifts";
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
	public static const IS_USER_RATED:String = "AreUserRated";
	public static const RATE_USER:String = "RateUser";

	public static const ON_GOT_IS_USER_RATED:String = "OnGotAreUserRated";


	public static const GET_FRIEND_INFO:String = "GetUserInfo";
	public static const GET_VIP_POINTS:String = "GetVipPoints";
	public static const ON_GOT_VIP_POINTS:String = "OnGotVipPoints";

	public static const GET_USER_INFO_BY_SOCIAL_ID:String = "GetUserInfoBySocialId";
	public static const ON_GOT_USER_INFO_BY_SOCIAL_ID:String = "OnGotUserInfoBySocialIdSuccess";

	public function userLogin():void//TODO: not only owner support
	{
		touchUserInfo('{"userInfo" : { "UserInfo" : ' +
				'{"userId" : "' + model.owner.id + '",' +
				'"name" : "' + model.owner.name + '",' +
				'"profileUrl" : "' + model.owner.profileLink + '",' +
				'"isMan" : "' + model.owner.sex + '",' +
				'"birthDate" : "' + model.owner.birthDate + '",' +
				'"city" : "' + model.owner.city + '",' +
				'"avatarUrl" : "' + model.owner.photoLink + '", ' +
				'"hideSocialInfo":"0", ' +
				'"hideBirthDate":"0", ' +
				'"hideCity":"0"}}}');
	}

	public function touchUserInfo(userInfo:String):void
	{
		ServerConnector.instance.addEventListener(TOUCH_USER_INFO_RESULT, model.onTouchUserInfoResultHTTP);
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
		if(model.userCache[guid]) {
			model.dispatchEvent(new ObjectEvent(GOT_USER_INFO, model.userCache[guid]));
			return;
		}
		var requestObject:Object = new Object();
		requestObject[GET_USER_INFO] = {};
		requestObject[GET_USER_INFO].targetUserGuid = guid;
		socket.sendRequest(requestObject);
	}

	public function getUserInfoBySocialId(sid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_USER_INFO_BY_SOCIAL_ID] = {};
		requestObject[GET_USER_INFO_BY_SOCIAL_ID].targetSocialId = sid;
		socket.sendRequest(requestObject);
	}

	public function getUserSympathies(guid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_USER_SYMPATHIES] = {};
		requestObject[GET_USER_SYMPATHIES].targetUserGuid = guid;
		socket.sendRequest(requestObject);
	}

	public function getMyGifts():void
	{
		var requestObject:Object = new Object();
		requestObject[GET_MY_GIFTS] = {};
		socket.sendRequest(requestObject);
	}

	public function getUserGifts(userGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_USER_GIFTS] = {};
		requestObject[GET_USER_GIFTS].targetUserGuid = userGuid;
		socket.sendRequest(requestObject);
	}

	public function getUserFollowers(userGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_USER_FOLLOWERS] = {};
		requestObject[GET_USER_FOLLOWERS].targetUserGuid = userGuid;
		socket.sendRequest(requestObject);
	}

	public function getDecorationFor(userGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_DECORATION_FOR] = {};
		requestObject[GET_DECORATION_FOR].targetUserGuid = userGuid;
		socket.sendRequest(requestObject);
	}

	public function getUserRate(userGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_USER_RATE] = {};
		requestObject[GET_USER_RATE].targetUserGuid = userGuid;
		socket.sendRequest(requestObject);
	}

	public function isUserRated(userGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[IS_USER_RATED] = {};
		requestObject[IS_USER_RATED].targetUserGuid = userGuid;
		socket.sendRequest(requestObject);
	}

	public function rateUser(userGuid:String, rate:String):void
	{
		var requestObject:Object = new Object();
		requestObject[RATE_USER] = {};
		requestObject[RATE_USER].rate = rate;
		requestObject[RATE_USER].targetUserGuid = userGuid;
		socket.sendRequest(requestObject);
	}

	public function getVipPoints(userGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[GET_VIP_POINTS] = {};
		requestObject[GET_VIP_POINTS].targetUserGuid = userGuid;
		socket.sendRequest(requestObject);
	}

	public function buyFollowing(userGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[BUY_FOLLOWING] = {};
		requestObject[BUY_FOLLOWING].targetUserGuid = userGuid;
		socket.sendRequest(requestObject);
	}

	public function buyDecore(decoreGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[BUY_DECORE] = {};
		requestObject[BUY_DECORE].decoreGuid = decoreGuid;
		socket.sendRequest(requestObject);
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

	public function sendMail(receiverGuid:String, subject:String, body:String):void
	{
		var requestObject:Object = new Object();
		requestObject[SEND_MAIL] = {};
		requestObject[SEND_MAIL].receiverGuid = receiverGuid;
		requestObject[SEND_MAIL].subject = subject;
		requestObject[SEND_MAIL].body = body;
		socket.sendRequest(requestObject);
	}

	public function markMailAsRead(mailGuid:String):void
	{
		var requestObject:Object = new Object();
		requestObject[MARK_MAIL_AS_READ] = {};
		requestObject[MARK_MAIL_AS_READ].targetMailGuid = mailGuid;
		socket.sendRequest(requestObject);
	}
}
}