/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/4/12
 * Time: 1:41 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.controlls.tabbar
{
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.utils.centerX;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

import org.casalib.display.CasaSprite;
import org.osmf.events.FacetValueChangeEvent;

public class TabButton extends CasaSprite
{
	public static const NORMAL:String = "normal";
	public static const HIGHLIGHTED:String = "highlighted";
	public static const SELECTED:String = "selected";
	public static const TAB_SELECTED:String = "tabSelected";
	
	private var _mc:MovieClip;
	
	private var _label:String = "";
	public var toggle:Boolean = true;
	
	public function TabButton(mc:MovieClip)
	{
		_mc = mc;
		addChild(mc);
		if(_mc["buttonLabel"]) (_mc["buttonLabel"] as TextField).mouseEnabled = false;

		enable();
	}

	private function onClick(e:MouseEvent):void
	{
		select();
	}

	private function onMouseOver(e:MouseEvent):void
	{
		_mc.gotoAndStop(HIGHLIGHTED);
	}

	private function onMouseOut(e:MouseEvent):void
	{
		_mc.gotoAndStop(NORMAL);
	}

	public function enable():void
	{
		_mc.gotoAndStop(NORMAL);
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		_mc.buttonMode = _mc.useHandCursor = true;
	}

	public function disable():void
	{
		_mc.gotoAndStop(SELECTED);
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		_mc.buttonMode = _mc.useHandCursor = false;
	}

	public function deselect():void
	{
		enable();
	}

	public function select():void
	{
		disable();
		dispatchEvent(new Event(TAB_SELECTED));
	}

	public function set label(value:String):void
	{
		_label = value;
		_mc["buttonLabel"].text = value;
	}
}
}
