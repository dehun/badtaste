package ru.evast.integration.core 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Andrey Pavlov. skype ctrl_break. email: obsidium@yandex.ru
	 */
	public interface IDataAdapter 
	{
		function init(params:Object, local:Boolean):void;
		
		function InviteFriends(msg:String):void 
		function ShowPayment(count:int, mainName:String, code:int, additional:Object = null):void 
		
		function Me():String;
		function GetAuthData():String;
		function GetReferalId():String;
		function isAppUser():Boolean; 
		function GetAppId():String;
		
		function GetAppFriends(onlyUids:Boolean, callback:Function):void;
		function GetFriends(onlyUids:Boolean, callback:Function):void;
		function GetProfiles(uids:String, callback:Function):void;
		function UploadToAlbum(blob:ByteArray, name:String):void;
		function PostToWall(msg:String, pictureUrl:String):void;
		function SendNotification(msg:String, uid:String, pictureUrl:String):void;
	}
	
}