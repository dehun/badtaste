/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/21/12
 * Time: 9:27 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.gamefield
{
import com.exponentum.apps.flirt.model.Config;
import com.greensock.TweenMax;

import flash.events.Event;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.load.SwfLoad;

public class Bottle extends CasaSprite
{
	private var bottleLoad:SwfLoad;
	private var container:CasaSprite = new CasaSprite();

	private const playersAngles:Array = [310,340,20,55,90,115,150,210,245,270,315];

	public static const BOTTLE_STOPPED:String = "bottleStopped";

	public function Bottle()
	{
		addChild(container);
	}

	private function onBottleLoaded(e:LoadEvent):void
	{
		container.removeChildren(true, true);
		container.addChild(bottleLoad.contentAsMovieClip);
		bottleLoad.contentAsMovieClip.x = -bottleLoad.contentAsMovieClip.width / 2;
		bottleLoad.contentAsMovieClip.y = -bottleLoad.contentAsMovieClip.height / 2;
	}

	//---------------------------------------------------------------------------------------------------
	// public
	//---------------------------------------------------------------------------------------------------
	public function setBottle(bottleId:int):void
	{
		bottleLoad = new SwfLoad(Config.RESOURCES_SERVER + "bottles/bottle" + bottleId + ".swf");
		bottleLoad.addEventListener(LoadEvent.COMPLETE, onBottleLoaded);
		bottleLoad.start();

	}
	
	public function showOnPlayer(placeId:int, numRotations:int = 1):void
	{
		TweenMax.to(container, numRotations * .5, {rotation:numRotations * 360 + playersAngles[placeId], onComplete:function():void{
			dispatchEvent(new Event(BOTTLE_STOPPED));
		}});
	}
}
}
