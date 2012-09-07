/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/4/12
 * Time: 8:52 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.controlls.tabbar.TabBar;
import com.exponentum.apps.flirt.view.controlls.tabbar.TabButton;
import com.exponentum.apps.flirt.view.pages.profile.friends.FriendsList;
import com.exponentum.apps.flirt.view.pages.profile.messages.MessagesList;
import com.exponentum.apps.flirt.view.pages.profile.news.NewsList;

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
	private var messageList:MessagesList = new MessagesList();
	private var newsList:NewsList = new NewsList();

	private var _state:String = "";

	public function BottomPanel()
	{
		tabBar.x = 49;
		addChild(tabBar);
		tabBar.addTab(new TabButton(new ProfileTabButton()), "Топ 100", SOCIAL, 130, true);
		tabBar.addTab(new TabButton(new ProfileTabButton()), "Друзья", FRIENDS, 130);
		tabBar.addTab(new TabButton(new ProfileTabButton()), "Сообщения", MESSAGES, 130);
		tabBar.addTab(new TabButton(new ProfileTabButton()), "Новости", NEWS, 130);
		tabBar.addTab(new TabButton(new ProfileTabButton()), "Добавить", ADD_FRIEND, 130, true);

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
	}

	private function onNewsTabSelected(e:Event):void
	{
		trace(NEWS);
		_state = NEWS;
		clearContainer();
		container.addChild(newsList);
	}

	private function onSocialTabSelected(e:Event):void
	{
		trace(SOCIAL);
		_state = SOCIAL;
	}

	private function onFriendsTabSelected(e:Event):void
	{
		trace(FRIENDS);
		_state = FRIENDS;
		clearContainer();
		container.addChild(friendsList);
	}

	private function onMessagesTabSelected(e:Event):void
	{
		trace(MESSAGES);
		_state = MESSAGES;
		clearContainer();
		container.addChild(messageList);
	}

	public function get state():String
	{
		return _state;
	}
}
}
