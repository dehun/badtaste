/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/13/12
 * Time: 9:08 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile.presents
{
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;

import flash.events.Event;
import flash.events.MouseEvent;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.load.SwfLoad;

public class Present extends CasaSprite
{
	public static const PRESENT_LOADED:String = "presentLoaded";
	private var presentLoad:SwfLoad;
	private var _presentOwner:User;
	
	public function Present(present:Object, presentOwner:User)
	{
		_presentOwner = presentOwner;

		presentLoad = new SwfLoad(Config.RESOURCES_SERVER + "gifts/gift" + present.SendedGift.giftGuid + ".swf");
		presentLoad.addEventListener(LoadEvent.COMPLETE, onBgLoaded);
		presentLoad.start();
	}

	private function onBgLoaded(e:LoadEvent):void
	{
		this.removeChildren(true, true);
		this.addChild(presentLoad.contentAsMovieClip);
		dispatchEvent(new Event(PRESENT_LOADED));

		addEventListener(MouseEvent.CLICK, onPresentClick);
	}

	private function onPresentClick(e:MouseEvent):void
	{
		Model.instance.view.showGiftsWindow(_presentOwner);
	}
}
}
