package com.exponentum.apps.flirt.view.controlls
{
	import flash.geom.Rectangle;
	import flash.display.DisplayObject
	import flash.geom.Point;
	/**
	 * ...
	 * @author Anton Bodrichenko. abodrichenko@gmail.com
	 */
	public class Align
	{
		/*
		public static var TOP_EDGE:Function = topEdge;
		public static var TOP_LEFT_EDGE:Function = topLeftEdge;
		public static var LEFT_EDGE:Function = leftEdge;
		public static var RIGHT_EDGE:Function = rightEdge;
		public static var MATCH_SIZE:Function = matchSize;
		public static var HORIZONTAL_CENTER:Function = horizontalCenter;
		public static var VERTICAL_CENTER:Function = verticalCenter;
		*/
		public function Align() 
		{
			
		}

		public static function matchSize(target:DisplayObject, source:DisplayObject):void {
			target.width = source.width;
			target.height = source.height;
		}
		
		//				BEHIND
		public static function rightBehind(target:DisplayObject, source:DisplayObject, indent:int = 0):void {
			const offset:Point = getOffsetPosition(target).subtract(getOffsetPosition(source));
			target.x = int(offset.x + source.x+source.width) + indent;
		}
		public static function leftBehind(target:DisplayObject, source:*, indent:int = 0):void {
			var offset:Point = ((source is DisplayObject) ? getOffsetPosition(target).subtract(getOffsetPosition(source)) : new Point(source.x, source.y));
			target.x = int(offset.x + source.x-target.width) - indent;
		}
		public static function topBehind(target:DisplayObject, source:DisplayObject, indent:int = 0):void {
			const offset:Point = getOffsetPosition(target).subtract(getOffsetPosition(source));
			target.y = int(offset.y + source.y - target.height) - indent;
		}
		public static function bottomBehind(target:DisplayObject, source:DisplayObject, indent:int = 0):void {
			const offset:Point = getOffsetPosition(target).subtract(getOffsetPosition(source));
			target.y = int(offset.y + source.y + source.height) + indent;
		}
		
		//				EDGE
		public static function topLeftEdge(target:DisplayObject, source:DisplayObject):void {
			topEdge(target, source);
			leftEdge(target, source);
		}
		public static function topRightEdge(target:DisplayObject, source:DisplayObject):void {
			topEdge(target, source);
			rightEdge(target, source);
		}
		
		public static function topEdge(target:DisplayObject, source:*, indent:int = 0):void {
			var offset:Point = ((source is DisplayObject) ? getOffsetPosition(target).subtract(getOffsetPosition(source)) : new Point(source.x, source.y));
			target.y = int(offset.y + source.y) + indent;
		}
		public static function bottomEdge(target:DisplayObject, source:*, indent:int = 0):void {
			var offset:Point = ((source is DisplayObject) ? getOffsetPosition(target).subtract(getOffsetPosition(source)) : new Point(source.x, source.y));
			target.y = int(offset.y + source.y + (source.height  - target.height)) - indent;
		}
		public static function leftEdge(target:DisplayObject, source:*, indent:int = 0):void {
			var offset:Point = ((source is DisplayObject) ? getOffsetPosition(target).subtract(getOffsetPosition(source)) : new Point(source.x, source.y));
			target.x = int(offset.x + source.x) + indent;
		}
		public static function rightEdge(target:DisplayObject, source:*, indent:int = 0):void {
			var offset:Point = ((source is DisplayObject) ? getOffsetPosition(target).subtract(getOffsetPosition(source)) : new Point(source.x, source.y));
			target.x = int(offset.x + (source.width - target.width)+source.x) - indent;
		}
		//				CENTER
		public static function center(target:DisplayObject, source:*):void {
			var offset:Point = ((source is DisplayObject) ? getOffsetPosition(target).subtract(getOffsetPosition(source)) : new Point(source.x, source.y));
			target.x = int(offset.x + (source.width - target.width) * 0.5 + source.x);
			target.y = int(offset.y + (source.height - target.height) * 0.5 + source.y);
		}
		public static function centerHorizontal(target:DisplayObject, source:DisplayObject, indent:int = 0):void {
			if (!target) return;
			const offset:Point = getOffsetPosition(target).subtract(getOffsetPosition(source));
			target.x = int(offset.x + (source.width - target.width) * 0.5 + source.x) + indent;
		}
		public static function centerVertical(target:DisplayObject, source:DisplayObject, indent:int = 0):void {
			const offset:Point = getOffsetPosition(target).subtract(getOffsetPosition(source));
			target.y = int(offset.y + (source.height  - target.height) * 0.5 + source.y) + indent;
		}
		
		//				corner
		public static function topLeftCorner(target:DisplayObject, source:DisplayObject, indent:int = 0):void {
			const offset:Point = getOffsetPosition(target).subtract(getOffsetPosition(source));
			target.y = int(offset.y + source.y - target.height*0.5) + indent;
			target.x = int(offset.x + source.x - target.width*0.5) + indent;
		}
		public static function topRightCorner(target:DisplayObject, source:DisplayObject, indent:int = 0):void {
			const offset:Point = getOffsetPosition(target).subtract(getOffsetPosition(source));
			target.y = int(offset.y + source.y - target.height*0.5) - indent;
			target.x = int(offset.x + source.x - target.width*0.5 +source.width) + indent;
		}
		private static function getOffsetPosition(displayObject:DisplayObject):Point {
			const bounds:Rectangle = displayObject.getBounds(displayObject);
			const offset:Point     = new Point();
			
			//return new Point(displayObject.x, displayObject.y);
			
			offset.x = (displayObject.scaleX > 0) ? bounds.left * displayObject.scaleX * -1 : bounds.right * displayObject.scaleX * -1
			offset.y = (displayObject.scaleY > 0) ? bounds.top * displayObject.scaleY * -1 : bounds.bottom * displayObject.scaleY * -1
			
			return offset;
		}

	}

}