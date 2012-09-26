package ru.evast.integration.core 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Andrey Pavlov. skype ctrl_break. email: obsidium@yandex.ru
	 */
	public class IntegrationEvent extends Event 
	{
		public static const USER_BALANCE_CHANGE:String = "user_balance_change";
		
		/*public static const REQUEST_IO_ERROR:String = "request_io_error";
		public static const REQUEST_SEC_ERROR:String = "requset_security_error";*/
		
		public var dataString:String;
		public var dataObject:Object;
		public var dataInt:int;
		
		public function IntegrationEvent(type:String, dataInt:int = 0, dataString:String = "", dataObject:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			this.dataInt = 		dataInt;
			this.dataString = 	dataString;
			this.dataObject = 	dataObject;
		}
		public override function clone():Event { return new IntegrationEvent(type, dataInt, dataString, dataObject, bubbles, cancelable); }		
	}

}