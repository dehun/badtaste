/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/4/12
 * Time: 8:52 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile
{
import com.exponentum.apps.flirt.view.controlls.tabbar.TabBar;
import com.exponentum.apps.flirt.view.controlls.tabbar.TabButton;

import flash.events.Event;

import org.casalib.display.CasaSprite;

public class BottomPanel extends CasaSprite
{
	private static const SOCIAL:String = "social";
	private static const FRIENDS:String = "friends";
	private static const MESSAGES:String = "messages";
	private static const NEWS:String = "news";
	private static const ADD_FRIEND:String = "addFriend";

	private var tabBar:TabBar = new TabBar();
	private var container:CasaSprite = new CasaSprite();
	private var friendsList:FriendsList = new FriendsList();

	public function BottomPanel()
	{
		tabBar.x = 49;
		addChild(tabBar);
		tabBar.addTab(new TabButton(new ProfileTabButton()), SOCIAL, 130);
		tabBar.addTab(new TabButton(new ProfileTabButton()), FRIENDS, 130);
		tabBar.addTab(new TabButton(new ProfileTabButton()), MESSAGES, 130);
		tabBar.addTab(new TabButton(new ProfileTabButton()), NEWS, 130);
		tabBar.addTab(new TabButton(new ProfileTabButton()), ADD_FRIEND, 130);
		tabBar.addEventListener(SOCIAL, onSocialTabSelected);
		tabBar.addEventListener(FRIENDS, onFriendsTabSelected);
		tabBar.addEventListener(MESSAGES, onMessagesTabSelected);
		tabBar.addEventListener(NEWS, onNewsTabSelected);
		tabBar.addEventListener(ADD_FRIEND, onAddFriendsTabSelected);
		
		clearContainer();
		onFriendsTabSelected(null);
	}

	private function clearContainer():void
	{
		if(!contains(container))
		{
			container.x = 0;
			container.y = -16;
			addChild(container);
		}
		container.removeChildren();
	}

	private function onAddFriendsTabSelected(e:Event):void
	{
		trace(ADD_FRIEND);
		clearContainer();
	}

	private function onNewsTabSelected(e:Event):void
	{
		trace(NEWS);
		clearContainer();
	}

	private function onSocialTabSelected(e:Event):void
	{
		trace(SOCIAL);
		clearContainer();
	}

	private function onFriendsTabSelected(e:Event):void
	{
		trace(FRIENDS);
		clearContainer();
		container.mouseChildren = false;
		container.mouseEnabled = false;
		container.addChild(friendsList);
	}

	private function onMessagesTabSelected(e:Event):void
	{
		trace(MESSAGES);
		clearContainer();
	}
}
}
