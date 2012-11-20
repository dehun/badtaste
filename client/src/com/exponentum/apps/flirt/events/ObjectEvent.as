package com.exponentum.apps.flirt.events {
	import flash.events.Event;

	/**
	 * @author Alexandr Glagoliev 
	 * @mail alex.glagoliev[at]gmail.com
	 * 2010
	 */
	public class ObjectEvent extends Event {
		
		public var data : Object;
		
		/*
		* constructor
		*/
		public function ObjectEvent(type : String, dataVal : Object = null, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
			
			data = dataVal;
		}
		
		override public function clone() : Event {
			var e : Event = new Event(type, bubbles, cancelable);
			
			return e;
		}
	}
}