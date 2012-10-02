package ru.evast.integration.inner.VK 
{
	import adobe.utils.CustomActions;

import com.adobe.serialization.json.JSON;
import com.exponentum.apps.flirt.model.Config;

import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import ru.evast.integration.core.IDataAdapter;
	import ru.evast.integration.core.IntegrationEvent;
	import ru.evast.integration.core.SocialProfileVO;
	import ru.evast.integration.inner.VK.js.VKExternal;
	import ru.evast.integration.inner.VK.rest.APIConnection;
	import ru.evast.integration.IntegrationProxy;
	
	/**
	 * ...
	 * @author Andrey Pavlov. skype ctrl_break. email: obsidium@yandex.ru
	 */
	/*
	 * Класс написан для работы в iframe
	 */
	public class VKInnerAdapter implements IDataAdapter 
	{
		private var _localFlashVars:Object = new Object();
		private var _flashVars:Object;
		
		private var _apiLib:APIConnection;
		
		private var apiResult:XML;
		
		private var notification:NotificationInfo = new NotificationInfo();
		
		//private const EXTCALL_SETTINGS_CHANGE:String = "onSettingsChanged";
		//private const EXTCALL_BALANCE_CHANGE:String = "onBalanceChanged";
		
		public function VKInnerAdapter() 
		{
			//Bronezoid
			if(Config.TESTER == 0)//Bronezoid
			{
				_localFlashVars["api_id"] = "3047691";
				_localFlashVars["api_url"] = "http://api.vk.com/api.php";
				_localFlashVars["auth_key"] = "9497b71d9c83ba1807a99c18511791c8";
				_localFlashVars["is_app_user"] = "1";
				_localFlashVars["referrer"] = "profile";
				_localFlashVars["secret"] = "7ec9220aa3";
				_localFlashVars["sid"] = "aa2f93b1b8edea43def66a8834807391b74ed0aba093e18949efcff217d7fa";
				_localFlashVars["user_id"] = "171082395";
				_localFlashVars["viewer_id"] = "171082395";
				_localFlashVars["api_result"] = "";
			}else{//Alex
				_localFlashVars["api_id"] = "3047691";
				_localFlashVars["api_url"] = "http://api.vk.com/api.php";
				_localFlashVars["auth_key"] = "aab191f4c481f6543fe74d445d8bd51c";
				_localFlashVars["is_app_user"] = "1";
				_localFlashVars["referrer"] = "profile";
				_localFlashVars["secret"] = "55737fd341";
				_localFlashVars["sid"] = "5a4eeab0c63f11aef100bf2db59ff723c584ed373a9be0fd258889f105caac";
				_localFlashVars["user_id"] = "8532894";
				_localFlashVars["viewer_id"] = "8532894";
				_localFlashVars["api_result"] = "";
			}
		}

		public function init(params:Object, local:Boolean):void {
			if (local)
				_flashVars = _localFlashVars;
			else {
				//ExternalInterface.addCallback(EXTCALL_SETTINGS_CHANGE, onUserBalanceLoaded);
				_flashVars = params;
			}
				
			_apiLib = new APIConnection(_flashVars);
			_apiLib.forceDirectApiAccess(true);
			
			if ( ExternalInterface.available ) {
				ExternalInterface.addCallback("BalanceUpdate", onUserBalanceLoaded);
			}
			
			if ( _flashVars["api_result"] == null ) return;
			try {
				apiResult = new XML( _flashVars["api_result"] );
				IntegrationProxy.dispatcher.dispatchEvent( new IntegrationEvent(IntegrationEvent.USER_BALANCE_CHANGE, int(int(apiResult.balance) / 100)));
			} catch (err:Error) {    }
		}
		
		public function InviteFriends(msg:String):void {
			ExternalInterface.call(" VK.External.showInviteBox() ");
		}
		public function PostToWall(msg:String, pictureUrl:String):void {
			notification.msg = msg;
			notification.uid = Me();
			notification.picture = pictureUrl;
			_apiLib.api("photos.getWallUploadServer", { }, onWallUploadServer, onApiError);
		}
		public function ShowPayment(count:int, mainName:String, code:int, additional:Object = null):void {
			ExternalInterface.call(" VK.External.showPaymentBox(" + count + ") ");
		}
		
		public function Me():String {
			return _flashVars["viewer_id"];
		}
		public function GetAuthData():String {
			return _flashVars["auth_key"];
		}
		public function GetReferalId():String {
			if (_flashVars["user_id"] == "0" || _flashVars["user_id"] == _flashVars["viewer_id"]) return "";
			return _flashVars["user_id"];
		}
		public function isAppUser():Boolean {
			return _flashVars["is_app_user"];
		}
		public function GetAppId():String {
			return _flashVars["api_id"];
		}
		
		public function GetAppFriends(onlyUids:Boolean, callback:Function):void {
			if (onlyUids) {
				_apiLib.api("friends.getAppUsers", { }, 
								function( o:Object ):void { callback.call( null, o ); }, 
								onApiError );
			} else
				_apiLib.api("friends.getAppUsers", { }, 
								function( o:Object ):void { GetProfiles( o.join(","), callback ); }, //!!! Не загрузит более 1000 друзей
								onApiError );
		}
		
		public function GetFriends(onlyUids:Boolean, callback:Function):void {
			if (onlyUids) {
				_apiLib.api("friends.get", { }, 
								function( o:Object ):void { callback.call( null, o ); }, 
								onApiError );
			} else
				/*_apiLib.api("friends.get", { fields:"uid,first_name,last_name,sex,photo,photo_medium,photo_big,bdate,city,country" }, 
								function( o:Object ):void { callback.call( null, ( o ) ); }, 
								onApiError );*/
				_apiLib.api("friends.get", { }, 
								function( o:Object ):void { var str:String;  for each (var item:Object in o) str += item +",";  GetProfiles(str, callback); }, 
								onApiError );				
		}
		
		public function GetProfiles(uids:String, callback:Function):void {
			if(uids != "")
			_apiLib.api("getProfiles", 
						{ fields:"uid,first_name,last_name,sex,photo,photo_medium,photo_big,bdate,city,country", uids:uids }, 
						function(input:Object):void 
									{ TransformProfiles(input, callback); }, 
						onApiError );
			else callback([]);

		}
		
		
		public function UploadToAlbum(blob:ByteArray, name:String):void{
			
		}
		
		public function SendNotification(msg:String, uid:String, pictureUrl:String):void {
			notification.msg = msg;
			notification.uid = uid;
			notification.picture = pictureUrl;
			_apiLib.api("photos.getWallUploadServer", { }, onWallUploadServer, onApiError);
		}
		
		private function onWallUploadServer(o:Object):void {
			var ldr:URLLoader = new URLLoader();
			var vars:URLVariables = new URLVariables();
			var request:URLRequest = new URLRequest("http://188.72.202.193:8089/VKImageUpload.ashx");
			vars.src = notification.picture;
			vars.dst = o.upload_url;
			request.data = vars;
			
			ldr.load(request);
			ldr.addEventListener(Event.COMPLETE, onUploadPhotoComplete);
		}
		private function onUploadPhotoComplete( evt:Event ):void {
			var ldr:URLLoader = evt.target as URLLoader;
			ldr.removeEventListener(Event.COMPLETE, onUploadPhotoComplete);
			
			//var result:Object = JSON.parse(ldr.data as String);
			var result:Object = JSON.decode(ldr.data as String);	
			
			_apiLib.api("photos.saveWallPhoto", { photo:result.photo, hash:result.hash, server:result.server, message:notification.msg, uid:notification.uid }, 
				onPhotoSaved, onApiError);
		}
		
		private function onPhotoSaved( o:Object ):void {
			var vkExternal:VKExternal = new VKExternal();
			vkExternal.getAction("wall.post", { owner_id:notification.uid, message:notification.msg, attachment:o[0].id });
		}
		
		/*
		 * Методы не включённые в интерфейс IDataAdapter
		 */		
		public function GetBalance():void {
			_apiLib.api("getUserBalance", { }, onUserBalanceLoaded, onApiError);
		}		
		
		
		private function TransformProfiles(input:Object, callback:Function):void{
			var ret:Array = new Array();
			
			var curProf:SocialProfileVO;
			var cityIds:String= "";
			
			for each( var a:Object in input) {
				curProf = new SocialProfileVO();
				
				curProf.Uid = a.uid;
				curProf.FirstName = a.first_name;
				curProf.LastName = a.last_name;
				curProf.isMan = (a.sex == "2");
				curProf.UrlProfile = "http://vk.com/id" + a.uid;
				curProf.PicSmall = a.photo;
				curProf.PicMedium = a.photo_medium;
				curProf.PicBig = a.photo_big;
				
				//записываем дату рождения
				if (a.bdate == null)
					curProf.BirthDate = "";
				else
					curProf.BirthDate = a.bdate;
				
				//записываем город
				if (a.city == null)
				curProf.City = "";
					else
				curProf.City = a.city;
					
				if (cityIds == "" )
					cityIds += a.city;
				else 
					cityIds += "," + a.city;
				
				//записываем страну	
				if (a.country == null)
					curProf.Country = "";
				else
					curProf.Country = a.country;
					
				ret.push(curProf);
			}
			
			_apiLib.api("places.getCityById", { cids:cityIds }, function (result:Object):void 
			{ 
				for (var i:int = 0 ; i < ret.length; i++)
				{
					for each (var item:Object in result)
					{
						if (ret[i].City == item.cid)
							ret[i].City = item.name;	
							
						if (ret[i].City == null)
							ret[i].City = "";
					}
				}
				callback.call(null, ret );
			}, 
			onApiError);
			
			//return ret;	
		}
		
		private function onUserBalanceLoaded(data:int):void {
			IntegrationProxy.dispatcher.dispatchEvent( new IntegrationEvent(IntegrationEvent.USER_BALANCE_CHANGE, int(int(data) / 100)));
		}
		
		private function onApiError(o:Object):void {

			trace("VKDataAdapter Api Error");
		}
	}

}

internal class NotificationInfo{
	public var msg:String;
	public var uid:String;
	public var picture:String;
}