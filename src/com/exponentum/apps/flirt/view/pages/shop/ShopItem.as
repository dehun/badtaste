/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 10/11/12
 * Time: 5:47 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.shop
{
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.view.controlls.Align;
import com.exponentum.apps.flirt.view.controlls.preloader.BlockerPreloader;
import com.exponentum.utils.ToolTip;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.load.SwfLoad;

import ru.evast.integration.IntegrationProxy;

public class ShopItem extends CasaSprite
{
	private var asset:ShopItemAsset = new ShopItemAsset();
	private var load:SwfLoad;
	private var bp:BlockerPreloader;
	private var _data:Object = {};

	private var _isBankItem:Boolean = false;

	public static const SHOP_ITEM_CLICK:String = "shopItemClick";
	public static const BANK_ITEM_CLICK:String = "bankItemClick";

	public function ShopItem(data:Object, isBankItem:Boolean = false)
	{
		_data = data;
		_isBankItem = isBankItem;

		addChild(asset);
		asset.priceTf.text = data.price;

		var urlString:String;
		if(_isBankItem)
			urlString = _data.image_url;
		else
			urlString = String(data.image).replace("http://static.evast.ru/", "");

		load = new SwfLoad(urlString);
		load.addEventListener(LoadEvent.COMPLETE, onLoaded);
		load.start();
		bp = new BlockerPreloader(asset, asset.width, asset.height);
		bp.preload(1);
		
		buttonMode = useHandCursor = true;

		ToolTip.bind(this, _data.description);

		addEventListener(MouseEvent.CLICK, onClick);
	}

	private function onClick(e:MouseEvent):void
	{
		if(_isBankItem)
			dispatchEvent(new ObjectEvent(BANK_ITEM_CLICK, _data));
		else
			dispatchEvent(new ObjectEvent(SHOP_ITEM_CLICK, _data));
	}

	private function onLoaded(e:LoadEvent):void
	{
		var mc:MovieClip = load.contentAsMovieClip;

		if(mc.width > mc.height){
			mc.width = asset.width - 10;
			mc.scaleY = mc.scaleX;
		}else{
			mc.height = asset.height - 50;
			mc.scaleX = mc.scaleY;
		}
		asset.avatarContainer.addChild(mc);
		Align.center(mc, asset);

		bp.partsLoaded++;
	}
}
}
