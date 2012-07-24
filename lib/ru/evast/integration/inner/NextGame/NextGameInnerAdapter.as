package ru.evast.integration.inner.NextGame 
{
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import ru.evast.integration.core.IDataAdapter;
	import ru.evast.integration.core.SocialProfileVO;
	
	/**
	 * ...
	 * @author Pavlov Andrey; mail: obsidium@yandex.ru skype: ctrl_break
	 */
	public class NextGameInnerAdapter implements IDataAdapter 
	{
		private var localFlashVars:Object = new Object();
		private var flashVars:Object;
		private var authKey:String;
		
		private var delegate:NextGameDelegate;//4E8065B1DD0213FBD5B8 //A9CB24A0B5C746A9F1C2
		
		private const CLIENT_KEY:String = "A9CB24A0B5C746A9F1C3";
		
		public function NextGameInnerAdapter() {
			localFlashVars["uid"] = "1084308";				
			localFlashVars["session_key"] = "342-pH14Qznb9676nw0Us2z5bK05PVkuX74b";		
			localFlashVars["api_server"] = "http://test.api2.nextgame.ru/api/";					
			localFlashVars["sig"] = "7629e0cfdcd240a48bec1ba9862a5e76";				
			localFlashVars["app_id"] = "251";		
			localFlashVars["ref_id"] = "0";			
			localFlashVars["post_id"] = "0";		
			localFlashVars["poster_id"] = "0"; 
			localFlashVars["nextgame"] = "1";
		}
		/*
		 * http://monopoly.static.evast.ru/NextGame/monopoly.html?
			 * session_key=342-pH14Qznb9676nw0Us2z5bK05PVkuX74b&uid=1084380&
			 * api_server=http%3A%2F%2Ftest.api2.nextgame.ru%2Fapi%2F&
			 * app_id=251&ref_id=0&nextgame=1&post_id=0&
			 * poster_id=0&
			 * sig=7629e0cfdcd240a48bec1ba9862a5e76
		 */
		
		 /*
		  * http://monopoly.static.evast.ru/NextGame/monopoly.html
			  * ?session_key=342-pH14Qznb9676nw0Us2z5bK05PVkuX74b&uid=1084380&
			  * api_server=http%3A%2F%2Ftest.api2.nextgame.ru%2Fapi%2F&
			  * app_id=251&ref_id=0&nextgame=1&post_id=0&poster_id=0&
			  * sig=7629e0cfdcd240a48bec1ba9862a5e76"
			*/
		
		/* INTERFACE ru.evast.integration.core.IDataAdapter */
		
		public function init(params:Object, local:Boolean):void {
			if (local)
				flashVars = localFlashVars;
			else
				flashVars = params;
				
			var sigKey : String = '';
			var sigKeys:Array = new Array();
			for(var key:String in flashVars) {
				if ( key == "sig" || key == "v" || key == "nextGame") continue;
				sigKey = (key + '=' + flashVars[key]);
				sigKeys.push(sigKey);
			}
			
			sigKeys = sigKeys.sort();
			authKey = sigKeys.join("") + "|" + flashVars["sig"];
			
			delegate = new NextGameDelegate(  flashVars["uid"], flashVars["app_id"], CLIENT_KEY, flashVars["session_key"], flashVars["api_server"] );
		}
		
		public function InviteFriends(msg:String):void {
			ExternalInterface.call("users.openInviteDialog(" + msg +")");
		}
		
		public function ShowPayment(count:int, mainName:String, code:int, additional:Object = null):void {
			//payment.openDialog(service_id, amount, title, description, extra)
			//payment.openDialog(1,10, 'Услуга', 'Описание услуги', 'color=red&size=big');
			
			ExternalInterface.call("payment.openDialog(" + 
											code.toString() + "," + 
											count.toString() + ",'" + 
											mainName +"','" + 
											mainName + 
											"','')");
		}
		
		public function Me():String {
			return flashVars["uid"] as String;
		}
		
		public function GetAuthData():String {
			return authKey;
		}
		
		public function GetReferalId():String {
			if ( flashVars["ref_id"] != null && flashVars["ref_id"] !== "0" )
				return flashVars["ref_id"] as String;
			
			if ( flashVars["poster_id"] != null && flashVars["poster_id"] !== "0" )
				return flashVars["poster_id"] as String;
				
			return "";
		}
		
		public function isAppUser():Boolean {
			return true;
		}
		
		public function GetAppId():String {
			return flashVars["app_id"] as String;
		}
		
		public function GetAppFriends(onlyUids:Boolean, callback:Function):void {																			
			if(onlyUids)
				delegate.request( "friends.getAppUsers", { ext:0, onComplete: function(input:Object):void { 
																				callback.call(null, input.data);
																}});
			else
				delegate.request( "friends.getAppUsers", { ext:1, onComplete: function(input:Object): void {
																				callback.call(null, TransformProfiles(input) );
																}});
		}
		
		public function GetFriends(onlyUids:Boolean, callback:Function):void {			
			if ( onlyUids ) 
				delegate.request( "friends.get", { ext:0, onComplete: function(input:Object):void { 
																				callback.call(null, input.data);
																			}});
			else 
				delegate.request( "friends.get", { ext:1, onComplete: function(input:Object): void {
																				callback.call(null, TransformProfiles(input) );
																			}});
		}
		
		public function GetProfiles(uids:String, callback:Function):void {
			delegate.request( "users.getInfo", { uids: uids , onComplete:
					function(input:Object):void { 	  
									callback.call(null, TransformProfiles(input) ); 	
					}});
		}
		
		public function UploadToAlbum(blob:ByteArray, name:String):void {
			
		}
		
		public function PostToWall(msg:String, pictureUrl:String):void {
			ExternalInterface.call("wall.post(" + msg + ")");
		}
		
		public function SendNotification(msg:String, uid:String, pictureUrl:String):void {
			delegate.request( "notification.send", { message: msg, uid:uid, onComplete:Stub });
		}
		
		private function TransformProfiles(input:Object):Array{
			var ret:Array = new Array();
			
			var curProf:SocialProfileVO;
			
			for each( var a:Object in input.data) {
				curProf = new SocialProfileVO();
				
				curProf.Uid = a.uid;
				curProf.FirstName = a.display_name;
				curProf.LastName = "";//a.last_name;
				curProf.isMan = (a.sex == "0");
				curProf.UrlProfile = a.link;
				curProf.PicSmall = "http://api2.nextgame.ru/service/picture/user/?uid=" + curProf.Uid + "&size=50x50";
				curProf.PicMedium = "http://api2.nextgame.ru/service/picture/user/?uid=" + curProf.Uid + "&size=100x100";
				curProf.PicBig = "http://api2.nextgame.ru/service/picture/user/?uid=" + curProf.Uid + "&size=100x100";
				
				ret.push(curProf);
			}
			
			return ret;
		}
		
		public function Stub(input:Object):void {
			
		}
		
	}

}

