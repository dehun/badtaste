/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/26/12
 * Time: 2:18 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.shop
{
import com.exponentum.apps.flirt.view.controlls.tabbar.TabBar;
import com.exponentum.apps.flirt.view.controlls.tabbar.TabButton;
import com.exponentum.utils.centerX;

import flash.events.Event;

import org.casalib.display.CasaSprite;

public class ShopPage extends CasaSprite
{
	private var shopPageAsset:ShopWindowAsset = new ShopWindowAsset();
	private var tabBar:TabBar = new TabBar();

	private const shopData:Array = [
		{name:"Подарки", type:"gifts"},
		{name:"Стили", type:"styles"},
		{name:"Бутылки", type:"bottles"}
	];

	public function ShopPage()
	{
		addChild(shopPageAsset);
		
		createTabBar();
	}

	private function createTabBar():void
	{
		tabBar.y = 68;
		shopPageAsset.addChildAt(tabBar, shopPageAsset.getChildIndex(shopPageAsset.orangeBg) - 1);
		for each (var o:Object in shopData)
		{
			tabBar.addTab(new TabButton(new RatingsTimeTab()), o.name, o.type, 130);
			tabBar.addEventListener(o.type, onTabChange);
		}

		centerX(tabBar, this.width);

	}

	private function onTabChange(e:Event):void
	{

	}
}
}
