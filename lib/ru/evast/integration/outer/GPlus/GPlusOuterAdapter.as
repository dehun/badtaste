package ru.evast.integration.outer.GPlus 
{
	import flash.system.Security;
	import flash.utils.ByteArray;
	import ru.evast.integration.core.IDataAdapter;
	import ru.evast.integration.core.SocialProfileVO;
	
	/**
	 * ...
	 * @author ...
	 */
	public class GPlusOuterAdapter implements IDataAdapter 
	{
		private var localFlashVars:Object = new Object();
		private var flashVars:Object;
		
		private var appId:String = "874746768473.apps.googleusercontent.com";
		
		private var RestLib:RestLibGplus;
		
		public function GPlusOuterAdapter() {
			localFlashVars["accessToken"] = "ya29.AHES6ZQGonn0QdKimkWFGK671K7XRs6e3Op-1rsi1upA6LoErqup2g";
			localFlashVars["userId"] = "110653447277163155387";
			
			Security.loadPolicyFile("http://www.googleapis.com/crossdomain.xml");
			Security.loadPolicyFile("https://www.googleapis.com/crossdomain.xml");
		}
		
		public function init(params:Object, local:Boolean):void {
			if (local)
				flashVars = localFlashVars;
			else {
				flashVars = params;
			}
			
			RestLib = new RestLibGplus(flashVars["accessToken"]);
		}
		
		public function InviteFriends(msg:String):void {
			
		}
		
		public function ShowPayment(count:int, mainName:String, code:int, additional:Object = null):void {
			
		}
		
		public function Me():String {
			return flashVars["userId"];
		}
		
		public function GetAuthData():String {
			return flashVars["accessToken"];
		}
		
		public function GetReferalId():String {
			return "";
		}
		
		public function isAppUser():Boolean {
			return true;
		}
		
		public function GetAppId():String {
			return appId;
		}
		
		public function GetAppFriends(onlyUids:Boolean, funck:Function):void {
			
		}
		
		public function GetFriends(onlyUids:Boolean, funk:Function):void {
			
		}
		
		public function GetProfiles(uids:String, callback:Function):void {
			if (uids == Me() ) {
				RestLib.CallMethod("people/me", function(input:Object):void { callback( TransformProfile(input) ); } );
			}
		}
		
		public function UploadToAlbum(blob:ByteArray, name:String):void {
			
		}
		
		public function PostToWall(msg:String, pictureUrl:String):void {
			
		}
		
		public function SendNotification(msg:String, uids:String, pictureUrl:String):void {
			
		}
		
		private function TransformProfile(input:Object):Array {
			var vo:SocialProfileVO = new SocialProfileVO();//familyName  givenName = "obsidium"
			
			vo.Uid = input.id;
			vo.FirstName = input.name.givenName;
			vo.LastName = input.name.familyName;
			vo.isMan = (input.gender == "male");
			vo.UrlProfile = input.url;//url = "https://lh5.googleusercontent.com/-McXBMcUDcYM/AAAAAAAAAAI/AAAAAAAAAAA/XiKMEeCfw3I/photo.jpg?sz=50"
			
			var image:String = input.image.url;
			var parts:Array = image.split("=");
			image = parts[0];
			//36 75 128
			
			vo.PicSmall = image + "=36";
			vo.PicMedium = image + "=75";
			vo.PicBig = image + "=128";
			
			
			return [vo];
		}
	}
}
	
import by.blooddy.crypto.serialization.JSON;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.Dictionary;
import flash.net.URLLoader;

internal class RestLibGplus
{
		
	private var activeRequest:Dictionary = new Dictionary();
	private var accessToken:String;
	
	private const ApiURL:String = "https://www.googleapis.com/plus/v1/";
	
	public function RestLibGplus(AccessToken:String) {
		this.accessToken = AccessToken;
	}
	
	public function CallMethod(suffix:String, callback:Function, params:Object = null):void {
		var variables : URLVariables = new URLVariables();
		
		variables.access_token = accessToken;
		
		if( params!= null ){
			for(var key:String in params) 
				variables[key] = params[key];
		}
		
		var rs:RequestStruct = new RequestStruct();
		rs.uLoader = new URLLoader();
		rs.uLoader.addEventListener(Event.COMPLETE, onRequsetComplete);
		//rs.uLoader.addEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
		//rs.uLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
		rs.callback = callback;
		
		var req:URLRequest = new URLRequest();
		req.url = ApiURL + suffix;
		req.data = variables;
		req.method = URLRequestMethod.GET;
		
		activeRequest[rs.uLoader] = rs;
		
		rs.uLoader.load(req);
	}
			
	
	private function onRequsetComplete(evt:Event):void	{
		var rs:RequestStruct = activeRequest[evt.currentTarget as URLLoader];
		
		delete activeRequest[evt.currentTarget as URLLoader];
		rs.uLoader.removeEventListener(Event.COMPLETE, onRequsetComplete);
		rs.uLoader.removeEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
		rs.uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
		
		//var result:Object = JSON.parse(rs.uLoader.data);
		var result:Object = JSON.decode(rs.uLoader.data);
		
		rs.callback(result);
	}
	
	private function onRequest_IOError(evt:IOErrorEvent):void {
		var rs:RequestStruct = activeRequest[evt.currentTarget as URLLoader];
		delete activeRequest[evt.currentTarget as URLLoader];
		rs.uLoader.removeEventListener(Event.COMPLETE, onRequsetComplete);
		rs.uLoader.removeEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
		rs.uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
	}
	
	private function onRequest_SecError(evt:SecurityErrorEvent):void {
		trace("FB Security error");
		var rs:RequestStruct = activeRequest[evt.currentTarget as URLLoader];
		delete activeRequest[evt.currentTarget as URLLoader];
		rs.uLoader.removeEventListener(Event.COMPLETE, onRequsetComplete);
		rs.uLoader.removeEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
		rs.uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
	}
	
}

internal class RequestStruct {
	public function RequestStruct():void {   }
	public var uLoader:URLLoader;
	public var callback:Function;
	
}