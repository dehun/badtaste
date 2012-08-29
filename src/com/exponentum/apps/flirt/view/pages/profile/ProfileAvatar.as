/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/2/12
 * Time: 11:16 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile
{
import flash.display.Bitmap;
import flash.display.SimpleButton;
import flash.events.MouseEvent;

import org.casalib.display.CasaSprite;

public class ProfileAvatar extends CasaSprite
{
	private var avatarHolder:ProfileAvatarHolder = new ProfileAvatarHolder();
	private var _frame:int = 1;
	private var _sex:int = 1;
	private var _photo:Bitmap;
	private var _isVIP:Boolean;

	public function ProfileAvatar()
	{
		addChild(avatarHolder);


	}

	public function showMarkBlock(mark:Number, canVote:Boolean = false):void
	{

		avatarHolder.averageMarkBlock.visible = !canVote;
		avatarHolder.markButtonsBlock.visible = canVote;

		const numMarks:uint = 6;

		if(canVote)
			for (var i:int = 1; i <= numMarks; i++)
				(avatarHolder.markButtonsBlock["mark" + i] as SimpleButton).addEventListener(MouseEvent.CLICK, onMarkClick);
		else
			avatarHolder.averageMarkBlock.markText.text = mark.toString();
	}

	private function onMarkClick(e:MouseEvent):void
	{
		trace(" == >", e.currentTarget.name.split("mark")[1]);
	}

	public function set frame(value:int):void
	{
		avatarHolder.backFrame.gotoAndStop(value);
		_frame = value;
	}

	public function set sex(value:int):void
	{
		avatarHolder.sex.gotoAndStop(value);
		_sex = value;
	}

	public function set photo(value:Bitmap):void
	{
		_photo = value;
		while(avatarHolder.avatarContainer.numChildren) avatarHolder.avatarContainer.removeChildAt(0);
		avatarHolder.avatarContainer.addChild(_photo);
		avatarHolder.sex.visible = false;
	}

	public function set isVIP(value:Boolean):void
	{
		_isVIP = value;
		avatarHolder.crown.visible = _isVIP;
	}
}
}
