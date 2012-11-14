/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 9/2/12
 * Time: 12:38 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile.friends
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.controlls.Align;
import com.exponentum.apps.flirt.view.controlls.preloader.BlockerPreloader;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.net.SharedObject;
import flash.net.URLLoader;
import flash.net.URLRequest;

import mx.utils.NameUtil;

import org.casalib.display.CasaSprite;
import org.osmf.events.LoaderEvent;
import org.osmf.metadata.IFacet;

import ru.cleptoman.net.UnsecurityDisplayLoader;
import ru.evast.integration.core.SocialProfileVO;

import spark.skins.spark.PanelSkin;

public class FriendListItem extends CasaSprite
{
	private var asset:FriendItemAsset = new FriendItemAsset();
	private var _profile:SocialProfileVO;

	public function FriendListItem(profile:SocialProfileVO)
	{
		_profile = profile;
		Model.instance.addEventListener(Controller.ON_GOT_USER_INFO_BY_SOCIAL_ID, onInfo);
		Model.instance.addEventListener(Controller.ON_GOT_USER_RATE, onRate);
		Model.instance.addEventListener(Controller.ON_GOT_VIP_POINTS, onVipPoints);
		Controller.instance.getUserInfoBySocialId(profile.Uid);
		addChild(asset);
	}

	private function onVipPoints(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(user.id != _profile.Uid) return;

		asset.vipMarker.visible = user.vipPoints > 0;
		Model.instance.removeEventListener(Controller.ON_GOT_VIP_POINTS, onVipPoints);
	}

	private function onRate(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(user.id != _profile.Uid) return;

		asset.starsText.text = user.userRate.toFixed(1);
		Model.instance.removeEventListener(Controller.ON_GOT_USER_RATE, onRate);
	}

	public static function Fill(target:DisplayObject, rect:Rectangle):void {
		var iWidth:Number = target.width;
		var iHeight:Number = target.height;

		target.scaleX = 1;
		target.scaleY = 1;

		var koeff:Number = 1;

		if (iWidth == iHeight) {
			if (iWidth != rect.width) koeff = rect.width / iWidth;
			target.scaleX = target.scaleY = koeff;
			target.x = 0 - (target.width - target.height) / 2;
		}
		else if (iWidth < iHeight) {
			if (iWidth != rect.width) koeff = rect.width / iWidth;
			target.scaleX = target.scaleY = koeff;
			target.y = 0 - (target.height - target.width) / 2;
		}
		else if (iWidth > iHeight) {
			if (iHeight != rect.height) koeff = rect.height / iHeight;
			target.scaleX = target.scaleY = koeff;
			target.x = 0 - (target.width - target.height) / 2;
		}

	}

	private function onInfo(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(user.id != _profile.Uid) return;
		var req:URLRequest = new URLRequest(user.photoLinkMedium);
		var loader:Loader = new Loader();
		var bp:BlockerPreloader = new BlockerPreloader(asset.friendAvatarContainer.holder, asset.friendAvatarContainer.holder.width, asset.friendAvatarContainer.holder.height, 0);
		bp.preload(1);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void{
			var holder:Sprite = asset.friendAvatarContainer.holder;
			Align.center(loader, holder);
			holder.addChild(loader);
			//FriendListItem.Fill(loader.content, holder.getBounds(holder));
			bp.partsLoaded++;
		});
		loader.load(req);

		addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
			Model.instance.view.showMiniProfile(user);
		});

		asset.heartsText.text = user.kisses.toFixed(1);
		Model.instance.removeEventListener(Controller.ON_GOT_USER_INFO_BY_SOCIAL_ID, onInfo);
		
		Controller.instance.getVipPoints(user.guid);
		Controller.instance.getUserRate(user.guid);
	}

	override public function destroy():void
	{
		asset = null;
		removeChildren();
		Model.instance.removeEventListener(Controller.ON_GOT_USER_INFO_BY_SOCIAL_ID, onInfo);
		Model.instance.removeEventListener(Controller.ON_GOT_USER_RATE, onRate);
		Model.instance.removeEventListener(Controller.ON_GOT_VIP_POINTS, onVipPoints);
	}
}
}
