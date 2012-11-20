package com.exponentum.apps.flirt.controller.net {
import com.adobe.serialization.json.JSON;
import com.exponentum.apps.flirt.controller.net.ServerConnector;
import com.exponentum.apps.flirt.controller.net.ServerConnector;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.junkbyte.console.Cc;

import flash.events.EventDispatcher;

	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * @author Alex Glagoliev
	 */
	public class ServerConnector extends EventDispatcher {

		//private
		private static var _instance:ServerConnector;
		public static function get instance():ServerConnector
		{
			if (_instance == null) {
				_instance = new ServerConnector();
			}
			return _instance;
		}
		
		public static function call(command:String, params : String) : void
		{
			Cc.log("http://" + ServerConfig.SERVER + ":" + ServerConfig.HTTP_PORT);
			var request : URLRequest = new URLRequest("http://" + ServerConfig.SERVER + ":" + ServerConfig.HTTP_PORT);
			var requestData:String = "{\"" + command + "\":" + params + "}";
			Cc.log("->", requestData);
			trace("->", requestData);
			request.data = requestData;
			request.method = URLRequestMethod.POST;

			var urlLoader : URLLoader = new URLLoader();
			urlLoader.load(request);

			urlLoader.addEventListener(Event.COMPLETE, onRequestComplete);
		}

		private static function onRequestComplete(e:Event):void 
		{
			Cc.log("<--", e.currentTarget.data);
			trace("<--", e.currentTarget.data);
			var o:Object = JSON.decode(e.currentTarget.data);
			for (var key:String in o)
			{
				ServerConnector.instance.dispatchEvent(new ObjectEvent(key, o[key]));
			}
		}
		
		private static function showError(message:String):void 
		{
			trace("Error! :" + message);
		}
	}
}
