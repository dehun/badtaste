/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/12/12
 * Time: 4:31 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile.news
{
import com.exponentum.apps.flirt.view.controlls.scroll.Scroll;
import com.exponentum.utils.centerX;

import org.casalib.display.CasaSprite;

public class NewsList extends CasaSprite
{
	private var bg:FriendList = new FriendList();
	private var newsBG:MessagesBG = new MessagesBG();
	
	public function NewsList()
	{
		addChild(bg);
		initAssets();
	}

	private function initAssets():void
	{
		while(bg.numChildren > 1) bg.removeChildAt(bg.numChildren - 1);
		
		bg.addChild(newsBG);
		newsBG.y = 63;
		centerX(newsBG, bg.width);

		createScroll();
	}

	private function createScroll():void
	{
		var scr:Scroll = new Scroll(75);
		scr.x = newsBG.width + 40;
		scr.y = newsBG.y + 27;
		addChild(scr);
	}
}
}
