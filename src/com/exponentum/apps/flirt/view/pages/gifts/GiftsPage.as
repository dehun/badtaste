/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 9/11/12
 * Time: 11:32 AM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.gifts
{
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.controlls.scroll.Scroll;
import com.exponentum.apps.flirt.view.pages.profile.presents.Present;
import com.exponentum.utils.centerX;
import com.exponentum.utils.centerY;

import flash.events.Event;
import flash.events.MouseEvent;

import org.casalib.display.CasaSprite;
import org.casalib.layout.Distribution;

public class GiftsPage extends CasaSprite
{
	private var asset:PresentsWindowAsset = new PresentsWindowAsset();
	private var scroll:Scroll = new Scroll(320);
	private var presentsContainer:Distribution;

	public function GiftsPage(user:User)
	{
		addChild(asset);
		centerX(asset, 760);
		centerY(asset, 760);

		asset.closeButton.addEventListener(MouseEvent.CLICK, onClose);
		
		scroll.x = asset.x + 610;
		scroll.y = asset.y + 95;
		addChild(scroll);

		presentsContainer = new Distribution(asset.presentsMask.width);
		presentsContainer.x = asset.presentsMask.x;
		presentsContainer.y = asset.presentsMask.y;
		asset.addChildAt(presentsContainer, asset.getChildIndex(asset.presentsMask) - 1);
		presentsContainer.mask = asset.presentsMask;
		for (var i:int = 0; i < user.presents.length; i++)
		{
			var present:Present = new Present(user.presents[i], user);
			present.addEventListener(Present.PRESENT_LOADED, onPresentLoaded);
			presentsContainer.addChildWithDimensions(present);
		}
	}

	private function onPresentLoaded(e:Event):void
	{
		presentsContainer.position();
		scroll.visible = presentsContainer.height > asset.presentsMask.height;
		scroll.setTargetAndSource(presentsContainer, asset.presentsMask);
		scroll.step = 10;
		scroll.addEventListener(Event.CHANGE, onScroll);
	}

	private function onScroll(e:Event):void
	{
		var difference:Number = presentsContainer.height - asset.presentsMask.height;
		presentsContainer.y = asset.presentsMask.y + (e.currentTarget as Scroll).position * (-difference);
	}

	private function onClose(e:MouseEvent):void
	{
		this.destroy();
	}

	override public function destroy():void
	{
		removeChildren();
		asset = null;
		scroll.removeEventListener(Event.CHANGE, onScroll);
		scroll = null;
		super.destroy();
	}
}
}
