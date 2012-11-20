package ru.evast.integration.outer.OK 
{
	import flash.utils.ByteArray;
	import ru.evast.integration.core.IDataAdapter;
	import ru.evast.integration.core.SocialProfileVO;
	
	/**
	 * ...
	 * @author ...
	 */
	public class OKOuterAdapter implements IDataAdapter 
	{
		private var localFlashVars:Object = new Object();
		private var flashVars:Object;
		
		private var RestLib:RestLibOK;
		
		private const API_SERVER:String = "http://api.odnoklassniki.ru//fb.do";
		private const APP_PUBLIC_KEY:String = "CBAHKOLCABABABABA";
		private const APP_SECRET_KEY:String = "2AD3B71A6A8B066F250450F6";
		
		public function OKOuterAdapter()	{
			localFlashVars["access_token"] = "cbv-9g9hHg3igMSjrkbysZXRIa5pcOYg5";
			localFlashVars["user_id"] = "576494768";
		}
		
		/* INTERFACE ru.evast.integration.core.IDataAdapter */
		
		public function init(params:Object, local:Boolean):void {
			if (local)
				flashVars = localFlashVars;
			else	{
				flashVars = params;
			}			
			
			RestLib = new RestLibOK(API_SERVER, APP_PUBLIC_KEY, flashVars["access_token"], flashVars["user_id"], APP_SECRET_KEY);
		}
		
		public function InviteFriends(msg:String):void {
			
		}
		
		public function ShowPayment(count:int, mainName:String, code:int, additional:Object = null):void {
			
		}
		
		public function Me():String {
			return flashVars["user_id"];
		}
		
		public function GetAuthData():String {
			return flashVars["access_token"];
		}
		
		public function GetReferalId():String {
			return "";
		}
		
		public function isAppUser():Boolean {
			return true;
		}
		
		public function GetAppId():String {
			return APP_PUBLIC_KEY;
		}
		
		public function GetAppFriends(onlyUids:Boolean, funck:Function):void {
			/*if(onlyUids)
					RestLib.CallMethod( { method: "friends.getAppUsers" },  function(input:Object):void { funck(input.uids); } );
				else
					throw "Not implemented";*/
		}
		
		public function GetFriends(onlyUids:Boolean, funk:Function):void {
			
		}
		
		public function GetProfiles(uids:String, funck:Function):void {
			if (uids == flashVars["user_id"]) {
				RestLib.CallMethod( { method: "users.getCurrentUser" }, 
					function(input:Object):void { 	  
						funck( 	TransformUser(input)	 ); 	});
			} else {
				throw new Error("not permissions");
			}
			/*RestLib.CallMethod( { method: "users.getInfo", uids: uids, fields:"uid,first_name,last_name,url_profile,gender,pic_1,pic_2,pic_3" }, 
					function(input:Object):void { 	  
						funck( 	TransformProfiles(input)	 ); 	});*/
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
			
			for each( var a:Object in input) {
				curProf = new SocialProfileVO();
				
				curProf.Uid = a.uid;
				curProf.FirstName = a.first_name;
				curProf.LastName = a.last_name;
				curProf.isMan = (a.sex == "male");
				curProf.UrlProfile = a.link;
				curProf.PicSmall = a.pic_1;
				curProf.PicMedium = a.pic_2;
				curProf.PicBig = a.pic_3;
				
				ret.push(curProf);
			}
			
			return ret;
		}
		
		private function TransformUser(input:Object):Array {
			var curProf:SocialProfileVO = new SocialProfileVO();
			
			curProf.Uid = input.uid;
			curProf.FirstName = input.first_name;
			curProf.LastName = input.last_name;
			curProf.isMan = (input.gender == "male");
			curProf.UrlProfile = input.link;
			curProf.PicSmall = input.pic_1;
			curProf.PicMedium = input.pic_2;
			curProf.PicBig = input.pic_2;
			
			return [curProf];
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
import flash.utils.ByteArray;
import flash.utils.Dictionary;
	

internal class RestLibOK 
{
	private var apiServer:String;
	private var applicationKey:String;
	private var accessToken:String;
	private var myUid:String;
	private var appSecretKey:String;
	
	private const FORMAT:String = "JSON";
	private var activeRequest:Dictionary = new Dictionary();	
	
	public function RestLibOK(api_server:String, application_key:String, access_token:String, logged_user_id:String, appSecretKey:String) 
	{		
		this.apiServer = api_server;
		this.applicationKey = application_key;
		this.accessToken = access_token;
		this.myUid = logged_user_id;
		this.appSecretKey = appSecretKey;
	}
	
	public function CallMethod(params:Object, callback:Function):void {
		var variables : URLVariables = new URLVariables();
		
		params['application_key'] = applicationKey;
		params['format'] = FORMAT;
		
		var sigKeys : Array = new Array();
		
		for(var key:String in params) {
			variables[key] = params[key];
			var sigKey : String = '';
			sigKey = (key + '=' + params[key]);
			sigKeys.push(sigKey);
		}
		
		variables['access_token'] = accessToken;
		variables['sig'] = GenerateSignature(sigKeys);
		
		SendRequest(variables, callback );
	}
	
	public function GenerateSignature(keys : Array) : String {
		var sigKeys : Array = keys.sort();
		var sig : String = '';
		
		for(var i : int = 0;i < sigKeys.length;i++) {
			sig += sigKeys[i];
		}
		
		return MD5.hash(sig + MD5.hash(accessToken + appSecretKey)).toLowerCase();
	}
	
	public function SendRequest( vars:URLVariables, callback:Function ):void {
		var rs:RequestStruct = new RequestStruct();
		rs.uLoader = new URLLoader();
		rs.uLoader.addEventListener(Event.COMPLETE, onRequsetComplete);
		rs.uLoader.addEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
		rs.uLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
		rs.callback = callback;
		
		var req:URLRequest = new URLRequest();
		req.url = apiServer;
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

internal class RequestStruct 
{
	public function RequestStruct() {  	}
	public var uLoader:URLLoader;
	public var callback:Function;
}