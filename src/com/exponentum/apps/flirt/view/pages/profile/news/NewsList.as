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

import flash.events.Event;

import org.casalib.display.CasaSprite;
import org.casalib.layout.Distribution;

public class NewsList extends CasaSprite
{
	private var bg:FriendList = new FriendList();
	private var newsBG:MessagesBG = new MessagesBG();

	private var newsDistribution:Distribution = new Distribution(580);
	private var _bottomPanelMask:BottomPanelMask = new BottomPanelMask();
	
	public function NewsList()
	{
		addChild(bg);
		initAssets();
	}

	private function initAssets():void
	{
		while(bg.numChildren > 1) bg.removeChildAt(bg.numChildren - 1);

		newsDistribution.x = 75;
		newsDistribution.y = 75;

		addChild(newsDistribution);
		_bottomPanelMask.x = newsDistribution.x;
		_bottomPanelMask.y = newsDistribution.y;
		addChild(_bottomPanelMask);
		newsDistribution.mask = _bottomPanelMask;
		bg.addChild(newsBG);

		newsBG.y = 63;
		centerX(newsBG, bg.width);
	}

	public function updateNews():void
	{
//		var messages:Array = Model.instance.mail;
//		messagesDistribution.removeChildren(true, true);
//		for (var i:int = 0; i < messages.length; i++)
//		{
//			var mi:MessageItem = new MessageItem(messages[i]);
//			addChild(mi);
//		}
//		messagesDistribution.position();
		var news:Array = [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}];
		newsDistribution.removeChildren(true, true);
		for (var i:int = 0; i < news.length; i++)
		{
			var mi:NewsItem = new NewsItem(news[i]);
			newsDistribution.addChild(mi);
		}
		newsDistribution.position();

		createScroll();
	}

	private function createScroll():void
	{
		var scr:Scroll = new Scroll(75);
		scr.x = newsBG.width + 40;
		scr.y = newsBG.y + 27;
		scr.setTargetAndSource(newsDistribution, _bottomPanelMask);
		scr.step = 10;
		scr.addEventListener(Event.CHANGE, onScroll);
		addChild(scr);
	}

	private function onScroll(e:Event):void
	{
		var difference:Number = newsDistribution.height - _bottomPanelMask.height;
		newsDistribution.y = _bottomPanelMask.y + (e.currentTarget as Scroll).position * (-difference);
	}
}
}
