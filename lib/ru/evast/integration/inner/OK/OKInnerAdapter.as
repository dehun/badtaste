package ru.evast.integration.inner.OK 
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import ru.evast.integration.core.IDataAdapter;
	import ru.evast.integration.core.IntegrationCfg;
	import ru.evast.integration.core.SocialDefaults;
	import ru.evast.integration.core.SocialProfileVO;
	import ru.evast.integration.inner.OK.forticom.ApiCallbackEvent;
	import ru.evast.integration.inner.OK.forticom.ForticomAPI;	
	import ru.evast.integration.inner.OK.forticom.SignUtil;
	import ru.evast.integration.IntegrationProxy;
	/**
	 * ...
	 * @author Andrey Pavlov. skype ctrl_break. email: obsidium@yandex.ru
	 */
	public class OKInnerAdapter implements IDataAdapter 
	{
		private var localFlashVars:Object = new Object();
		private var flashVars:Object;
		
		private var RestLib:RestLibOK;
		
		public function OKInnerAdapter() 
		{			
			localFlashVars["authorized"] = "1";				
			localFlashVars["application_key"] = "CBANJLABABABABABA";		
			localFlashVars["auth_sig"] = "d33e8ceaec83a8bc51867532b5de656f";					
			localFlashVars["api_server"] = "http://api.odnoklassniki.ru//";				
			localFlashVars["apiconnection"] = "695296_1326967140888";		
			localFlashVars["session_key"] = "895be76dr18e9h3fQ1c1dZcetdaa9XahJ4640BcFv0926cbEP7796hUfwb";			
			localFlashVars["logged_user_id"] = "576494768";		
			localFlashVars["sig"] = "947aeac0e6064e22d9e6867624875773"; 						
			localFlashVars["session_secret_key"] = "b60fe43fccf43eb7d2daad701db27178";		
			localFlashVars["refplace"] = "friend_invitation"; 			
			localFlashVars["referer"] = "91745172587";
		}
		
		/*
			http://monopoly.static.evast.ru/OK/monopoly.html?application_key=CBANJLABABABABABA&authorized=1&auth_sig=d33e8ceaec83a8bc51867532b5de656f&api_server=http%3A%2F%2Fapi.odnoklassniki.ru%2F&
				apiconnection=695296_1342151515544&web_server=www.odnoklassniki.ru&first_start=0&logged_user_id=576494768&session_key=895be76dr18e9h3fQ1c1dZcetdaa9XahJ4640BcFv0926cbEP7796hUfwb&
				sig=2f61e0ae1e4a02634a16c6d1424cba00&clientLog=0&session_secret_key=b60fe43fccf43eb7d2daad701db27178
		 */
		
		public function init(params:Object, local:Boolean):void {
			if (local)
				flashVars = localFlashVars;
			else	{
				flashVars = params;
				ForticomAPI.connection = flashVars["apiconnection"];
			}			
			
			RestLib = new RestLibOK(flashVars["api_server"]+ "fb.do", flashVars["application_key"], flashVars["session_key"], flashVars["logged_user_id"], flashVars["session_secret_key"]);
		}
		public function InviteFriends(msg:String):void {
			ForticomAPI.showInvite(msg);
		}
		/*	TODO: Протестировать этот метод для постинга от Алекса Волкова
			  public function streamPublish(obj : StreamPublishObj) : void {
			   MonsterDebugger.trace(this, obj);
			   streamPublishObj = obj;
			   var media : Array = [{src:obj.img_url, type:"image"}];
			   _attach = JSON.stringify({caption:obj.message, media:media});
			   _action_links = JSON.stringify([{"text":"Получить приз","href":obj.post_id}]);
			   _signature = getSigStream(obj.title, _attach, _action_links);
			   ForticomAPI.addEventListener(ApiCallbackEvent.CALL_BACK, apiCallback);
			   ForticomAPI.showConfirmation("stream.publish", obj.confirmMessage, _signature);
			  }
		  */
		public function PostToWall(msg:String, pictureUrl:String):void {
			
			SignUtil.applicationKey = flashVars["application_key"];
			SignUtil.sessionKey = flashVars["session_key"];
			SignUtil.secretSessionKey = flashVars["session_secret_key"];
			
			var ttm:URLVariables = new URLVariables();
			var msgEnc:String = encodeURI(msg);
			
			var request:Object = { method:"stream.publish", message:msg };
			
			request = SignUtil.signRequest(request, true);
			
			ForticomAPI.showConfirmation("stream.publish", msg, request["sig"]);
			ForticomAPI.addEventListener(ApiCallbackEvent.CALL_BACK, function (event:ApiCallbackEvent):void {				
				var testString:*;
				var event:* = event;
				if (event.result == "ok") {
					request["resig"] = event.data;
					testString = "http://api.odnoklassniki.ru/fb.do?method=stream.publish&format=XML&application_key=" + flashVars["application_key"] + "&message=" + msgEnc + "&session_key=" + flashVars["session_key"] + "&sig=" + request["sig"] + "&resig=" + request["resig"];
					var Uloader:* = new URLLoader();
					var Urequest:* = new URLRequest(testString);
					try {
						Uloader.load(Urequest);
					}
					catch (error:Error) {
						trace("Ошибка при сохранении поста на стену");
					}
				}
			});
			
		}
		public function ShowPayment(count:int, mainName:String, code:int, additional:Object = null):void {
			ForticomAPI.showPayment(mainName, mainName, code.toString(), count, null, null, 'ok', 'true');
			ForticomAPI.addEventListener(ApiCallbackEvent.CALL_BACK, onPaymentResult);
		}
		private function onPaymentResult(result:Object):void {
			ForticomAPI.removeEventListener(ApiCallbackEvent.CALL_BACK, onPaymentResult);
			if ( IntegrationProxy.balanceUpdateFunction != null )
				IntegrationProxy.balanceUpdateFunction();
		}

		
		public function GetAppId():String 	{
			return flashVars["application_key"];
		}
		
		public function Me():String	{
			return flashVars["logged_user_id"];
		}
		
		public function GetAuthData():String {
			return flashVars["auth_sig"] + "/" + flashVars["session_key"];
		}
		
		public function GetReferalId():String	{
			if ( flashVars["refplace"] == "friend_invitation" ) return flashVars["referer"];
			else return "";
		}
		
		public function isAppUser():Boolean {
			return true;	//В однокласниках приложения устанавливаются автоматически
		}
		
		public function UploadToAlbum(blob:ByteArray, name:String):void {
			
		}
		
		public function GetAppFriends(onlyUids:Boolean, callback:Function):void {
			if(onlyUids)
					RestLib.CallMethod( { method: "friends.getAppUsers" },  function(input:Object):void { 
																				callback.call(null, TransformAppFriendUids( input ) ); 
																			});
				else
					RestLib.CallMethod( { method: "friends.getAppUsers"}, function(input:Object):void {
																				LoadAllProfiles(input, callback);
																				});
		}
		public function GetFriends(onlyUids:Boolean, callback:Function):void {
			if(onlyUids)
					RestLib.CallMethod( { method: "friends.get" },  function(input:Object):void { 
																				callback.call(null, input ); 
																			});
				else
					RestLib.CallMethod( { method: "friends.get"},  function(input:Object):void {
																				LoadAllProfiles(input, callback);
																				});
		}
		
		public function GetProfiles(uids:String, callback:Function):void {
			RestLib.CallMethod( { method: "users.getInfo", uids: uids, fields:"uid,first_name,last_name,url_profile,gender,pic_1,pic_2,pic_3,birthday,location" }, 
					function(input:Object):void { 	  
						callback.call( null, TransformProfiles(input) ); 	
					});
		}
		
		public function SendNotification(msg:String, uids:String, pictureUrl:String):void {
			RestLib.CallMethod( { method: "notifications.sendSimple", uid:uids, text:msg }, stub);
		}
		
		private function LoadAllProfiles(input:Object, callback:Function):void {
			var uids:Array;
			
			if ( input is Array ) {
				uids = input as Array;
			} 
			else if(input.uids is Array ) {
				uids = input.uids;
			}
			
			if ( uids == null || uids.length == 0 ) {
				callback.call(null, []);
			}
			
			var groups:Array = new Array();
			
			for ( var a:int = 0; a * 100 < uids.length; a++) {
				var low:int = a * 100;
				groups.push(uids.slice(low, low + 100));
			}
			
			var result:Array = new Array();
			
			var i:int = 0;
			function getGroup():Array {
				if ( i == groups.length )
					return null;
				
				return groups[i++] as Array;
			}
			
			function stepNext():void {
				var u:Array = getGroup();
				if ( u == null ) {
					callback.call(null, result);
					return;
				}
				
				GetProfiles(u.join(","), function(profiles:Array):void {
					result = result.concat(profiles);
					stepNext();
				});
			}
			
			stepNext();
		}
		
		
		private function TransformProfiles(input:Object):Array {
			if ( input == null ) return [];
			if ( IntegrationCfg.allowDefault && input.error_code != null ) return [ SocialDefaults.GetDefaultProfileRu(Me()) ];//TODO: Избавиться от этого
			
			var ret:Array = new Array();
			
			var curProf:SocialProfileVO;
			
			for each( var a:Object in input) {
				curProf = new SocialProfileVO();
				
				curProf.Uid = a.uid;
				curProf.FirstName = a.first_name;
				curProf.LastName = a.last_name;
				if( a.gender != null )
					curProf.isMan = (a.gender == "male");
				else
					curProf.isMan = true;
				curProf.UrlProfile = a.url_profile;
				curProf.PicSmall = a.pic_1;
				curProf.PicMedium = a.pic_2;
				curProf.PicBig = a.pic_3;
				curProf.BirthDate = a.birthday;
				curProf.City = a.location.city;
				curProf.Country = a.location.country;
				
				ret.push(curProf);
			}
			
			return ret;
		}
		
		private function  TransformAppFriendUids(input:Object):Array {
			if ( IntegrationCfg.allowDefault && input.error_code != null ) return [];//TODO: Избавиться от этого
			
			return input.uids;
		}
		
		private function stub(input:Object):void{
			
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
	

internal class RestLibOK 
{
	private var api_server:String;
	private var application_key:String;
	private var session_key:String;
	private var myUid:String;
	private var session_secret_key:String;
	
	private const FORMAT:String = "JSON";
	private var activeRequest:Dictionary = new Dictionary();	
	
	public function RestLibOK(api_server:String, application_key:String, session_key:String, logged_user_id:String, session_secret_key:String) 
	{		
		this.api_server = api_server;
		this.application_key = application_key;
		this.session_key = session_key;
		this.myUid = logged_user_id;
		this.session_secret_key = session_secret_key;	
	}
	
	public function CallMethod(params:Object, callback:Function):void {
		var variables : URLVariables = new URLVariables();
		
		params['application_key'] = application_key;
		params['session_key'] = session_key;
		params['format'] = FORMAT;
		
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
		
		return MD5.hash(sig + session_secret_key).toLowerCase();
	}
	
	public function SendRequest( vars:URLVariables, callback:Function ):void {
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