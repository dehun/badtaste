/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/25/12
 * Time: 10:59 AM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.ratings
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.view.controlls.scroll.Scroll;
import com.exponentum.apps.flirt.view.controlls.tabbar.TabBar;
import com.exponentum.apps.flirt.view.controlls.tabbar.TabButton;
import com.exponentum.apps.flirt.view.pages.BackGroundedPage;
import com.exponentum.utils.centerX;
import com.exponentum.utils.centerY;

import flash.events.Event;
import flash.events.MouseEvent;

import org.casalib.display.CasaSprite;
import org.casalib.layout.Distribution;

public class RatingsPage extends BackGroundedPage
{

	private static const sortCriterias:Array = [
		{name:"Общий", type:"common", buttonWidth:71},
		{name:"Поцелуи", type:"kisses", buttonWidth:82},
		{name:"Симпатии", type:"sympathy", buttonWidth:92},
		{name:"Подарки", type:"received_gifts", buttonWidth:80},
		{name:"Дарители", type:"sended_gifts", buttonWidth:88},
		{name:"Друзья", type:"followers", buttonWidth:73},
		{name:"Оценки", type:"rated", buttonWidth:73},
		{name:"Популярность", type:"popularity", buttonWidth:150}
	];//sended_gifts, received_gifts, sympathy, rated, rater, vippoints

	private const DAY:String = "day";
	private const WEEK:String = "week";
	private const MONTH:String = "month";
	private const TOP_VIP:String = "common_vip";

	private const MAX_ITEMS_PER_SCREEN:int = 14;

	//..................................................................................................................

	private var ratingsHeader:RatingsHeader = new RatingsHeader();
	private var timeTabBar:TabBar = new TabBar();
	private var criteriaTabBarContainer:RatingsSortTabBar = new RatingsSortTabBar();
	private var criteriaTabBar:TabBar = new TabBar();
	private var _ratingsBg:RatingsBg = new RatingsBg();
	private var backButton:BackButton = new BackButton();

	private var _fromLocation:String = "";

	private var playersDistribution:Distribution = new Distribution(500, true);
	private var ratingItems:Vector.<RatingsItem> = new Vector.<RatingsItem>();
	private var currentList:Array = [];
	private var scroll:Scroll;

	private var currentTimeInterval:String = MONTH;
	private var currentTag:String = "sympathy";

	public function RatingsPage()
	{
		setBackground(1);
		createHeader();
		createTimeTabBar();
		createWindow();
		createCriteriaTabBar();
		createBackButton();
		createPlayersDistribution();
		createScroll();

		Model.instance.addEventListener(Controller.ON_GOT_SCORES, onScores);

		Controller.instance.getScores("kisses", "month");
	}

	private function onScores(e:ObjectEvent):void
	{
		currentList = (e.data.scorelist as Array);
		for each (var ri:RatingsItem in ratingItems)
			ri.visible = false;

		for (var i:int = 0; i < Math.min(MAX_ITEMS_PER_SCREEN, currentList.length); i++)
		{
			ratingItems[i].visible = true;
			ratingItems[i].reload(currentList[i].UserScore.userGuid, i + 1);
		}

		scroll.visible = currentList.length > MAX_ITEMS_PER_SCREEN;
	}

	private function createBackButton():void
	{
		backButton.y = _ratingsBg.y + _ratingsBg.height - 5;
		centerX(backButton, 760);
		addChild(backButton);
		backButton.addEventListener(MouseEvent.CLICK, onBack);
	}

	private function createHeader():void
	{
		ratingsHeader.y = 45;
		centerX(ratingsHeader, 760);
		addChild(ratingsHeader);
	}

	private function createCriteriaTabBar():void
	{
		criteriaTabBarContainer.y = _ratingsBg.y + 5;
		centerX(criteriaTabBarContainer, 760);
		criteriaTabBarContainer.x -= 5;
		addChild(criteriaTabBarContainer);
		var xSumm:int = 0;
		criteriaTabBarContainer.butonsContainer.addChild(criteriaTabBar);
		for each (var o:Object in sortCriterias)
		{
			criteriaTabBar.addTab(new TabButton(new SortTabButton()), o.name, o.type, o.buttonWidth, false);
			criteriaTabBar.addEventListener(o.type, onTabChange);
			xSumm += o.buttonWidth;
			var edge:Edge = new Edge();
			edge.x = xSumm;
			criteriaTabBar.addChild(edge);
		}
		
	}

	private function createTimeTabBar():void
	{
		timeTabBar.y = 118;
		addChild(timeTabBar);
		timeTabBar.addTab(new TabButton(new RatingsTimeTab()), "День", DAY, 130);
		timeTabBar.addTab(new TabButton(new RatingsTimeTab()), "Неделя", WEEK, 130);
		timeTabBar.addTab(new TabButton(new RatingsTimeTab()), "Месяц", MONTH, 180);
		timeTabBar.addTab(new TabButton(new RatingsTimeTab()), "Top VIP", TOP_VIP, 130);

		centerX(timeTabBar, 760);

		timeTabBar.addEventListener(DAY, onPeriodChanged);
		timeTabBar.addEventListener(WEEK, onPeriodChanged);
		timeTabBar.addEventListener(MONTH, onPeriodChanged);
		timeTabBar.addEventListener(TOP_VIP, onPeriodChanged);
	}

	private function createWindow():void
	{
		centerX(_ratingsBg, 760);
		_ratingsBg.y = 155;
		addChild(_ratingsBg);
	}

	private function createPlayersDistribution():void
	{
		playersDistribution.x = 40;
		playersDistribution.y = 230;
		addChild(playersDistribution);

		for (var i:int = 0; i < Math.min(MAX_ITEMS_PER_SCREEN); i++)
		{
			var ratingItem:RatingsItem = new RatingsItem();
			ratingItems.push(ratingItem);
			playersDistribution.addChildWithDimensions(ratingItem, ratingItem.width + 3, ratingItem.height + 2);
		}

		playersDistribution.position();
	}

	private function createScroll():void
	{
		scroll = new Scroll(300);
		scroll.x = 705;
		scroll.y = 280;
		addChild(scroll);
		scroll.addEventListener(Event.CHANGE, onScroll);
	}

	private var currStartIndex:int = 0;
	private function onScroll(e:Event):void
	{
		var difference:int = currentList.length - MAX_ITEMS_PER_SCREEN;
		var startIndex:int = int(difference * scroll.position);
		if(startIndex == currStartIndex) return;
		currStartIndex = startIndex;
		for (var i:int = 0; i < MAX_ITEMS_PER_SCREEN; i++)
		{
			ratingItems[i].reload(currentList[i + startIndex].UserScore.userGuid, i + startIndex + 1);
		}
	}

	//----------------------------------------------------------

	private function onBack(e:MouseEvent):void
	{
		dispatchEvent(new Event(fromLocation));
	}

	private function onTabChange(e:Event):void
	{
		currentTag = e.type;
		Controller.instance.getScores(currentTag, currentTimeInterval);
	}

	private function onPeriodChanged(e:Event):void
	{
		currentTimeInterval = e.type;
		Controller.instance.getScores(currentTag, currentTimeInterval);
	}

	public function get fromLocation():String
	{
		return _fromLocation;
	}

	public function set fromLocation(value:String):void
	{
		_fromLocation = value;
	}
}
}
