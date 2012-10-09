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
	private var _owner:User = new User();
	public var userCache:Dictionary = new Dictionary();
	public var mailbox:Array = [];

	public static const USER_AUTHENTICATED:String = "userAuthenticated";

	public function onTouchUserInfoResultHTTP(e:ObjectEvent):void
	{
		if(e.data.result == "ok") Controller.instance.authenticate(_owner.id,  "");
	}

	public function onTouchUserInfoResultSocket(e:ObjectEvent):void
	{

	}

	public function onAuthenticated(e:ObjectEvent):void
	{
		_owner.guid = e.data.guid;
		userCache[_owner.guid] = _owner;
		dispatchEvent(new Event(USER_AUTHENTICATED));
	}

	public function onGotUserInfo(e:ObjectEvent):void
	{
		if(userCache[e.data.infoOwnerGuid] == null) userCache[e.data.infoOwnerGuid] = new User();
		(userCache[e.data.infoOwnerGuid] as User).update(e.data);
		dispatchEvent(new ObjectEvent(e.type, userCache[e.data.infoOwnerGuid]));
	}

	public function onGotUserInfoBySocial(e:ObjectEvent):void
	{
		if(userCache[e.data.guid] == null) userCache[e.data.guid] = new User();
		(userCache[e.data.guid] as User).update(e.data);
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
		_owner.presents = e.data.gifts;
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

	public function onGotMailbox(e:ObjectEvent):void
	{
		mailbox = (e.data.mails as Array).reverse();
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

//----------------------------------------------------------------------------------------------------------------------
//	SERVICE
//----------------------------------------------------------------------------------------------------------------------
	public function onGotCurrentTime(e:ObjectEvent):void
	{

	}

//----------------------------------------------------------------------------------------------------------------------
//	BANK METHODS
//----------------------------------------------------------------------------------------------------------------------
	public function onBankBalanceChecked(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onBankBalanceChanged(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

//----------------------------------------------------------------------------------------------------------------------
//	USER RATE METHODS
//----------------------------------------------------------------------------------------------------------------------

	public function onGotUserRate(e:ObjectEvent):void
	{
		(userCache[e.data.userGuid] as User).userRate = e.data.averateRate;
		(userCache[e.data.userGuid] as User).lastRaters = e.data.lastRaters;
		dispatchEvent(new ObjectEvent(e.type, userCache[e.data.userGuid]));
	}

	public function onGotIsUserRated(e:ObjectEvent):void
	{
		(userCache[e.data.targetUserGuid] as User).isRated = e.data.areRated == "true";
		dispatchEvent(new ObjectEvent(e.type, userCache[e.data.targetUserGuid]));
		trace(e.data.targetUserGuid, e.data.areRated);
	}

	public function onRateUserSuccess(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onRateUserFailure(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onRatePointDeleteSuccess(e:ObjectEvent):void
	{
//		(userCache[e.data.targetUserGuid] as User).isRated = e.data.areRated;
//		dispatchEvent(new ObjectEvent(e.type, userCache[e.data.targetUserGuid]));
//		trace(e.data.targetUserGuid, e.data.areRated);
	}

	public function onRatePointDeleteFailure(e:ObjectEvent):void
	{
//		(userCache[e.data.targetUserGuid] as User).isRated = e.data.areRated;
//		dispatchEvent(new ObjectEvent(e.type, userCache[e.data.targetUserGuid]));
//		trace(e.data.targetUserGuid, e.data.areRated);
	}

//----------------------------------------------------------------------------------------------------------------------
//	BUY LINKED METHODS
//----------------------------------------------------------------------------------------------------------------------
	public function onDecoreBuySuccess(e:ObjectEvent):void
	{
	}

	public function onDecoreBuyFail(e:ObjectEvent):void
	{
	}

	public function onFollowingBought(e:ObjectEvent):void
	{
	}

//----------------------------------------------------------------------------------------------------------------------
//	GIFT METHODS
//----------------------------------------------------------------------------------------------------------------------
	public function onGiftReceivedInGame(e:ObjectEvent):void
	{
	}

	public function onGotGift(e:ObjectEvent):void
	{
	}

//----------------------------------------------------------------------------------------------------------------------
//	ROOMS
//----------------------------------------------------------------------------------------------------------------------
	public function onJoinedToMainRoomQueue(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onJoinedToTaggedRoomQueue(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onJoinedToRoom(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onRoomStateChanged(e:ObjectEvent):void
	{
	}

	public function onRoomUserListChanged(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onRoomIsFull(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onAlreadyInRoom(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onRoomDeath(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	//game
	public function onBottleSwinged(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onKissed(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onRefusedToKiss(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onNewBottleSwinger(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function get owner():User
	{
		if(_owner.guid && userCache[_owner.guid]) return userCache[_owner.guid];
		return _owner
	}

	//jobs
	public function onGotUserCompletedJobs(e:ObjectEvent):void
	{
		if(e.data.ownerGuid == _owner.guid) _owner.jobsCompleted = e.data.jobsCompleted;
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onJobCompleted(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	//room leave
	public function leaveCurrentRoomSuccess(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function leaveCurrentRoomFail(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	//chat
	public function onGotChatMessageFromRoom(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onGotChatMessageFromVIPRoom(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onGotRandomVIP(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onGotRandomChatter(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onVIPPointsBuySuccess(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onVIPPointsBuyFail(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onBuyChatterStatusSuccess(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	public function onBuyChatterStatusFail(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}

	//scores
	public function onGotScores(e:ObjectEvent):void
	{
		dispatchEvent(new ObjectEvent(e.type, e.data));
	}
}
}