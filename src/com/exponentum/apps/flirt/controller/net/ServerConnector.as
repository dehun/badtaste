package com.exponentum.apps.flirt.controller.net {
import com.adobe.serialization.json.JSON;
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
		
		public static function call(command:String, params : Object) : void 
		{
			var variables : URLVariables = new URLVariables();
			variables[command] = new Object();
			for (var key:String in params) {
				variables[command][key] = params[key];
				trace('variables[command]['+key+']: ' + (variables[command][key]));
			}
			
			sendRequest(variables);
		}
		
		private static function sendRequest(variables : URLVariables, onResult : Function = null, onError : Function = null) : void 
		{
			trace("Connecting: http://" + ServerConfig.SERVER + ":" + ServerConfig.SOCKET_PORT);
			var request : URLRequest = new URLRequest("http://" + ServerConfig.SERVER + ":" + ServerConfig.SOCKET_PORT);
			request.data = variables;
			request.method = URLRequestMethod.POST;
			for (var key:String in variables)
			{
				Cc.log(variables[key]);
			}

			var urlLoader : URLLoader = new URLLoader();
			urlLoader.load(request);
			
			urlLoader.addEventListener(Event.COMPLETE, onRequestComplete);
		}
		
		private static function onRequestComplete(e:Event):void 
		{
			var o:Object = JSON.decode(e.currentTarget.data);
			Cc.log(e.currentTarget.data);
		}
		
		private static function showError(message:String):void 
		{
			trace("Error! :" + message);
		}
	}
}
