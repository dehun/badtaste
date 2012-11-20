/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 10/11/12
 * Time: 10:57 AM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.ratings
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.controlls.Align;
import com.exponentum.apps.flirt.view.controlls.preloader.BlockerPreloader;

import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.net.URLRequest;

import org.casalib.display.CasaSprite;

public class RatingsItem extends CasaSprite
{
	private var asset:ratingItemAsset = new ratingItemAsset();
	
	private var _guid:String = "";
	private var _place:int = 0;
	
	public function RatingsItem()
	{
		addChild(asset);
		asset.playerName.text = "...";
		asset.kisses.text = "0";
		asset.place.text = "";
	}

	public function reload(guid:String, place:int):void
	{
		_guid = guid;
		_place = place;
		while((asset.avatar.avatarHolder as Sprite).numChildren)
		{
			(asset.avatar.avatarHolder as Sprite).removeChildAt(0);
		}
		Model.instance.addEventListener(Controller.GOT_USER_INFO, onUserInfo);
		Controller.instance.getUserInfo(_guid);
	}


	private function onUserInfo(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(user.guid != _guid) return;

		Model.instance.removeEventListener(Controller.GOT_USER_INFO, onUserInfo);
		asset.playerName.text = user.name;
		var i = 0;
		while (asset.playerName.textWidth > 155) {
			asset.playerName.text = user.name.substr(0, asset.playerName.text.length - i) + "...";
			i++;
		}
		asset.kisses.text = user.kisses.toString();
		asset.place.text = _place.toString();

		var req:URLRequest = new URLRequest(user.photoLinkSmall);
		var loader:Loader = new Loader();
		var holder:Sprite = asset.avatar.avatarHolder;
		var bp:BlockerPreloader = new BlockerPreloader(holder, 50, 50, 0);
		bp.preload(1);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void{
			//Align.center(loader, holder);
			holder.addChild(loader);
			bp.partsLoaded++;
		});
		loader.load(req);

	}

}
}


