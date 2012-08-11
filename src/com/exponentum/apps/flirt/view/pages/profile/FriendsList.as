/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/6/12
 * Time: 10:30 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile
{
import com.exponentum.utils.centerX;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;

import org.casalib.display.CasaSprite;
import org.casalib.layout.Distribution;

public class FriendsList extends CasaSprite
{
	private const MAX_FRIENDS:int = 6;
	private var bg:FriendList = new FriendList();
	private var container:Distribution = new Distribution();


	//controls of friendlist
	private var oneLeft:MovieClip;
	private var fastLeft:MovieClip;
	private var oneRight:MovieClip;
	private var fastRight:MovieClip;

	public function FriendsList()
	{
		initAssets();
		container.y = 72;
		addChild(container);

		for (var i:int = 0; i < MAX_FRIENDS; i++)
		{
			container.addChildWithDimensions(new FriendItem(), 97);
			container.position();
			centerX(container, bg.width);
		}

	}

	private function initAssets():void
	{
		addChild(bg);
		oneLeft = bg.leftButton;
		oneRight = bg.rightButton;
		fastLeft = bg.fLeftButton;
		fastRight = bg.fRightButton;

		oneLeft.addEventListener(MouseEvent.CLICK, onLeft);
		oneRight.addEventListener(MouseEvent.CLICK, onRight);
		fastLeft.addEventListener(MouseEvent.CLICK, onFastLeft);
		fastRight.addEventListener(MouseEvent.CLICK, onFastRight);
	}

	private function onLeft(e:MouseEvent):void
	{

	}

	private function onRight(e:MouseEvent):void
	{

	}

	private function onFastLeft(e:MouseEvent):void
	{

	}

	private function onFastRight(e:MouseEvent):void
	{

	}


}
}
