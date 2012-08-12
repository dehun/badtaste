/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/12/12
 * Time: 4:44 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.controlls.scroll
{
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
	}

	private function onScrubberUp(e:MouseEvent):void
	{
		scrubber.stopDrag();
	}

	private function onScrubberDown(e:MouseEvent):void
	{
		scrubber.startDrag(true, new Rectangle(scrollBackground.x, scrollBackground.y + scrubber.height / 2, 0, scrollBackground.height - scrubber.height));
		this.stage.addEventListener(MouseEvent.MOUSE_UP, onScrubberUp);
	}

	private function onDownClick(e:MouseEvent):void
	{

	}

	private function onUpClick(e:MouseEvent):void
	{

	}
}
}
