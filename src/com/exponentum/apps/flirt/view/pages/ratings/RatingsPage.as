/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/25/12
 * Time: 10:59 AM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.ratings
{
import com.exponentum.apps.flirt.model.Config;
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

	private var ratingsHeader:RatingsHeader = new RatingsHeader();
	private var timeTabBar:TabBar = new TabBar();
	private var criteriaTabBarContainer:RatingsSortTabBar = new RatingsSortTabBar();
	private var criteriaTabBar:TabBar = new TabBar();
	private var background:RatingsBg = new RatingsBg();
	private var backButton:BackButton = new BackButton();

	private const DAY:String = "day";
	private const WEEK:String = "week";
	private const ALL_TIME:String = "allTime";
	private const TOP_VIP:String = "topVip";

	private var playersDistribution:Distribution = new Distribution();

	private static const sortCriterias:Array = [
		{name:"Общий", type:"common", buttonWidth:71},
		{name:"Поцелуи", type:"kiss", buttonWidth:82},
		{name:"Симпатии", type:"sympathy", buttonWidth:92},
		{name:"Подарки", type:"gift", buttonWidth:80},
		{name:"Дарители", type:"gifter", buttonWidth:88},
		{name:"Друзья", type:"friend", buttonWidth:73},
		{name:"Оценки", type:"mark", buttonWidth:73},
		{name:"Популярность", type:"popularity", buttonWidth:150}
	];
	

	public function RatingsPage()
	{
		setBackground(1);
		createHeader();
		createTimeTabBar();
		createWindow();
		createCriteriaTabBar();
		createBackButton();
	}

	private function createBackButton():void
	{
		backButton.y = background.y + background.height + 10;
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
		criteriaTabBarContainer.y = background.y + 5;
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
		timeTabBar.addTab(new TabButton(new RatingsTimeTab()), "Месяц", ALL_TIME, 180);
		timeTabBar.addTab(new TabButton(new RatingsTimeTab()), "Top VIP", TOP_VIP, 130);

		centerX(timeTabBar, 760);

		timeTabBar.addEventListener(DAY, onRateByDay);
		timeTabBar.addEventListener(WEEK, onRateByWeek);
		timeTabBar.addEventListener(ALL_TIME, onRateAllTime);
		timeTabBar.addEventListener(TOP_VIP, onTopVIP);
	}

	private function createWindow():void
	{
		centerX(background, 760);
		background.y = 155;
		addChild(background);
	}

	//----------------------------------------------------------

	private function onRateByDay(e:Event):void
	{

	}

	private function onRateByWeek(e:Event):void
	{

	}

	private function onRateAllTime(e:Event):void
	{

	}

	private function onTopVIP(e:Event):void
	{

	}

	private function onBack(e:MouseEvent):void
	{
		dispatchEvent(new Event(Config.PROFILE));
	}

	private function onTabChange(e:Event):void
	{

	}

}
}
