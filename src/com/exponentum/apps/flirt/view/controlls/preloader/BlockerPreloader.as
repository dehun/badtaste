/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 9/19/12
 * Time: 12:55 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.controlls.preloader
{
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.sampler.Sample;

import org.casalib.display.CasaSprite;

public class BlockerPreloader extends CasaSprite
{
	private var blocker:CasaSprite;
	private var preloader:RoundedPreloader;

	private var _parent:Sprite;
	private var _alpha:Number;
	private var _w:Number;
	private var _h:Number;

	public function BlockerPreloader(aParent:Sprite, w:int, h:int, anAlpha:Number = 0)
	{
		_parent = aParent;
		_alpha = anAlpha;
		_w = w;
		_h = h;
		_parent.addChild(this);
	}

	private var partsToLoad:int = 0;
	private var _partsLoaded:int = 0;

	public function preload(parts:int):void
	{
		partsToLoad = parts;

		blocker = new CasaSprite();
		blocker.graphics.lineStyle(1, 0x0, 0);
		blocker.graphics.beginFill(0x0, _alpha);
		blocker.graphics.drawRect(0, 0, _w, _h);
		addChild(blocker);

		preloader = new RoundedPreloader(0xffffff);
		preloader.x = _w/2;
		preloader.y = _h/2;
		addChild(preloader);
		preloader.play();
	}

	public function get partsLoaded():int
	{
		return _partsLoaded;
	}

	public function set partsLoaded(value:int):void
	{
		_partsLoaded = value;
		if(partsLoaded == partsToLoad) destroy();
	}

	override public function destroy():void
	{
		removeChildren(true, true);
		blocker = null;
		preloader = null;
		super.destroy();
	}
}
}
