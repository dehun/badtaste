/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/26/12
 * Time: 2:18 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.shop
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.view.common.DialogWindow;
import com.exponentum.apps.flirt.view.controlls.scroll.Scroll;
import com.exponentum.apps.flirt.view.controlls.tabbar.TabBar;
import com.exponentum.apps.flirt.view.controlls.tabbar.TabButton;
import com.exponentum.utils.centerX;

import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

import org.casalib.display.CasaSprite;
import org.casalib.layout.Distribution;

public class ShopPage extends CasaSprite
{
	private var shopData:Object;

	private var shopPageAsset:ShopWindowAsset = new ShopWindowAsset();
	private var tabBar:TabBar = new TabBar();

	private var distribution:Distribution = new Distribution(560, false);
	private var scroll:Scroll;

	private var isGiftShop:Boolean = true;
	private var _targetGuid:String = "";

	public function ShopPage(targetGuid:String)
	{
		_targetGuid = targetGuid;

		addChild(shopPageAsset);
		
		createTabBar();
		createScroll();
		createDistribution();

		shopPageAsset.closeButton.addEventListener(MouseEvent.CLICK, onClose);
		this.filters = [new DropShadowFilter(0, 45, 0x0, 1, 30, 30, 1, 3)];
	}

	private function createDistribution():void
	{
		shopPageAsset.container.addChild(distribution);
	}

	private function onClose(e:MouseEvent):void
	{
		this.destroy();
	}

	private function createTabBar():void
	{
		tabBar.y = 68;
		shopPageAsset.addChildAt(tabBar, shopPageAsset.getChildIndex(shopPageAsset.orangeBg) - 1);
		if(isGiftShop)
			shopData = Config.giftShopData;
		else
			shopData = Config.decorShopData;

		for each (var o:Object in shopData.groups)
		{
			var tb:RatingsTimeTab = new RatingsTimeTab();
			tb.buttonLabel.visible = false;
			tabBar.addTab(new TabButton(new RatingsTimeTab()), o.label, o.name, 130);
			tabBar.addEventListener(o.name, onTabChange);
		}
		reloadItems(shopData.groups[0].name)
		centerX(tabBar, this.width);
	}

	private function createScroll():void
	{
		scroll = new Scroll(300);
		scroll.x = 605;
		scroll.y = 140;
		addChild(scroll);
		scroll.addEventListener(Event.CHANGE, onScroll);
	}

	private function onScroll(e:Event):void
	{
		var difference:Number = distribution.height - shopPageAsset.distrMask.height;
		distribution.y = (e.currentTarget as Scroll).position * (-difference);
	}

	private function reloadItems(itemsGroup:String):void
	{
		distribution.removeChildren(true, true);
		for each (var o:Object in shopData.gifts)
		{
			if(o.group == itemsGroup){
				var shopItem:ShopItem = new ShopItem(o);
				shopItem.addEventListener(ShopItem.SHOP_ITEM_CLICK, onProductSelected)
				distribution.addChildWithDimensions(shopItem, shopItem.width + 3, shopItem.height + 3);
			}
		}
		distribution.position();
	}

	private function onProductSelected(e:ObjectEvent):void
	{
		Model.instance.view.showDialogWindow(new DialogWindow("Вы уверенны что хотите купить этот подарок за " + e.data.price + "монет?", "Внимание!", "Да", "Нет", function():void{
			//Model.instance.addEventListener(Controller.ON_VIP_POINTS_BUY_SUCCESS, onBecameVIPSuccess);
			//Model.instance.addEventListener(Controller.ON_VIP_POINTS_BUY_FAIL, onBecameVIPFail);
			Controller.instance.presentGift(_targetGuid, e.data.guid);
		}));
	}

	private function onTabChange(e:Event):void
	{
		reloadItems(e.type);
	}
	
	override public function destroy():void
	{
		removeChildren(true, true);
		super.destroy();	
	}
}
}
