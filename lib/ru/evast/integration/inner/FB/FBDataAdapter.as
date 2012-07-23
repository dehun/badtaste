package ru.evast.integration.inner.FB
{	
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import ru.evast.integration.core.IDataAdapter;
	import ru.evast.integration.core.SocialProfileVO;
	import ru.evast.integration.IntegrationProxy;
	
	public class FBDataAdapter implements IDataAdapter
	{
		private var localFlashVars:Object = new Object();
		private var flashVars:Object;
		
		private const APP_ID:String = "190521524382106";
		private const APP_SECRET:String = "	a74c0472fba3e2c07bca6b29a6e4f864";
		
		private var restLib:RestLibFB;
		
		public function FBDataAdapter()
		{//access_token=AAAE6zsKSHKwBAOWuHkBHKFvi2jhFVF61oIarHUpgB3KTEKBYmeXr1le0Hhg5uR8NNXABYKnRkZBrPIKHZBVC5as05iyzdDEgC2qtZADlBs3ysopXolQ&user_id=1331297344
			localFlashVars["access_token"] = "AAAE6zsKSHKwBAOWuHkBHKFvi2jhFVF61oIarHUpgB3KTEKBYmeXr1le0Hhg5uR8NNXABYKnRkZBrPIKHZBVC5as05iyzdDEgC2qtZADlBs3ysopXolQ";
			localFlashVars["user_id"] = "1331297344";
		}
		
		public function init(params:Object, local:Boolean):void	{
			if( local ) {
				flashVars = localFlashVars;
			} else {
				//Security.loadPolicyFile("https://graph.facebook.com/crossdomain.xml");
				Security.loadPolicyFile("http://graph.facebook.com/crossdomain.xml");
				flashVars = params;
				
				if ( ExternalInterface.available ) {
					ExternalInterface.addCallback("onPayment", HandlePayment);
				}
			}
			
			restLib = new RestLibFB( flashVars["access_token"] );
			
		}
		
		
		public function InviteFriends(msg:String):void	{
			ExternalInterface.call("InviteFriends");
		}
		
		public function ShowPayment(count:int, mainName:String, code:int, additional:Object = null):void {
			ExternalInterface.call("ShowPayment(" + count.toString() +")");
		}
		
		public function Me():String	{
			return flashVars["user_id"];
			
		}
		
		public function GetAuthData():String	{
			return flashVars["access_token"];
		}
		
		public function GetReferalId():String	{
			return "";
		}
		
		public function isAppUser():Boolean	{
			return true;
		}
		
		public function GetAppId():String	{
			return APP_ID;
		}
		
		public function GetAppFriends(onlyUids:Boolean, callback:Function):void	{
			if ( onlyUids ) {
				// fql version 		SELECT uid, name, pic_square FROM user WHERE is_app_user  AND uid IN (SELECT uid2 FROM friend WHERE uid1 = me())
				
				restLib.CallMethod("me/friends", function(input:Object): void {
														callback( TransformFriends(input) );
													}, {fields:"installed"} );
			} else {
				restLib.CallMethod("me/friends", function(input:Object): void {
														callback( TransformAppFriendProfiles(input) );
													}, {fields:"first_name,last_name,link,gender,installed"} );
			}
		}
		
		public function GetFriends(onlyUids:Boolean, callback:Function):void {
			if ( onlyUids ) {				
				restLib.CallMethod("me/friends", function(input:Object): void {
														callback( TransformFriends(input) );
													});
			} else {
				restLib.CallMethod("me/friends", function(input:Object): void {
														callback( TransformFriendProfiles(input) );
													}, {fields:"first_name,last_name,link,gender"} );
			}
		}
		
		public function GetProfiles(uids:String, callback:Function):void	{//picture
			restLib.CallMethod("", function(input:Object): void {	callback( TransformProfiles(input) ); }, 
												{ids:uids});
		}
		
		public function UploadToAlbum(blob:ByteArray, name:String):void	{
		}
		
		public function PostToWall(msg:String, pictureUrl:String):void	{
			/* var obj:Object = {
			  method: 'feed',
			  link: 'http://apps.facebook.com/russian_business',
			  picture: 'http://fbrell.com/f8.jpg',
			  name: 'Russian Business',
			  message: msg,
			  caption: 'Russian Business',
			  description: ''
			};*/
			
			/*var obj:String = "{method: 'feed'," +
			  "link: 'http://apps.facebook.com/russian_business'," +
			  "picture: 'http://fbrell.com/f8.jpg'," +
			  "name: 'Russian Business'," +
			  "message: " + msg + "," +
			  "caption: 'Russian Business'," +
				"description: 'description'}";
			
			ExternalInterface.call("function () {	FB.ui(" + obj +", CallBackStub); } ");
			trace("try post to wall");*/
			
			ExternalInterface.call("PostToWall('" + msg + "')");
		}
		
		public function SendNotification(msg:String, uids:String, pictureUrl:String):void {
			ExternalInterface.call("SendRequestTo('" + uids + "', '" + msg + "')");
		}
		
		private function TransformFriends(input:Object):Array {
			var ret:Array = new Array();
			for each( var o:Object in input.data ) {
				if( o.installed == true )
					ret.push(o.id);
			}
			return ret;
		}
		private function TransformProfiles(input:Object):Array {
			var ret:Array = new Array();
			var vo:SocialProfileVO;
			for( var p:String in input ){
				vo = new SocialProfileVO();
				vo.FirstName = input[p].first_name;
				vo.LastName = input[p].last_name;
				vo.Uid = input[p].id;
				vo.UrlProfile = input[p].link;
				vo.isMan = true;
				vo.PicSmall = "http://graph.facebook.com/"+ vo.Uid +"/picture?type=square";
				vo.PicMedium = "http://graph.facebook.com/"+ vo.Uid +"/picture?type=normal";
				vo.PicBig = "http://graph.facebook.com/"+ vo.Uid +"/picture?type=large";
				if( input[p].gender != undefined && input[p].gender != "male" )
					vo.isMan = false;
				ret.push(vo);
			}
			return ret;
		}
		private function TransformFriendProfiles(input:Object):Array {
			var ret:Array = new Array();
			var vo:SocialProfileVO;
			for each( var o:Object in input.data ){
				vo = new SocialProfileVO();
				vo.FirstName = o.first_name;
				vo.LastName = o.last_name;
				vo.Uid = o.id;
				vo.UrlProfile = o.link;
				vo.isMan = true;
				vo.PicSmall = "http://graph.facebook.com/"+ vo.Uid +"/picture?type=square";
				vo.PicMedium = "http://graph.facebook.com/"+ vo.Uid +"/picture?type=normal";
				vo.PicBig = "http://graph.facebook.com/"+ vo.Uid +"/picture?type=large";
				if( o.gender != undefined && o.gender != "male" )
					vo.isMan = false;
				ret.push(vo);
			}
			return ret;
		}
		private function TransformAppFriendProfiles(input:Object):Array {
			var ret:Array = new Array();
			var vo:SocialProfileVO;
			for each( var o:Object in input.data ) {
				if ( o.installed != true ) continue;
				vo = new SocialProfileVO();
				vo.FirstName = o.first_name;
				vo.LastName = o.last_name;
				vo.Uid = o.id;
				vo.UrlProfile = o.link;
				vo.isMan = true;
				vo.PicSmall = "http://graph.facebook.com/"+ vo.Uid +"/picture?type=square";
				vo.PicMedium = "http://graph.facebook.com/"+ vo.Uid +"/picture?type=normal";
				vo.PicBig = "http://graph.facebook.com/"+ vo.Uid +"/picture?type=large";
				if( o.gender != undefined && o.gender != "male" )
					vo.isMan = false;
				ret.push(vo);
			}
			return ret;
		}
		
		private function HandlePayment():void {
			IntegrationProxy.balanceUpdateFunction.call(null);
		}
	}
}
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.Dictionary;
import flash.net.URLLoader;

