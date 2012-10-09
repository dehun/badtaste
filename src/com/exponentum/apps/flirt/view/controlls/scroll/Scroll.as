/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/12/12
 * Time: 4:44 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.controlls.scroll
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import org.casalib.display.CasaSprite;

public class Scroll extends CasaSprite
{
	private var scrollBackground:ScrollBg = new ScrollBg();
	private var upButton:ScrollUpButton = new ScrollUpButton();
	private var downButton:ScrollDownButton = new ScrollDownButton();
	private var scrubber:ScrollScrubber = new ScrollScrubber();

	private var _scrollHeight:int = 100;

	private var _target:DisplayObject;
	private var _source:DisplayObject;
	private var _step:int = 10;
	private var _position:Number = 0;


	public function Scroll(aHeight:int)
	{
		create();
		scrollHeight = aHeight;
	}

	private function create():void
	{
		addChild(upButton);
		addChild(scrollBackground);
		addChild(downButton);
		addChild(scrubber);
	}

	public function setTargetAndSource(targetValue:DisplayObject, sourceValue:DisplayObject):void
	{
		_target = targetValue;
		_source = sourceValue;

		this.visible = (_target.height > _source.height);
	}

	public function set scrollHeight(value:int):void
	{
		_scrollHeight = value;

		scrollBackground.height = value;
		downButton.y 			= scrollBackground.y + scrollBackground.height;
		scrubber.y 				= scrollBackground.y + scrubber.height / 2;
		
		startListen();
	}

	private function startListen():void
	{
		upButton.addEventListener(MouseEvent.CLICK, onUpClick);
		downButton.addEventListener(MouseEvent.CLICK, onDownClick);
		scrubber.addEventListener(MouseEvent.MOUSE_DOWN, onScrubberDown);
		scrubber.addEventListener(MouseEvent.MOUSE_UP, onScrubberUp);
		scrubber.addEventListener(MouseEvent.MOUSE_OVER, onScrubberOver);
		scrubber.addEventListener(MouseEvent.MOUSE_OUT, onScrubberOut);
		scrubber.gotoAndStop(1);
	}

	private function onScrubberOut(e:MouseEvent):void
	{
		scrubber.gotoAndStop(1);
	}

	private function onScrubberOver(e:MouseEvent):void
	{
		scrubber.gotoAndStop(2);
	}

	private function onScrubberUp(e:MouseEvent):void
	{
		scrubber.stopDrag();
		scrubber.gotoAndStop(1);
		removeEventListener(Event.ENTER_FRAME, onScrub);
	}

	private function onScrubberDown(e:MouseEvent):void
	{
		scrubber.gotoAndStop(3);
		scrubber.startDrag(true, new Rectangle(scrollBackground.x, scrollBackground.y + scrubber.height / 2, 0, scrollBackground.height - scrubber.height));
		this.stage.addEventListener(MouseEvent.MOUSE_UP, onScrubberUp);
		
		addEventListener(Event.ENTER_FRAME, onScrub);
	}

	private function onScrub(e:Event = null):void
	{
		if(_position ==Math.ceil(scrubber.y - (scrollBackground.y + scrubber.height / 2)) / (scrollBackground.height - scrubber.height)) return;
 		_position = Math.ceil(scrubber.y - (scrollBackground.y + scrubber.height / 2)) / (scrollBackground.height - scrubber.height);
		_position = Math.min(_position, 1);
		_position = Math.max(_position, 0);
		trace(_position);
		dispatchEvent(new Event(Event.CHANGE));
	}

	private function onDownClick(e:MouseEvent):void
	{
		var validStep:Number = (scrollBackground.height - scrubber.height) / _step;
		scrubber.y = Math.min(scrollBackground.height - scrubber.height / 2, scrubber.y + validStep);
		onScrub();
	}

	private function onUpClick(e:MouseEvent):void
	{
		var validStep:Number = (scrollBackground.height - scrubber.height) / _step;
		scrubber.y = Math.max(scrubber.height / 2, scrubber.y - validStep);
		onScrub();
	}

	private function updateScroll():void
	{

	}

	public function set step(value:int):void
	{
		_step = value;
	}

	public function get position():Number
	{
		return _position;
	}

	public function set position(value:Number):void
	{
		_position = value;
		scrubber.y = (scrollBackground.height - scrubber.height / 2) * _position;
	}
}
}
