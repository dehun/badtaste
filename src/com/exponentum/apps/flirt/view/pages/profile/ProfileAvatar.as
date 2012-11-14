/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/2/12
 * Time: 11:16 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.events.ObjectEvent;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.controlls.Align;
import com.exponentum.apps.flirt.view.pages.profile.friends.FriendListItem;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;

import mx.controls.PopUpButton;

import org.casalib.display.CasaSprite;

public class ProfileAvatar extends CasaSprite
{
	private var avatarHolder:ProfileAvatarHolder = new ProfileAvatarHolder();
	private var _frame:int = 1;
	private var _sex:int = 1;
	private var _photo:Loader;
	private var _isVIP:Boolean;
	private var _user:User;

	public function ProfileAvatar()
	{
		addChild(avatarHolder);
		showMarkBlock();
		frame = 1;
		isVIP = false;
		sex = 1;
		isRated = true;
		mark = 0;
	}

	public function showMarkBlock():void
	{
		const numMarks:uint = 6;

		for (var i:int = 1; i <= numMarks; i++)
			(avatarHolder.markButtonsBlock["mark" + i] as SimpleButton).addEventListener(MouseEvent.CLICK, onMarkClick);
	}

	public function set mark(m:Number):void{
		avatarHolder.averageMarkBlock.markText.text = m.toString();
	}

	public function set isRated(b:Boolean):void{
		avatarHolder.averageMarkBlock.visible = b;
		avatarHolder.markButtonsBlock.visible = !b;
	}

	private function onMarkClick(e:MouseEvent):void
	{
		Controller.instance.rateUser(_user.guid, e.currentTarget.name.split("mark")[1].toString());
		Model.instance.addEventListener(Controller.ON_RATE_USER_SUCCESS, onRateSuccess);
		Model.instance.addEventListener(Controller.ON_RATE_USER_FAILED, onRateUserFail);
		isRated = true;
	}

	private function onRateUserFail(e:Event):void
	{
		Model.instance.removeEventListener(Controller.ON_RATE_USER_SUCCESS, onRateSuccess);
		Model.instance.removeEventListener(Controller.ON_RATE_USER_FAILED, onRateUserFail);
		isRated = false;
	}

	private function onRateSuccess(e:Event):void
	{
		Model.instance.removeEventListener(Controller.ON_RATE_USER_SUCCESS, onRateSuccess);
		Model.instance.removeEventListener(Controller.ON_RATE_USER_FAILED, onRateUserFail);
		isRated = true;
		Model.instance.addEventListener(Controller.GET_USER_RATE, onUserRate);
		Controller.instance.getUserRate(_user.guid);
	}

	private function onUserRate(e:ObjectEvent):void
	{
		Model.instance.removeEventListener(Controller.GET_USER_RATE, onUserRate);
		mark = (e.data as User).userRate;
	}

	public function set frame(value:int):void
	{
		avatarHolder.backFrame.gotoAndStop(value);
		_frame = value;
	}

	public function set sex(value:int):void
	{
		avatarHolder.sex.gotoAndStop(value + 1);
		_sex = value;
	}

	public function set photo(value:Loader):void
	{
		_photo = value;
		while(avatarHolder.avatarContainer.numChildren) avatarHolder.avatarContainer.removeChildAt(0);
		//Align.center(_photo, avatarHolder.avatarContainer)
		avatarHolder.avatarContainer.addChild(_photo);
		FriendListItem.Fill(_photo, avatarHolder.getBounds(avatarHolder));
		avatarHolder.sex.visible = false;
	}

	public function set isVIP(value:Boolean):void
	{
		_isVIP = value;
		avatarHolder.crown.visible = _isVIP;
	}

	public function set user(value:User):void
	{
		_user = value;
	}

	override public function destroy():void
	{
		Model.instance.removeEventListener(Controller.ON_RATE_USER_SUCCESS, onRateSuccess);
		Model.instance.removeEventListener(Controller.ON_RATE_USER_FAILED, onRateUserFail);
		Model.instance.removeEventListener(Controller.GET_USER_RATE, onUserRate);

		super.destroy();
	}
}
}