import adobe.utils.CustomActions;
import com.adobe.crypto.MD5;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.net.URLLoader;
import flash.utils.Dictionary;
import flash.net.URLLoaderDataFormat;
import flash.events.Event;
import com.adobe.crypto.MD5;

internal class NextGameDelegate 
{

	public static var _private_key:String;

	protected var _uid:String;
	protected var _app_id:String;
	protected var _session_key:String;
	protected var _rest_url:String;
	private var _global_options:Object;
	private var loader:URLLoader;

	public function NextGameDelegate(uid:String, app_id:String, private_key:String, session_key:String, rest_url:String=""){
		this._uid = uid;
		this._app_id = app_id;
		_private_key = private_key;
		this._session_key = session_key;
		this._rest_url = rest_url;
	}

	public function request(method:String, options:Object=null):void{
		if (options == null){
			options = {};
		};
		//options.onComplete = options.onComplete;
		this._sendRequest(method, options);
	}

	private function _sendRequest(method:String, options:Object):void{
		var key:String;
		var request:URLRequest;
		var loader:URLLoader;
		var i:String;
		var request_params:Object = {};
		request_params.method = method;
		request_params.session_key = this._session_key;
		request_params.app_id = this._app_id;
		if (options.params){
			for (i in options.params) {
				request_params[i] = options.params[i];
			};
		};
		var urlVars:URLVariables = new URLVariables();
		for (key in request_params) {
			urlVars[key] = request_params[key];
		};
		urlVars.method = method;
		urlVars.session_key = this._session_key;
		urlVars.app_id = this._app_id;
		urlVars.sig = this.generate_signature(request_params);
		request = new URLRequest();
		request.url = this._rest_url;
		request.method = URLRequestMethod.POST;
		request.data = urlVars;
		loader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.TEXT;
		loader.addEventListener(Event.COMPLETE, function (e:Event):void
		{
			var loader:URLLoader = URLLoader(e.target);
			var data:Object = JSON.parse(loader.data);
			options.onComplete(data);
		});
		try {
			loader.load(request);
		}
		catch(error:Error) {
			options.onError(error);
		};
	}

	private function generate_signature(params:Object):String{
		var key:String;
		var arg:*;
		var vars:Array = [];
		var s:String = "";
		s = (s + this._uid);
		for (key in params) {
			arg = params[key];
			vars.push(((key + "=") + arg.toString()));
		};
		vars.sort();
		s = (s + vars.join(""));
		s = (s + _private_key);
		return (MD5.hash(s));
	}

	public function get private_key():String	{
		return (NextGameDelegate._private_key);
	}

	public function get session_key():String	{
		return (this._session_key);
	}

	public function get app_id():String	{
		return (this._app_id);
	}

	public function get uid():String	{
		return (this._uid);
	}
}