/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 10/5/12
 * Time: 10:50 AM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.common
{
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.view.controlls.Align;

import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import mx.utils.NameUtil;

import org.casalib.display.CasaSprite;

public class InfoWindow extends CasaSprite
{
	private var asset:infoWindowAsset = new infoWindowAsset();
	private var okFunction:Function;

	public function InfoWindow(messageText:String = "message",
							   headerText:String = "header",
							   yesButtonText:String = "OK",
							   onOk:Function = null)
	{
		addChild(asset);
		asset.message.text = messageText;
		asset.message.wordWrap = true;
		asset.header.text = headerText;
		asset.yesButton.label.text = yesButtonText;

		asset.yesButton.gotoAndStop(1);
		asset.yesButton.addEventListener(MouseEvent.MOUSE_OVER, onYesOver);
		asset.yesButton.addEventListener(MouseEvent.MOUSE_OUT, onYesOut);
		asset.yesButton.addEventListener(MouseEvent.MOUSE_DOWN, onYesDown);
		asset.yesButton.addEventListener(MouseEvent.MOUSE_UP, onYesUp);

		asset.closeButton.addEventListener(MouseEvent.CLICK, onClose);

		if(onOk) okFunction = onOk;
		this.filters = [new DropShadowFilter(0, 45, 0x0, 1, 30, 30, 1, 3)];

		Align.center(this, Model.instance.view);
	}

	private function onYesOver(e:MouseEvent):void
	{
		asset.yesButton.gotoAndStop(2);
	}

	private function onYesOut(e:MouseEvent):void
	{
		asset.yesButton.gotoAndStop(1);
	}

	private function onYesDown(e:MouseEvent):void
	{
		asset.yesButton.gotoAndStop(3);
	}

	private function onYesUp(e:MouseEvent):void
	{
		asset.yesButton.gotoAndStop(2);
		if(okFunction) okFunction.apply();
		this.destroy();
	}

	private function onClose(e:MouseEvent):void
	{
		this.destroy();
	}

	override public function destroy():void
	{
		asset.yesButton.removeEventListener(MouseEvent.MOUSE_OVER, onYesOver);
		asset.yesButton.removeEventListener(MouseEvent.MOUSE_OUT, onYesOut);
		asset.yesButton.removeEventListener(MouseEvent.MOUSE_DOWN, onYesDown);
		asset.yesButton.removeEventListener(MouseEvent.MOUSE_UP, onYesUp);
		removeChildren();
		asset = null;
		okFunction = null;
		super.destroy();
	}
}
}
