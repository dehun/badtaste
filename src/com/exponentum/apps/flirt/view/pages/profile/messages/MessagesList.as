/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/12/12
 * Time: 4:31 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile.messages
{
import com.exponentum.apps.flirt.view.controlls.scroll.Scroll;
import com.exponentum.utils.centerX;

import org.casalib.display.CasaSprite;

public class MessagesList extends CasaSprite
{
	private var bg:FriendList = new FriendList();
	private var messagesBG:MessagesBG = new MessagesBG();
	
	public function MessagesList()
	{
		addChild(bg);
		initAssets();
	}

	private function initAssets():void
	{
		while(bg.numChildren > 6) bg.removeChildAt(bg.numChildren - 1);
		
		bg.addChild(messagesBG);
		messagesBG.y = 70;
		centerX(messagesBG, bg.width);

		createScroll();
	}

	private function createScroll():void
	{
		var scr:Scroll = new Scroll(70);
		scr.x = messagesBG.width + 35;
		scr.y = messagesBG.y + 40;
		addChild(scr);
	}
}
}
