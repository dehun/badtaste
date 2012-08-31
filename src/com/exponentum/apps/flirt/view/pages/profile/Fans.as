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
	private var _controller:Controller;

	private var loadedFollowers:int = 0;
	private var _followers:Array;

	public function Fans(controller:Controller)
	{
		_controller = controller;
		addChild(fansBlock);
	}

	public function update(followers:Array):void
	{
		_followers = followers;

	}

	private function onFollowerLoaded(e:Event):void
	{

	}
}
}
