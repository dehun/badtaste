/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/4/12
 * Time: 1:00 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile
{
import com.exponentum.apps.flirt.controller.Controller;

import flash.events.Event;

import org.casalib.display.CasaSprite;

public class Fans extends CasaSprite
{
	private var fansBlock:FansBlock = new FansBlock();

	public function Fans(controller:Controller)
	{
		addChild(fansBlock);
	}

	private var loadedFollowers:int = 0;

	public function update(followers:Array):void
	{

	}

	private function onFollowerLoaded(e:Event):void
	{

	}
}
}
