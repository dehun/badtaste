package ru.evast.integration.inner.MM 
{
	import flash.events.Event;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import ru.evast.integration.core.IDataAdapter;
	import ru.evast.integration.core.SocialProfileVO;
	import ru.evast.integration.inner.MM.api.MailruCall;
	import ru.evast.integration.inner.MM.api.MailruCallEvent;
	import ru.evast.integration.IntegrationProxy;	
	/**
	 * ...
	 * @author 
	 */
	public class MMInnerAdapter implements IDataAdapter 
	{
		private var localFlashVars:Object = new Object();
		private var flashVars:Object;
		
		private const apiURL:String = "http:\/\/www.appsmail.ru\/platform\/api";
		private const PRIVATE_KEY:String = "12f5b276b1858948f13b4a862eddfdd9";
		private const APP_TITLE:String = "Монополия";
		
		//Переменные для загрузки фото
		private var blob:ByteArray;
		private var blobName:String;
		
		private var restLib:RestLibMM;
		
		public function MMInnerAdapter() 
		{
			/*localFlashVars["vid"] = "15172459069920408752";				
			localFlashVars["oid"] = "15172459069920408752";		
			localFlashVars["app_id"] = "625662";					
			localFlashVars["authentication_key"] = "b1fc64acccd0ad8015255d4fb38cf5cb";				
			localFlashVars["sig"] = "45d9fe206dc315a17f5c020b55a6140e";		
			localFlashVars["window_id"] = "CometName_e92fe879225896365b18de942c23f211";			
			localFlashVars["is_app_user"] = "1";		
			localFlashVars["ext_perm"] = "notifications"; 		
			localFlashVars["session_key"] = "68afe2cf77f9d55864aaa0d597ede65f";
			localFlashVars["referer_type"] = ""; 			
			localFlashVars["referer_id"] = "";*/
			localFlashVars["vid"] = "13104067025448964595";				
			localFlashVars["oid"] = "13104067025448964595";		
			localFlashVars["app_id"] = "625662";					
			localFlashVars["authentication_key"] = "8b4521f25dd93a859fc9cefb3cce9478";				
			localFlashVars["sig"] = "18d7498d09eaeb842eb875200c132f41";		
			localFlashVars["window_id"] = "CometName_89fb2538ff614761bbaf14ea5146f752";			
			localFlashVars["is_app_user"] = "1";		
			localFlashVars["ext_perm"] = "notifications"; 		
			localFlashVars["session_key"] = "5027d650e81f3d813228a2f2a8dca8e3";
			localFlashVars["referer_type"] = ""; 			
			localFlashVars["referer_id"] = "";
		}
		/*
		 * http://monopoly.static.evast.ru/MM/monopoly.html?is_app_user=1&session_key=68afe2cf77f9d55864aaa0d597ede65f&vid=18112732558998376709&
			 * oid=18112732558998376709&app_id=625662&authentication_key=b1fc64acccd0ad8015255d4fb38cf5cb&session_expire=1339308607&
			 * ext_perm=notifications&sig=be1403c74312341a4f93b41bc343d7d4&window_id=CometName_649d7152961532d35dcb286e018bbfb2
		*/
		
		public function init(params:Object, local:Boolean):void {
			if (local)
				flashVars = localFlashVars;
			else {	
				flashVars = params;
				
				MailruCall.addEventListener(Event.COMPLETE, mailruReadyHandler);
				MailruCall.init('flashGame', PRIVATE_KEY);
			}			
			
			restLib = new RestLibMM(apiURL, flashVars['app_id'], flashVars['session_key'], flashVars['vid'], PRIVATE_KEY);
		}
		
		public function InviteFriends(msg:String):void {
			MailruCall.exec('mailru.app.friends.invite');
		}
		public function PostToWall(msg:String, pictureUrl:String):void {
			MailruCall.exec('mailru.common.stream.post', MailruStub , { title: APP_TITLE, text:msg /*, img_url:pictureUrl */} );
		}
		
		public function ShowPayment(count:int, mainName:String, code:int, additional:Object = null):void {
			var params:Object = new Object();
			params.service_id = code;
			params.service_name = mainName;
			params.mailiki_price = count;
			
			MailruCall.exec('mailru.app.payments.showDialog', MailruStub , params );
			MailruCall.addEventListener(MailruCallEvent.PAYMENT_DIALOG_STATUS, onPaymentStatus);
		}
		
		private function onPaymentStatus( evt:MailruCallEvent ):void {
			if ( IntegrationProxy.balanceUpdateFunction != null )
				IntegrationProxy.balanceUpdateFunction();
		}
		
		public function Me():String {
			return flashVars['vid'] as String;
		}
		public function GetAuthData():String {
			return flashVars['authentication_key'];
		}
		public function GetReferalId():String {
			if ( flashVars['referer_id'] != null ) return flashVars['referer_id'] as String;
			else return "";
		}
		public function isAppUser():Boolean {
			return true;	//В майле приложения добавляются автоматически
		}
		public function GetAppId():String {
			return flashVars["app_id"];
		}
		
		/*
		 * Запросы в соц сеть
		 */		
		public function GetAppFriends(onlyUids:Boolean, callback:Function):void {
			if(onlyUids)
				restLib.CallMethod( {method: "friends.getAppUsers", ext:0}, callback );
			else
				restLib.CallMethod( { method: "friends.getAppUsers", ext:1 }, function(input:Object): void {
																				callback.call(null, TransformProfiles(input) );
																			});
		}
		public function GetFriends(onlyUids:Boolean, callback:Function):void {
			if ( onlyUids ) {
				restLib.CallMethod( {method: "friends.get", ext:0}, callback );
			} else {
				restLib.CallMethod( { method: "friends.get", ext:1 }, function(input:Object): void {
																				callback.call(null, TransformProfiles(input) );
																			});
			}
		}
		
		public function GetProfiles(uids:String, callback:Function):void {
			restLib.CallMethod( { method: "users.getInfo", uids: uids }, 
					function(input:Object):void { 	  
						callback.call(null, TransformProfiles(input) ); 	
					});
		}
		
		public function UploadToAlbum(blob:ByteArray, name:String):void {
			//blob = blob;
			//blobName = name;
			
			//GetAlbums();
		}
		
		public function SendNotification(msg:String, uid:String, pictureUrl:String):void {
			var params:Object = new Object();
			params.uid = uid;
			params.title = APP_TITLE;
			params.text = msg;
			if( pictureUrl != null && pictureUrl != "" )
				params.img_url = pictureUrl;
			
			MailruCall.exec('mailru.common.guestbook.post', MailruStub , params );
		}
		
		
		
		/*
		 * Вспомогательный функции
		 */
		/*private function GetAlbums():void {
			restLib.CallMethod( { method: "photos.getAlbums" }, HandleGetAlbums);
		}
		
		private function HandleGetAlbums(input:Object):void	{
			
			for each ( var a in input) {
				if ( a.aid == SocialCfg.AlbumNameEng ) {
					UploadPhoto();
					return;
				}
			}
			
			RestLib.CallMethod( { method: "photos.createAlbum", aid:SocialCfg.AlbumNameEng, title:SocialCfg.AlbumNameRus, description:SocialCfg.AlbumDescription }, HandleCreateAlbum);
		}
		
		private function HandleCreateAlbum(input:Object):void {
			UploadPhoto();
		}
		
		private function UploadPhoto():void {
			restLib.TransferPicture( { method:"photos.upload", name:blobName }, HandleUploadPhoto, blob);
		}
		
		private function HandleUploadPhoto(input:Object):void {
			
		}*/
		
		
		
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
				curProf.BirthDate = a.birthday;
				curProf.Country = a.location.country.name;
				curProf.City = a.location.city.name;
				
				ret.push(curProf);
			}
			
			return ret;
		}
		
		private function MailruStub(evt:String):void {
			
		}
		
		private function mailruReadyHandler(unused:Object) : void {
			trace('Mail.ru API ready');
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
	import ru.evast.integration.utils.MultipartURLLoader;
	
	internal class RestLibMM 
	{		
		private var apiURL:String;
		private var appId:String;
		private var sessionKey:String;
		private var myUid:String;
		private var privateKey:String;
		
		private const FORMAT:String = "JSON";
		private var ActiveRequest:Dictionary = new Dictionary();
		
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
			
			ActiveRequest[rs.uLoader] = rs;
			
			rs.uLoader.load(req);
		}
		
		public function TransferPicture(params:Object, callback:Function, blob:ByteArray):void {
			params['app_id'] = appId;
			params['session_key'] = sessionKey;
			params['format'] = FORMAT;
			params['secure'] = "0";
			
			var sigKeys : Array = new Array();
			var loader:MultipartURLLoader = new MultipartURLLoader();
			
			for(var key:String in params) {
				var sigKey : String = '';
				sigKey = (key + '=' + params[key]);
				sigKeys.push(sigKey);
				loader.addVariable(key, params[key]);
			}
			
			loader.addVariable('sig', GenerateSignature(sigKeys) );
			
			loader.addFile(blob, 'photo.png', 'img_file' );
			loader.addEventListener( Event.COMPLETE, onMultiRequestComplete );
			
			var rs:RequestStruct = new RequestStruct();
			rs.multiLoader = loader;
			rs.callback = callback;
			ActiveRequest[rs.multiLoader] = rs;
			
			try
			{
				loader.load(apiURL);
			}
			catch(e:Error)
			{
				
			}
		}
		
		private function onRequsetComplete(evt:Event):void	{
			var rs:RequestStruct = ActiveRequest[evt.currentTarget as URLLoader];
			rs.uLoader.removeEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.removeEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
			
			delete ActiveRequest[evt.currentTarget as URLLoader];
			
			//var result:Object = JSON.parse(rs.uLoader.data);
			var result:Object = JSON.decode(rs.uLoader.data);
			
			rs.callback(result);
		}
		
		private function onMultiRequestComplete(evt:Event):void {
			var rs:RequestStruct = ActiveRequest[evt.currentTarget as MultipartURLLoader];
			rs.multiLoader.removeEventListener( Event.COMPLETE, onMultiRequestComplete );
			delete ActiveRequest[evt.currentTarget as MultipartURLLoader];
			
			//var result:Object = JSON.parse(rs.multiLoader.loader.data);
			var result:Object = JSON.decode(rs.multiLoader.loader.data);
			
			rs.callback.call( null, result);
		}
		
		private function onRequest_IOError(evt:IOErrorEvent):void {
			var rs:RequestStruct = ActiveRequest[evt.currentTarget as URLLoader];
			rs.uLoader.removeEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.removeEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
			delete ActiveRequest[evt.currentTarget as URLLoader];
		}
		
		private function onRequest_SecError(evt:SecurityErrorEvent):void {
			var rs:RequestStruct = ActiveRequest[evt.currentTarget as URLLoader];
			rs.uLoader.removeEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.removeEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
			delete ActiveRequest[evt.currentTarget as URLLoader];
		}
		
	}

internal class RequestStruct {
	public function RequestStruct():void {   }
	public var uLoader:URLLoader;
	public var callback:Function;
	public var multiLoader:MultipartURLLoader;
	
}	