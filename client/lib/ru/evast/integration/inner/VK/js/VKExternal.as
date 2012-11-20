package ru.evast.integration.inner.VK.js{
	
	/*
		Этот класс использует preload.js
	*/
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	public class VKExternal extends Object{

		static private const EXTERNAL_CALL:String = "VK.api('{METHOD}', {PARAMS}, function (data) {getSWF('apitech_loader').{CALL_FUNC}(data.response);} )";
		
		private var availble:Boolean = false;
		
		public function VKExternal ():void {
			try {
				if (ExternalInterface.available) {
					availble = true;
				}
				else {
					availble = false;
				}
			} catch (e:Error) {
				trace('ExternalInterface can not be init, error+' + e.name + '[' + e.errorID + ']: ' + e.message);
			}
		}
		
		public function getFunction(method:String, params:Object = null, callback:Function = null):void {
			ExternalInterface.addCallback(method, callback);
			ExternalInterface.call(EXTERNAL_CALL.split('{METHOD}').join(method).split('{PARAMS}').join(toJSParams(params)).split('{CALL_FUNC}').join(method));
		}
		
		public function getAction(method:String, params:Object = null) :void {
			ExternalInterface.call(EXTERNAL_CALL.split('{METHOD}').join(method).split('{PARAMS}').join(toJSParams(params)).split('{CALL_FUNC}').join(method));
		}
		
		private function toJSParams(params:Object):String {
			var paramsJS:String = '{';
			for (var item:String in params) {
				paramsJS += item + " : '" + params[item]+"',";
			}
			paramsJS = paramsJS.substr(0, paramsJS.length - 1) + " }";
			return paramsJS;
		}
		
		/*
			public function ShowSettingsBox(val:int):void	{
				if (availble) {
					ExternalInterface.call("VK.External.showSettingsBox(" +String(val) +")");
				}
			}
			public function SaveWallPost(hash:String):void {
				if (availble) {
					ExternalInterface.call("VK.External.saveWallPost(" + hash +")");
				}
			}
		*/
	}
	
}