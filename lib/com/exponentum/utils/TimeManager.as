package com.exponentum.utils 
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author @author Alexandr Glagoliev <alex.glagoliev@gmail.com>
	 */
	public class TimeManager extends EventDispatcher
	{
		private var timer:Timer = new Timer(1000);
		
		private var _time:int = 0;
		
		
		//constructor
		public function TimeManager() 
		{
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		private function onTimer(e:TimerEvent):void 
		{
			_time ++;
		}
		
		//instantination
		private static var _instance:TimeManager;
		public static function get instance():TimeManager
		{
			if (_instance == null) {
				_instance = new TimeManager();
			}
			return _instance;
		}
		
		public function get time():int 
		{
			return _time;
		}
		
		public function set time(value:int):void 
		{
			_time = value;
		}
		
		//time formatters
		public function formatTime(t : int) : String {
			var s : int = Math.round(t);
			var m : int = 0;
			if (s > 0) {
				while (s > 59) {
					m++; 
					s -= 60;
				}
				return String((m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s);
			} else {
				return "00:00";
			}
		}
	}

}