internal class RestLibFB
	{
		
		private var ActiveRequest:Dictionary = new Dictionary();
		private var AccessToken:String;
		
		private const ApiURL:String = "https://graph.facebook.com/";
		
		public function RestLibFB(AccessToken:String) {
			this.AccessToken = AccessToken;
		}
		
		public function CallMethod(suffix:String, callback:Function, params:Object = null):void {
			var variables : URLVariables = new URLVariables();
			
			variables.access_token = AccessToken;
			
			if( params!= null ){
				for(var key:String in params) 
					variables[key] = params[key];
			}
			
			var rs:RequestStruct = new RequestStruct();
			rs.uLoader = new URLLoader();
			rs.uLoader.addEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.addEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
			rs.callback = callback;
			
			var req:URLRequest = new URLRequest();
			req.url = ApiURL + suffix;
			req.data = variables;
			req.method = URLRequestMethod.GET;
			
			ActiveRequest[rs.uLoader] = rs;
			
			rs.uLoader.load(req);
		}
				
		
		private function onRequsetComplete(evt:Event):void	{
			var rs:RequestStruct = ActiveRequest[evt.currentTarget as URLLoader];
			
			delete ActiveRequest[evt.currentTarget as URLLoader];
			rs.uLoader.removeEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.removeEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
			
			var result:Object = JSON.parse(rs.uLoader.data);
			
			rs.callback(result);
		}
		
		private function onRequest_IOError(evt:IOErrorEvent):void {
			var rs:RequestStruct = ActiveRequest[evt.currentTarget as URLLoader];
			delete ActiveRequest[evt.currentTarget as URLLoader];
			rs.uLoader.removeEventListener(Event.COMPLETE, onRequsetComplete);
			rs.uLoader.removeEventListener(IOErrorEvent.IO_ERROR , onRequest_IOError);
			rs.uLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequest_SecError);
		}
		
		private function onRequest_SecError(evt:SecurityErrorEvent):void {
			var rs:RequestStruct = ActiveRequest[evt.currentTarget as URLLoader];
			delete ActiveRequest[evt.currentTarget as URLLoader];
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