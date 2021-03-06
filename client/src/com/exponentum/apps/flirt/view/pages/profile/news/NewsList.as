/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/12/12
 * Time: 4:31 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile.news
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.view.controlls.scroll.Scroll;
import com.exponentum.apps.flirt.view.pages.gamefield.Bottle;
import com.exponentum.apps.flirt.view.pages.profile.BottomPanel;
import com.exponentum.apps.flirt.view.pages.profile.messages.MessageItem;
import com.exponentum.utils.centerX;

import flash.events.Event;

import mx.utils.NameUtil;

import org.casalib.display.CasaSprite;
import org.casalib.layout.Distribution;

public class NewsList extends CasaSprite
{
	private var bg:FriendList = new FriendList();
	private var messagesBG:MessagesBG = new MessagesBG();

	private var messagesDistribution:Distribution = new Distribution(580);
	private var _bottomPanelMask:BottomPanelMask = new BottomPanelMask();


	public function NewsList()
	{
		addChild(bg);
		messagesDistribution.x = 75;
		messagesDistribution.y = 75;

		addChild(messagesDistribution);
		_bottomPanelMask.x = messagesDistribution.x;
		_bottomPanelMask.y = messagesDistribution.y;
		addChild(_bottomPanelMask);
		messagesDistribution.mask = _bottomPanelMask;

		initAssets();
	}

	private function onMailBox(e:Event):void
	{
		Model.instance.removeEventListener(Controller.ON_GOT_MAILBOX, onMailBox);
		var messages:Array = Model.instance.mailbox;
		messagesDistribution.removeChildren(true, true);
		for (var i:int = 0; i < messages.length; i++)
		{
			if(messages[i].Mail.type == "news"){
				var mi:MessageItem = new MessageItem(messages[i]);

				messagesDistribution.addChild(mi);
			}
		}
		messagesDistribution.position();
	}

	public function updateMessages():void
	{
		Model.instance.addEventListener(Controller.ON_GOT_MAILBOX, onMailBox);
		Controller.instance.checkMailbox();
	}

	private function initAssets():void
	{
		while(bg.numChildren > 1) bg.removeChildAt(bg.numChildren - 1);

		bg.addChild(messagesBG);
		messagesBG.y = 63;
		centerX(messagesBG, bg.width);

		createScroll();
	}

	private function createScroll():void
	{
		var scr:Scroll = new Scroll(75);
		scr.x = messagesBG.width + 40;
		scr.y = messagesBG.y + 27;
		scr.setTargetAndSource(messagesDistribution, _bottomPanelMask);
		scr.step = 10;
		scr.addEventListener(Event.CHANGE, onScroll);
		addChild(scr);
	}

	private function onScroll(e:Event):void
	{
		var difference:Number = messagesDistribution.height - _bottomPanelMask.height;
		messagesDistribution.y = _bottomPanelMask.y + (e.currentTarget as Scroll).position * (-difference);
	}

	override public function destroy():void
	{
		removeChildren(true, true);
		Model.instance.removeEventListener(Controller.ON_GOT_MAILBOX, onMailBox);
		bg = null;
		messagesBG = null;
		messagesDistribution = null;
		_bottomPanelMask = null;
		super.destroy();
	}
}
}
