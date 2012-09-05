package com.exponentum.apps.flirt.model
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.View;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filters.ColorMatrixFilter;
import flash.utils.Dictionary;

public class Model extends EventDispatcher
{

//----------------------------------------------------------------------------------------------------------------------
//	Instantination
//----------------------------------------------------------------------------------------------------------------------
	private static var _instance:Model;
	public static function get instance():Model
	{
		if(!_instance)
			_instance = new Model();

		return _instance;
	}
	
	public function Model()
	{
		_instance = this;
	}

//----------------------------------------------------------------------------------------------------------------------
//	Executive Code
//----------------------------------------------------------------------------------------------------------------------
	public static const USER_AUTHENTICATED:String = "userAuthenticated";
	public static const USER_PROFILE_UPDATED:String = "userProfileUpdated";

	public static const MAILBOX:String = "mailbox";
	public var view:View;
//----------------------------------------------------------------------------------------------------------------------
//	User Data
//----------------------------------------------------------------------------------------------------------------------
	public var owner:User = new User();
	public var userCache:Dictionary = new Dictionary();
	public var mailbox:Array = [];

	public function onTouchUserInfoResultHTTP(e:ObjectEvent):void
	{
		if(e.data.result == "ok") Controller.instance.authenticate(owner.id,  "");
	}

	public function onTouchUserInfoResultSocket(e:ObjectEvent):void
	{

	}

	public function onAuthenticated(e:ObjectEvent):void
	{
		owner.guid = e.data.guid;
		userCache[owner.guid] = owner;
		dispatchEvent(new Event(USER_AUTHENTICATED));
	}

	public function onGotUserInfo(e:ObjectEvent):void
	{
		if(userCache[e.data.ownerUserGuid] == null) userCache[e.data.ownerUserGuid] = new User();

		userCache[e.data.ownerUserGuid].id = e.data.userId;
		userCache[e.data.ownerUserGuid].guid = e.data.ownerUserGuid;
		userCache[e.data.ownerUserGuid].name = e.data.name;
		userCache[e.data.ownerUserGuid].city = e.data.city;
		userCache[e.data.ownerUserGuid].photoLink = e.data.pictureUrl;
		userCache[e.data.ownerUserGuid].profileLink = e.data.profileUrl;
		userCache[e.data.ownerUserGuid].birthDate = e.data.birthDate;
		userCache[e.data.ownerUserGuid].sex = e.data.sex;
		userCache[e.data.ownerUserGuid].isOnline = e.data.isOnline;

		userCache[e.data.ownerUserGuid].isLinkHidden = e.data.isSocialInfoHidden;
		userCache[e.data.ownerUserGuid].isAgeHidden = e.data.isBirthDateHidden;
		userCache[e.data.ownerUserGuid].isCityHidden = e.data.isNameHidden;

		userCache[e.data.ownerUserGuid].coins = e.data.coins;
		userCache[e.data.ownerUserGuid].kisses = e.data.kisses;

		dispatchEvent(new ObjectEvent(USER_PROFILE_UPDATED, userCache[e.data.infoOwnerGuid]));
	}

	public function onGotMyGifts(e:ObjectEvent):void
	{
		owner.presents = e.data.gifts;
		dispatchEvent(new ObjectEvent(USER_PROFILE_UPDATED, owner));
	}

	public function onGotUserSympathies(e:ObjectEvent):void
	{
		(userCache[e.data.ownerUserGuid] as User).sympathies = e.data.sympathies;
		dispatchEvent(new ObjectEvent(USER_PROFILE_UPDATED, userCache[e.data.ownerUserGuid]));
	}

	public function onGotUserFollowers(e:ObjectEvent):void
	{
		(userCache[e.data.ownerUserGuid] as User).followers = e.data.followers;
		(userCache[e.data.ownerUserGuid] as User).rebuyPrice = e.data.rebuyPrice;
		dispatchEvent(new ObjectEvent(USER_PROFILE_UPDATED, userCache[e.data.ownerUserGuid]));
	}

	public function onGotDecorations(e:ObjectEvent):void
	{
		(userCache[e.data.ownerUserGuid] as User).decorations = e.data.decorations;
		dispatchEvent(new ObjectEvent(USER_PROFILE_UPDATED, userCache[e.data.ownerUserGuid]));
	}

	public function onGotUserRate(e:ObjectEvent):void
	{
		(userCache[e.data.userGuid] as User).userRate = e.data.averateRate;
		(userCache[e.data.userGuid] as User).lastRaters = e.data.lastRaters;
		dispatchEvent(new ObjectEvent(USER_PROFILE_UPDATED, userCache[e.data.ownerUserGuid]));
	}

	public function onGotVipPoints(e:ObjectEvent):void
	{
		(userCache[e.data.ownerUserGuid] as User).vipPoints = e.data.points;
		dispatchEvent(new ObjectEvent(USER_PROFILE_UPDATED, userCache[e.data.ownerUserGuid]));
	}

	public function onFollowingBought(e:ObjectEvent):void
	{

	}

	public function onGotMailbox(e:ObjectEvent):void
	{
		mailbox = e.data.mails as Array;
		dispatchEvent(new Event(MAILBOX));
	}

	public function onGotNewMail(e:ObjectEvent):void
	{

	}

	public function onMessageMarkedAsRead(e:ObjectEvent):void
	{

	}

	public function touchUserInfoByUserResult(e:ObjectEvent):void
	{

	}

	//room
	public function onJoinedToMainRoomQueue(e:ObjectEvent):void
	{
	}

	public function onJoinedToRoom(e:ObjectEvent):void
	{
	}

	public function onRoomStateChanged(e:ObjectEvent):void
	{
	}

	public function onRoomUserListChanged(e:ObjectEvent):void
	{
	}

	public function onRoomIsFull(e:ObjectEvent):void
	{
	}

	public function onRoomIsFool(e:ObjectEvent):void
	{
	}

	public function onAlreadyInRoom(e:ObjectEvent):void
	{
	}

	public function onRoomDeath(e:ObjectEvent):void
	{
	}

	//chat
	public function onGotChatMessageFromRoom(e:ObjectEvent):void
	{
	}

	//game
	public function onBottleSwinged(e:ObjectEvent):void
	{

	}

	public function onKissed(e:ObjectEvent):void
	{

	}

	public function onRefusedToKiss(e:ObjectEvent):void
	{

	}

	public function onNewBottleSwinger(e:ObjectEvent):void
	{

	}
}
}