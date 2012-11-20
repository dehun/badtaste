package com.exponentum.utils {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class RoundedPreloader extends Sprite {  
		private var _color : uint;  
		private var _minRadius : int;  
		private var _segmentsCount : int;  
		private var _segmentLength : int;
		//private var _rotationSpeed : int;  
		private var _timer : Timer;
		private var _playing : Boolean = true;

		// ------------- public
		public function RoundedPreloader(pColor : uint = 0x666666, minRadius : int = 10, segmentLength : int = 10, segmentsCount : int = 12, rotationSpeed : int = 40) {  
			 
			_color = pColor;  
			_minRadius = minRadius;  
			_segmentLength = segmentLength;
			_segmentsCount = segmentsCount;  
			_timer = new Timer(rotationSpeed);
			_timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
			
			render();  
		}  

		public function play() : void {
			if (!_playing || !_timer) return;
			_timer.start();
			_playing = true;
		}

		public function stop() : void {
			if (!_playing || !_timer)return;
			_timer.stop();
			_playing = false;
		}

		public function destroy() : void {
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, onTimerHandler);
			while (numChildren) { 
				removeChildAt(0); 
			}											
			if(stage && parent)	parent.removeChild(this);
		}

		public function get color() : uint { 
			return _color; 
		}

		public function set color(colorValue : uint) : void {
			_color = colorValue;																
			while (numChildren) { 
				removeChildAt(0); 
			}
			render();
		}

		public function get segmentLength() : int { 
			return _segmentLength; 
		}

		public function set segmentLength(lengthValue : int) : void {
			_segmentLength = lengthValue;														
			while (numChildren) { 
				removeChildAt(0); 
			}											
			render();									
		}

		public function get segmentsCount() : int { 
			return _segmentsCount; 
		}

		public function set segmentsCount(countValue : int) : void {
			_segmentsCount = countValue;			
			if (_segmentsCount < 5) _segmentsCount = 5;
			while (numChildren) { 
				removeChildAt(0); 
			}
			render();
		}

		public function get minRadius() : int { 
			return _minRadius; 
		}

		public function set minRadius(radiusValue : int) : void {
			_minRadius = radiusValue;					
			while (numChildren) { 
				removeChildAt(0); 
			}											
			render();									
		}

		public function get speed() : int { 
			return _timer.delay; 
		}								

		private function render() : void {  
			for(var i : int = 0;i < _segmentsCount;i++) {
				var line : Shape = drawRoundedPreloaderRect(_segmentLength, _segmentLength * 0.4, _segmentLength * 0.2, _color);
				line.x = _minRadius;
				line.y = -line.height / 2;
				var tempMc : Sprite = new Sprite();
				tempMc.addChild(line);
				tempMc.alpha = 0.3 + 0.7 * i / _segmentsCount;
				tempMc.rotation = 360 * i / _segmentsCount;
				addChild(tempMc);
			}
		}  

		private function onTimerHandler(e : TimerEvent) : void {  
			rotation += 360 / _segmentsCount;  
		}  

		private function drawRoundedPreloaderRect(w : Number, h : Number, bevel : Number = 0, color : uint = 0x000000, alpha : Number = 1) : Shape {
			var mc : Shape = new Shape();
			mc.graphics.beginFill(color, alpha);
			mc.graphics.moveTo(w - bevel, h);              	
			mc.graphics.curveTo(w, h, w, h - bevel);       
			mc.graphics.lineTo(w, bevel);                  	
			mc.graphics.curveTo(w, 0, w - bevel, 0);       	
			mc.graphics.lineTo(bevel, 0);                  	
			mc.graphics.curveTo(0, 0, 0, bevel);           	
			mc.graphics.lineTo(0, h - bevel);              	
			mc.graphics.curveTo(0, h, bevel, h);           	
			mc.graphics.lineTo(w - bevel, h);              	
			mc.graphics.endFill();
			return mc;
		}

		public function set speed(speedValue : int) : void {
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, onTimerHandler);
			_timer = new Timer(speedValue);
			_timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
			if(_playing) {
				_timer.start();
			}
		}
	}  
}  