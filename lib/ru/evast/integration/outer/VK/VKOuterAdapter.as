package ru.evast.integration.outer.VK 
{
	import flash.system.Security;
	import flash.utils.ByteArray;
	import ru.evast.integration.core.IDataAdapter;
	import ru.evast.integration.core.SocialProfileVO;
	
	/**
	 * ...
	 * @author ...
	 */
	public class VKOuterAdapter implements IDataAdapter 
	{
		private var localFlashVars:Object = new Object();
		private var flashVars:Object;
		
		private var apiURL:String = "http://api.vkontakte.ru/method/";
		private var appId:String = "2804258";
		private var privateKey:String = "3ME9hQ58ETPzfb5cxyip";
		
		private var restLib:ExternalVKRestLib;
		
		public function VKOuterAdapter() 
		{
			localFlashVars["accessToken"] = "bd98b1b1f246be21bd132ef0aebd39e4d2abd13bd13aef2bedc134cb1369acb";
			localFlashVars["userId"] = "9150273";
			localFlashVars["secret"] = "12f003c179fcf99d6e";
		}
		public function init(params:Object, local:Boolean):void {
			if (local)
				flashVars = localFlashVars;
			else {
				Security.loadPolicyFile("http://api.vkontakte.ru/crossdomain.xml");
				//Security.loadPolicyFile("https://api.vkontakte.ru/crossdomain.xml");
				flashVars = params;
			}
			
			restLib = new ExternalVKRestLib(apiURL, flashVars["accessToken"], flashVars["secret"]);
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
		
		public function GetAppFriends(onlyUids:Boolean, callback:Function):void {
			if ( onlyUids ) {
				restLib.CallMethod("friends.getAppUsers", { }, function(input:Object):void { callback(input.response); } );
			} else {
				throw new Error("not implemented");
			}
		}
		public function GetFriends(onlyUids:Boolean, callback:Function):void {
			if ( onlyUids ) {
				restLib.CallMethod("friends.get", { }, function(input:Object):void { callback(input.response); });
			} else {
				throw new Error("not implemented");
			}
		}
		public function GetProfiles(uids:String, func:Function):void {
			restLib.CallMethod("getProfiles", 
						{ fields:"uid,first_name,last_name,sex,photo,photo_medium,photo_big", uids:uids }, 
						function(input:Object):void { func(TransformProfiles(input)); } );
		}
		public function UploadToAlbum(blob:ByteArray, name:String):void {
			
		}
		public function PostToWall(msg:String, pictureUrl:String):void {
			
		}
		
		public function SendNotification(msg:String, uids:String, pictureUrl:String):void {
			
		}
		
		private function TransformProfiles(input:Object):Array{
			var ret:Array = new Array();
			
			var curProf:SocialProfileVO;
			
			for each( var a:Object in input.response) {
				curProf = new SocialProfileVO();
				
				curProf.Uid = a.uid;
				curProf.FirstName = a.first_name;
				curProf.LastName = a.last_name;
				curProf.isMan = (a.sex == "2");
				curProf.UrlProfile = "http://vkontakte.ru/id" + a.uid;
				curProf.PicSmall = a.photo;
				curProf.PicMedium = a.photo_medium;
				curProf.PicBig = a.photo_big;
				
				ret.push(curProf);
			}
			
			return ret;
		}
	}

}

import com.adobe.crypto.MD5;
import com.adobe.serialization.json.JSON;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.Dictionary;

internal class ExternalVKRestLib {
	
		private var apiURL:String;
		private var accessToken:String;
		private var secret:String;
		
		private var activeRequest:Dictionary = new Dictionary();
		
		public function ExternalVKRestLib(apiURL:String, accessToken:String, secret:String) {
			
			this.apiURL = apiURL;
			this.accessToken = accessToken;
			this.secret = secret;
		}
		
		
		public function CallMethod(methodName:String, params:Object, callback:Function):void {
			var variables : URLVariables = new URLVariables();
			var requestString:String = "";
			params['access_token'] = accessToken;
			
			var sigKeys : Array = new Array();
			
			for (var key:String in params) {
				requestString += "&" +key + "=" + params[key];
				variables[key] = params[key];
			}
			requestString = requestString.substr(1);
			variables["sig"] = GenerateSignature("/method/" + methodName +"?" + requestString);
			
			var rs:RequestStruct = new RequestStruct();
			rs.uLoader = new URLLoader();
			rs.uLoader.addEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.addEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
			rs.callback = callback;
			
			var req:URLRequest = new URLRequest();
			req.url = apiURL + methodName;
			req.data = variables;
			req.method = URLRequestMethod.GET;
			
			activeRequest[rs.uLoader] = rs;
			
			rs.uLoader.load(req);
		}
		public function GenerateSignature(requestString:String) : String {
			
			return MD5.hash(requestString + secret).toLowerCase();
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
			
			trace("VKExternalAdapter IO Error");
			//SocialProxy.instance.dispatchEvent(new SocialEvent(SocialEvent.REQUEST_IO_ERROR));
		}
		
		private function onRequest_SecError(evt:SecurityErrorEvent):void {
			var rs:RequestStruct = activeRequest[evt.currentTarget as URLLoader];
			delete activeRequest[evt.currentTarget as URLLoader];
			
			rs.uLoader.removeEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.removeEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
			
			trace("VKExternalAdapter Security Error");
			//SocialProxy.instance.dispatchEvent(new SocialEvent(SocialEvent.REQUEST_SEC_ERROR));
		}
		
	}

	internal class RequestStruct {
		public var uLoader:URLLoader;
		public var callback:Function;
	}