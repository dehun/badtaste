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

import org.casalib.display.CasaSprite;

public class DialogWindow extends CasaSprite
{
	private var asset:DialogWindowAsset = new DialogWindowAsset();
	private var okFunction:Function;
	private var cancelFunction:Function;

	public function DialogWindow(messageText:String = "message",
								 headerText:String = "header",
								 yesButtonText:String = "OK",
								 noButtonText:String = "CANCEL",
								 onOk:Function = null,
								 onCancel:Function = null)
	{
		addChild(asset);
		asset.message.text = messageText;
		asset.header.text = headerText;
		asset.yesButton.label.text = yesButtonText;
		asset.noButton.label.text = noButtonText;

		asset.yesButton.gotoAndStop(1);
		asset.yesButton.addEventListener(MouseEvent.MOUSE_OVER, onYesOver);
		asset.yesButton.addEventListener(MouseEvent.MOUSE_OUT, onYesOut);
		asset.yesButton.addEventListener(MouseEvent.MOUSE_DOWN, onYesDown);
		asset.yesButton.addEventListener(MouseEvent.MOUSE_UP, onYesUp);

		asset.noButton.gotoAndStop(1);
		asset.noButton.addEventListener(MouseEvent.MOUSE_OVER, onNoOver);
		asset.noButton.addEventListener(MouseEvent.MOUSE_OUT, onNoOut);
		asset.noButton.addEventListener(MouseEvent.MOUSE_DOWN, onNoDown);
		asset.noButton.addEventListener(MouseEvent.MOUSE_UP, onNoUp);

		asset.closeButton.addEventListener(MouseEvent.CLICK, onClose);

		if(onOk) okFunction = onOk;
		if(onCancel) cancelFunction = onCancel;

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


	private function onNoOver(e:MouseEvent):void
	{
		asset.noButton.gotoAndStop(2);
	}

	private function onNoOut(e:MouseEvent):void
	{
		asset.noButton.gotoAndStop(1);
	}

	private function onNoDown(e:MouseEvent):void
	{
		asset.noButton.gotoAndStop(3);
	}

	private function onNoUp(e:MouseEvent):void
	{
		asset.noButton.gotoAndStop(2);
		if(cancelFunction) cancelFunction.apply();
		this.destroy();
	}


	private function onClose(e:MouseEvent):void
	{
		if(cancelFunction) cancelFunction.apply();
		this.destroy();
	}

	override public function destroy():void
	{
		asset.yesButton.removeEventListener(MouseEvent.MOUSE_OVER, onYesOver);
		asset.yesButton.removeEventListener(MouseEvent.MOUSE_OUT, onYesOut);
		asset.yesButton.removeEventListener(MouseEvent.MOUSE_DOWN, onYesDown);
		asset.yesButton.removeEventListener(MouseEvent.MOUSE_UP, onYesUp);

		asset.noButton.removeEventListener(MouseEvent.MOUSE_OVER, onNoOver);
		asset.noButton.removeEventListener(MouseEvent.MOUSE_OUT, onNoOut);
		asset.noButton.removeEventListener(MouseEvent.MOUSE_DOWN, onNoDown);
		asset.noButton.removeEventListener(MouseEvent.MOUSE_UP, onNoUp);
		removeChildren();
		asset = null;
		okFunction = null;
		cancelFunction = null;
		super.destroy();
	}
}
}
