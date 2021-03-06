/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/11/12
 * Time: 4:21 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages
{
import com.exponentum.apps.flirt.model.Config;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.load.SwfLoad;

public class BackGroundedPage extends CasaSprite
{
	private var bgLoad:SwfLoad;
	public var background:CasaSprite = new CasaSprite();
	public var currentBg:int = -1;

	public function BackGroundedPage()
	{
		addChild(background);
	}

	public function setBackground(bgId:int):void
	{
		currentBg = bgId;
		bgLoad = new SwfLoad(Config.RESOURCES_SERVER + "backgrounds/bg" + bgId + ".swf");
		bgLoad.addEventListener(LoadEvent.COMPLETE, onBgLoaded);
		bgLoad.start();
	}

	private function onBgLoaded(e:LoadEvent):void
	{
		bgLoad.removeEventListener(LoadEvent.COMPLETE, onBgLoaded);
		background.removeChildren();
		background.addChild(bgLoad.contentAsMovieClip);
	}

	override public function destroy():void
	{
		removeChildren();
		if(bgLoad) bgLoad.removeEventListener(LoadEvent.COMPLETE, onBgLoaded);
		bgLoad = null;
		background = null;
		super.destroy();
	}
}
}
