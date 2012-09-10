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

import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;

import mx.utils.NameUtil;

import org.casalib.display.CasaSprite;
import org.osmf.metadata.IFacet;

import ru.cleptoman.net.UnsecurityDisplayLoader;
import ru.evast.integration.core.SocialProfileVO;

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

		asset.starsText.text = user.userRate.toString();
		Model.instance.removeEventListener(Controller.ON_GOT_USER_RATE, onRate);
	}

	private function onInfo(e:ObjectEvent):void
	{
		var user:User = e.data as User;
		if(user.id != _profile.Uid) return;
		
		var loader:UnsecurityDisplayLoader = new UnsecurityDisplayLoader();
		loader.addEventListener(Event.INIT, function(e:Event):void {
			var loader:UnsecurityDisplayLoader = e.target as UnsecurityDisplayLoader;
			var bmp:Bitmap = (new Bitmap((loader.content as Bitmap).bitmapData));
			bmp.width = asset.friendAvatarContainer.width;
			bmp.scaleY = bmp.scaleX;
			bmp.smoothing = true;
			asset.friendAvatarContainer.holder.addChild(bmp);
		});
		var req:URLRequest = new URLRequest(user.photoLink);
		loader.load(req);

		addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
			Model.instance.view.showMiniProfile(user);
		});

		asset.heartsText.text = user.kisses.toString();
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
