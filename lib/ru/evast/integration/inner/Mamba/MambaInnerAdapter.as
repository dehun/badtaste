package ru.evast.integration.inner.Mamba 
{
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import ru.evast.integration.core.IDataAdapter;
	import com.adobe.crypto.MD5;
	import ru.evast.integration.core.SocialDefaults;
	import ru.evast.integration.core.SocialProfileVO;
	
	/**
	 * ...
	 * @author Pavlov Andrey; mail: obsidium@yandex.ru skype: ctrl_break
	 */
	public class MambaInnerAdapter implements IDataAdapter 
	{
		private var localFlashVars:Object = new Object();
		private var flashVars:Object;
		
		private var RestLib:RestLibMamba;
		private var authKey:String;
		
		private const private_key:String = "K40WOQStK7t1nnxr1rzK";				// Секретный ключ для связи с сервером (клиент-сервер)
		
		private var apiURL:String = "http://api.aplatform.ru/";
		//"app_id=380&oid=757908408&auth_key=87a6cf07bd301274cc1cb590ad728ef6&sid=7816bf47388dd5c2ff3b5e44b6968d20&partner_url=http%3A%2F%2Fmamba.ru%2F"
		public function MambaInnerAdapter() 
		{
			localFlashVars["app_id"] = "380";				
			localFlashVars["oid"] = "757908408";
			localFlashVars["sid"] = "7816bf47388dd5c2ff3b5e44b6968d20";
			localFlashVars["auth_key"] = "87a6cf07bd301274cc1cb590ad728ef6";		
			//localFlashVars["fav_id"] = "";
			localFlashVars["partner_url"] = "http://mamba.ru/";			
			
		}
		
		public function init(params:Object, local:Boolean):void 
		{
			if (local)
				flashVars = localFlashVars;
			else	
			{
				flashVars = params;
			}
			
			var sigKey : String = '';
			var sigKeys:Array = new Array();
			for(var key:String in flashVars) {
				if ( key == "auth_key" || key == "v" ) continue;
				sigKey = (key + '=' + flashVars[key]);
				sigKeys.push(sigKey);
			}
			
			sigKeys = sigKeys.sort();
			authKey = sigKeys.join("") + "|" + flashVars["auth_key"];
			
			RestLib = new RestLibMamba(apiURL, flashVars["app_id"], flashVars["oid"], flashVars["sid"], private_key);
		}
		
		public function InviteFriends(msg:String):void 
		{
			ExternalInterface.call("mamba.init(function(){ mamba.method('openContactRequestLayer', '" + msg + "', '') })");
		}
		
		public function ShowPayment(count:int, mainName:String, code:int, additional:Object = null):void 
		{
			ExternalInterface.call("mamba.init(function(){ mamba.method('openPaymentLayer', " + flashVars["app_id"]  +" , " + count.toString() + ", " + code.toString() + ") })");
		}
		
		public function Me():String 
		{
			return flashVars["oid"];
		}
		
		public function GetAuthData():String 
		{
			return authKey;
		}
		
		public function GetReferalId():String 
		{
			if (flashVars["fav_id"] == null ) return "";
			else return flashVars["fav_id"];
		}
		
		public function isAppUser():Boolean 
		{
			return true;
		}
		
		public function GetAppId():String 
		{
			return flashVars["app_id"];
		}
		
		public function GetAppFriends(onlyUids:Boolean, callback:Function):void {
			if ( onlyUids ) {
				RestLib.CallMethod( { method:"contacts.getContactList", "limit": 100 },
					function (input:Object):void	{
						callback.call(null, TransformAppContactsIds( input ) );
					});
			} else {
				RestLib.CallMethod( { method:"contacts.getContactList", "limit": 100 },
					function (input:Object):void	{
						callback.call(null, TransformAppContacts( input ) );
					});
			}
		}
		
		public function GetFriends(onlyUids:Boolean, callback:Function):void {
			if ( onlyUids ) {
				RestLib.CallMethod( { method:"contacts.getContactList", "limit": 100, ids_only:1 },
					function (input:Object):void	{
						callback.call( null, input.data.contacts );
					});
			} else {
				RestLib.CallMethod( { method:"contacts.getContactList", "limit": 100 },
					function (input:Object):void	{
						callback.call( null, TransformContacts( input ) );
					});
			}
		}
		
		public function GetProfiles(uids:String, callback:Function):void {
			RestLib.CallMethod( { method:"anketa.getInfo", oids:uids },
							function(input:Object) :void{ 	  
										callback( 	TransformProfiles(input)	 ); 	});
		}
		
		public function UploadToAlbum(blob:ByteArray, name:String):void {
			
		}
		
		public function SendNotification(msg:String, uids:String, pictureUrl:String):void {
			
		}
		
		public function PostToWall(msg:String, pictureUrl:String):void 
		{
			RestLib.CallMethod( { method: "achievement.set", text:msg } ,Stub);
		}
		
		private function TransformProfiles(input:Object):Array {
			var ret:Array = new Array();
			
			var curProf:SocialProfileVO;
			
			for each( var a:Object in input.data) {
				curProf = new SocialProfileVO();
				
				curProf.Uid = a.info.oid;
				curProf.FirstName = a.info.name;
				curProf.LastName = "";
				curProf.isMan = (a.info.sex == "M");
				curProf.UrlProfile = a.info.anketa_link;
				if ( a.info.small_photo_url == "" )
					curProf.PicSmall = a.info.small_photo_url;
				else 
					curProf.PicSmall = SocialDefaults.DefaultPickSmall;
				
				if ( a.info.medium_photo_url == "" ) {
					curProf.PicMedium = SocialDefaults.DefaultPickMedium;
					curProf.PicBig = 	SocialDefaults.DefaultPickBig;
				} else {
					curProf.PicMedium = a.info.medium_photo_url;
					curProf.PicBig = a.info.medium_photo_url;
				}
				
				ret.push(curProf);
			}
			
			return ret;
		}
		
		private function TransformContacts(input:Object):Array {
			var ret:Array = new Array();
			
			var curProf:SocialProfileVO;
			
			for each( var a:Object in input.data.contacts) {
				curProf = new SocialProfileVO();
				
				curProf.Uid = a.info.oid;
				curProf.FirstName = a.info.name;
				curProf.LastName = "";
				curProf.isMan = (a.info.sex == "M");
				curProf.UrlProfile = a.info.anketa_link;
				curProf.PicSmall = a.info.small_photo_url;
				curProf.PicMedium = a.info.medium_photo_url;
				curProf.PicBig = a.info.medium_photo_url;
				
				ret.push(curProf);
			}
			
			return ret;
		}
		
		private function TransformAppContacts(input:Object):Array {
			var ret:Array = new Array();
			
			var curProf:SocialProfileVO;
			
			for each( var a:Object in input.data.contacts) {
				if (a.info.is_app_user == 0 ) continue;
				
				curProf = new SocialProfileVO();
				
				curProf.Uid = a.info.oid;
				curProf.FirstName = a.info.name;
				curProf.LastName = "";
				curProf.isMan = (a.info.sex == "M");
				curProf.UrlProfile = a.info.anketa_link;
				curProf.PicSmall = a.info.small_photo_url;
				curProf.PicMedium = a.info.medium_photo_url;
				curProf.PicBig = a.info.medium_photo_url;
				
				ret.push(curProf);
			}
			
			return ret;
		}
		
		private function TransformAppContactsIds(input:Object):Array {
			var ret:Array = new Array();
			
			for each( var a:Object in input.data.contacts) {
				if (a.info.is_app_user == 0 ) continue;				
				ret.push(a.info.oid);
			}
			
			return ret;
		}
		
		private function Stub(input:Object):void {
			
		}
		
	}

}
import com.adobe.crypto.MD5;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.net.URLLoader;
import flash.utils.Dictionary;

