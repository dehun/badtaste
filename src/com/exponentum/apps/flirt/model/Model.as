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
	public var view:View;
//----------------------------------------------------------------------------------------------------------------------
//	User Data
//----------------------------------------------------------------------------------------------------------------------
	public var owner:User = new User();
	public var userCache:Dictionary = new Dictionary();
	public var mailbox:Array = [];

	public static const USER_AUTHENTICATED:String = "userAuthenticated";

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
		if(userCache[e.data.infoOwnerGuid] == null) userCache[e.data.infoOwnerGuid] = new User();

		userCache[e.data.infoOwnerGuid].id = e.data.userId;
		userCache[e.data.infoOwnerGuid].guid = e.data.infoOwnerGuid;
		userCache[e.data.infoOwnerGuid].name = e.data.name;
		userCache[e.data.infoOwnerGuid].city = e.data.city;
		userCache[e.data.infoOwnerGuid].photoLink = e.data.pictureUrl;
		userCache[e.data.infoOwnerGuid].profileLink = e.data.profileUrl;
		userCache[e.data.infoOwnerGuid].birthDate = e.data.birthDate;
		userCache[e.data.infoOwnerGuid].sex = e.data.sex;
		userCache[e.data.infoOwnerGuid].isOnline = e.data.isOnline;

		userCache[e.data.infoOwnerGuid].isLinkHidden = e.data.isSocialInfoHidden;
		userCache[e.data.infoOwnerGuid].isAgeHidden = e.data.isBirthDateHidden;
		userCache[e.data.infoOwnerGuid].isCityHidden = e.data.isNameHidden;

		userCache[e.data.infoOwnerGuid].coins = e.data.coins;
		userCache[e.data.infoOwnerGuid].kisses = e.data.kisses;

		dispatchEvent(new ObjectEvent(e.type, userCache[e.data.infoOwnerGuid]));
	}

	public function onGotUserInfoBySocial(e:ObjectEvent):void
	{
		if(userCache[e.data.guid] == null) userCache[e.data.guid] = new User();

		userCache[e.data.guid].id = e.data.ownerSocialId;
		userCache[e.data.guid].guid = e.data.guid;
		userCache[e.data.guid].name = e.data.name;
		userCache[e.data.guid].city = e.data.city;
		userCache[e.data.guid].photoLink = e.data.pictureUrl;
		userCache[e.data.guid].profileLink = e.data.profileUrl;
		userCache[e.data.guid].birthDate = e.data.birthDate;
		userCache[e.data.guid].sex = e.data.sex;
		userCache[e.data.guid].isOnline = e.data.isOnline;

		userCache[e.data.guid].isLinkHidden = e.data.isSocialInfoHidden;
		userCache[e.data.guid].isAgeHidden = e.data.isBirthDateHidden;
		userCache[e.data.guid].isCityHidden = e.data.isNameHidden;

		userCache[e.data.guid].coins = e.data.coins;
		userCache[e.data.guid].kisses = e.data.kisses;

		dispatchEvent(new ObjectEvent(e.type, userCache[e.data.guid]));
	}

	public function onGotVipPoints(e:ObjectEvent):void
	{
		(userCache[e.data.ownerUserGuid] as User).vipPoints = e.data.points;
		dispatchEvent(new ObjectEvent(e.type, userCache[e.data.ownerUserGuid]));
	}

	public function onGotDecorations(e:ObjectEvent):void
	{
		(userCache[e.data.ownerUserGuid] as User).decorations = e.data.decorations;
		dispatchEvent(new ObjectEvent(e.type, userCache[e.data.ownerUserGuid]));
	}

	public function onGotUserFollowers(e:ObjectEvent):void
	{
		(userCache[e.data.ownerUserGuid] as User).followers = e.data.followers;
		(userCache[e.data.ownerUserGuid] as User).rebuyPrice = e.data.rebuyPrice;
		dispatchEvent(new ObjectEvent(e.type, userCache[e.data.ownerUserGuid]));
	}
	public function onGotMyGifts(e:ObjectEvent):void
	{
		owner.presents = e.data.gifts;
		dispatchEvent(new Event(e.type));
	}

	public function onGotUserGifts(e:ObjectEvent):void
	{
		(userCache[e.data.ownerGuid] as User).presents = e.data.gifts;
		dispatchEvent(new Event(e.type));
	}

	public function onGotUserSympathies(e:ObjectEvent):void
	{
		(userCache[e.data.ownerUserGuid] as User).sympathies = e.data.sympathies;
	}

	public function onGotUserRate(e:ObjectEvent):void
	{
		(userCache[e.data.userGuid] as User).userRate = e.data.averateRate;
		(userCache[e.data.userGuid] as User).lastRaters = e.data.lastRaters;
		dispatchEvent(new ObjectEvent(e.type, userCache[e.data.userGuid]));
	}

	public function onGotIsUserRated(e:ObjectEvent):void
	{
		(userCache[e.data.targetUserGuid] as User).isRated = e.data.areRated;
		dispatchEvent(new ObjectEvent(e.type, userCache[e.data.targetUserGuid]));
		trace(e.data.targetUserGuid, e.data.areRated);
	}

	public function onFollowingBought(e:ObjectEvent):void
	{

	}

	public function onGotMailbox(e:ObjectEvent):void
	{
		mailbox = e.data.mails as Array;
		dispatchEvent(new Event(e.type));
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