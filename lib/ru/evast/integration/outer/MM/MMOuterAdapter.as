package ru.evast.integration.outer.MM 
{
	import flash.utils.ByteArray;
	import ru.evast.integration.core.IDataAdapter;
	import ru.evast.integration.core.SocialProfileVO;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MMOuterAdapter implements IDataAdapter 
	{
		private var localFlashVars:Object = new Object();
		private var flashVars:Object;
		private var isRest:Boolean = true;
		
		private const apiURL:String = "http:\/\/www.appsmail.ru\/platform\/api";
		private const PRIVATE_KEY:String = "483231fc8971626f9b8b0fa6d26133fd";
		
		private var restLib:RestLibMM;
		
		public function MMOuterAdapter() 
		{			
			localFlashVars["vid"] = "18112732558998376709";				
			localFlashVars["oid"] = "18112732558998376709";		
			localFlashVars["app_id"] = "664085";					
			localFlashVars["authentication_key"] = "0af8b9de0eb939cfab8916294fad16cc";				
			localFlashVars["sig"] = "6b65c8e5875a5520639c07b1e323d71a";		
			localFlashVars["window_id"] = "CometName_00f77cccea7e749dd1cf4fc0a1d486fc";			
			localFlashVars["is_app_user"] = "1";		
			localFlashVars["ext_perm"] = "notifications"; 		
			localFlashVars["session_key"] = "d2b1a23316cd52b0dfeb78b3a0a7138f";
			localFlashVars["referer_type"] = ""; 			
			localFlashVars["referer_id"] = "";
		}
		/*
		 * value="app_id=664085&
		 * exp=1330078152&ext_perm=notifications&
		 * is_app_user=1&
		 * oid=18112732558998376709&
		 * session_key=d2b1a23316cd52b0dfeb78b3a0a7138f&
		 * ss=d41d8cd98f00b204e9800998ecf8427e&
		 * state=&
		 * vid=18112732558998376709&
		 * sig=331980c944b2f0ebdc459bacd090825e
		 * socialNetwork=MM"
		 * 
		 */
		
		public function init(params:Object, local:Boolean):void {
			if (local)
				flashVars = localFlashVars;
			else {	
				flashVars = params;
			}			
			
			restLib = new RestLibMM(apiURL, flashVars['app_id'], flashVars['session_key'], flashVars['vid'], PRIVATE_KEY);
		}
		
		public function InviteFriends(msg:String):void {
			
		}
		public function PostToWall(msg:String, pictureUrl:String):void {
			
		}
		
		public function ShowPayment(count:int, mainName:String, code:int, additional:Object = null):void {
			
		}
		
		public function Me():String {
			return flashVars['vid'] as String;
		}
		public function GetAuthData():String {
			return flashVars['session_key'];
		}
		public function GetReferalId():String {
			return "";
		}
		public function isAppUser():Boolean {
			return true;	//В майле приложения добавляются автоматическе
		}
		public function GetAppId():String {
			return flashVars["app_id"]
		}
		
		/*
		 * Запросы в соц сеть
		 */		
		public function GetAppFriends(onlyUids:Boolean, callback:Function):void {
			if ( isRest ) {
				if(onlyUids)
					restLib.CallMethod( {method: "friends.getAppUsers", ext:0}, callback );
				else
					restLib.CallMethod( { method: "friends.getAppUsers", ext:1 }, function(input:Object): void {
																				callback( TransformProfiles(input) );
																				});
			} else {
				
			}
		}
		public function GetFriends(onlyUids:Boolean, funk:Function):void {
			
		}
		
		public function GetProfiles(uids:String, callback:Function):void {
			if ( isRest ) {
				restLib.CallMethod( { method: "users.getInfo", uids: uids }, 
						function(input:Object) :void{ 	  
							callback( 	TransformProfiles(input)	 ); 	});
			} else {
				
			}
		}
		
		public function UploadToAlbum(blob:ByteArray, name:String):void {
		
		}
		
		public function SendNotification(msg:String, uids:String, pictureUrl:String):void {
			
		}
		
		/*
		 * Вспомогательный функции
		 */		
		private function TransformProfiles(input:Object):Array{
			var ret:Array = new Array();
			
			var curProf:SocialProfileVO;
			
			for each( var a:Object in input) {
				curProf = new SocialProfileVO();
				
				curProf.Uid = a.uid;
				curProf.FirstName = a.first_name;
				curProf.LastName = a.last_name;
				curProf.isMan = (a.sex == "0");
				curProf.UrlProfile = a.link;
				curProf.PicSmall = a.pic_small;
				curProf.PicMedium = a.pic;
				curProf.PicBig = a.pic_big;
				
				ret.push(curProf);
			}
			
			return ret;
		}		
	}

}


	import by.blooddy.crypto.serialization.JSON;
	import com.adobe.crypto.MD5;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	internal class RestLibMM 
	{		
		private var apiURL:String;
		private var appId:String;
		private var sessionKey:String;
		private var myUid:String;
		private var privateKey:String;
		
		private const FORMAT:String = "JSON";
		private var activeRequest:Dictionary = new Dictionary();
		
		public function RestLibMM(apiURL:String, appId:String, sessionKey:String, myUid:String, privateKey:String) {
			
			this.apiURL = apiURL;
			this.appId = appId;
			this.sessionKey = sessionKey;
			this.myUid = myUid;
			this.privateKey = privateKey;			
		}
		
		
		public function CallMethod(params:Object, callback:Function):void {
			var variables : URLVariables = new URLVariables();
			
			params['app_id'] = appId;
			params['session_key'] = sessionKey;
			params['format'] = FORMAT;
			params['secure'] = "0";
			
			var sigKeys : Array = new Array();
			
			for(var key:String in params) {
				variables[key] = params[key];
				var sigKey : String = '';
				sigKey = (key + '=' + params[key]);
				sigKeys.push(sigKey);
			}
			
			variables['sig'] = GenerateSignature(sigKeys);
			
			SendRequest(variables, callback );
		}
		
		public function GenerateSignature(keys : Array) : String {
			var sigKeys : Array = keys.sort();
			var sig : String = '';

			for(var i : int = 0;i < sigKeys.length;i++) {
				sig += sigKeys[i];
			}
			
			return MD5.hash(myUid + sig + privateKey).toLowerCase();
		}
		
		public function SendRequest( vars:URLVariables, callback:Function ):void {
			var rs:RequestStruct = new RequestStruct();
			rs.uLoader = new URLLoader();
			rs.uLoader.addEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.addEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
			rs.callback = callback;
			
			var req:URLRequest = new URLRequest();
			req.url = apiURL;
			req.data = vars;
			req.method = URLRequestMethod.GET;
			
			activeRequest[rs.uLoader] = rs;
			
			rs.uLoader.load(req);
		}
				
		private function onRequsetComplete(evt:Event):void	{
			var rs:RequestStruct = activeRequest[evt.currentTarget as URLLoader];
			rs.uLoader.removeEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.removeEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
			
			delete activeRequest[evt.currentTarget as URLLoader];
			
			//var result:Object = JSON.parse(rs.uLoader.data);
			var result:Object = JSON.decode(rs.uLoader.data);
			rs.callback(result);
		}
		
		private function onRequest_IOError(evt:IOErrorEvent):void {
			var rs:RequestStruct = activeRequest[evt.currentTarget as URLLoader];
			rs.uLoader.removeEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.removeEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
			delete activeRequest[evt.currentTarget as URLLoader];
		}
		
		private function onRequest_SecError(evt:SecurityErrorEvent):void {
			var rs:RequestStruct = activeRequest[evt.currentTarget as URLLoader];
			rs.uLoader.removeEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.removeEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
			delete activeRequest[evt.currentTarget as URLLoader];
		}
		
	}

internal class RequestStruct {
	public function RequestStruct():void {   }
	public var uLoader:URLLoader;
	public var callback:Function;	
}	