internal class RestLibMamba 
	{
		private var api_server:String;
		private var app_id:String;
		private var oid:String;
		private var sid:String;
		private var private_key:String;
		
		public function RestLibMamba(api_server:String, app_id:String, oid:String, sid:String, private_key:String) 
		{			
			this.api_server = api_server;
			this.app_id = app_id;
			this.oid = oid;
			this.private_key = private_key;
			this.sid = sid; 
		}		
		
		private const FORMAT:String = "JSON";
		private var activeRequest:Dictionary = new Dictionary();
		
		public function CallMethod(params:Object, callback:Function):void
		{
			var variables : URLVariables = new URLVariables();
			
			params['app_id'] = app_id;
			//params['oid'] = oid;
			params['sid'] = sid;
			params['format'] = "JSON";
			params['secure'] = "0";
			
			var sigKeys : Array = new Array();
			
			for(var key:String in params) {
				variables[key] = params[key];
				var sigKey : String = '';
				sigKey = (key + '=' + params[key]);
				sigKeys.push(sigKey);
			}
			
			variables['sig'] = generateSignature(sigKeys);
			sendRequest(variables, callback );
		}
		
		public function generateSignature(keys : Array) : String {
			var sigKeys : Array = keys.sort();
			var sig : String = '';

			for(var i : int = 0;i < sigKeys.length;i++) {
				sig += sigKeys[i];
			}
			
			return MD5.hash(oid + sig + private_key).toLowerCase();
		}
		
		public function sendRequest( vars:URLVariables, callback:Function):void 
		{
			var rs:RequestStruct = new RequestStruct();
			rs.uLoader = new URLLoader();
			rs.uLoader.addEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.addEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
			rs.callback = callback;
			
			var req:URLRequest = new URLRequest();
			req.url = api_server;
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
			
			var result:Object = JSON.parse(rs.uLoader.data);
			
			rs.callback(result);
		}
		
		private function onRequest_IOError(evt:IOErrorEvent):void {
			var rs:RequestStruct = activeRequest[evt.currentTarget as URLLoader];
			rs.uLoader.removeEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.removeEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
			delete activeRequest[evt.currentTarget as URLLoader];		
			
			trace("onRequest_IOError");
		}
		
		private function onRequest_SecError(evt:SecurityErrorEvent):void {
			var rs:RequestStruct = activeRequest[evt.currentTarget as URLLoader];
			rs.uLoader.removeEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.removeEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
			delete activeRequest[evt.currentTarget as URLLoader];	
			
			trace("onRequest_SecError");
		}	
	}

internal class RequestStruct 
{
	public function RequestStruct() {  	}
	public var uLoader:URLLoader;
	public var callback:Function;
}