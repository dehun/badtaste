/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/23/12
 * Time: 9:41 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.gamefield.chat
{
import com.exponentum.apps.flirt.view.controlls.scroll.Scroll;

import org.casalib.display.CasaSprite;

public class Chat extends CasaSprite
{
	public function Chat()
	{
		createScroll();
	}

	private function createScroll():void
	{
		var scr:Scroll = new Scroll(75);
		scr.x = 0;
		scr.y = 0;
		addChild(scr);
	}
}
}
