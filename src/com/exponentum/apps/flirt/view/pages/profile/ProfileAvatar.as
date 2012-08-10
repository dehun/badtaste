/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/2/12
 * Time: 11:16 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile
{
import flash.display.SimpleButton;
import flash.events.MouseEvent;

import org.casalib.display.CasaSprite;

public class ProfileAvatar extends CasaSprite
{
	private var avatarHolder:ProfileAvatarHolder = new ProfileAvatarHolder();


	public function ProfileAvatar()
	{
		addChild(avatarHolder);

		showMarkBlock();
	}

	private function showMarkBlock():void
	{
		var canVote:Boolean = true;

		avatarHolder.averageMarkBlock.visible = canVote;
		avatarHolder.markButtonsBlock.visible = !canVote;

		const numMarks:uint = 6;

		if(!canVote)
			for (var i:int = 1; i <= numMarks; i++)
				(avatarHolder.markButtonsBlock["mark" + i] as SimpleButton).addEventListener(MouseEvent.CLICK, onMarkClick);
		else
			avatarHolder.averageMarkBlock.markText.text = 5.1;
	}

	private function onMarkClick(e:MouseEvent):void
	{
		trace(" == >", e.currentTarget.name.split("mark")[1]);
	}
}
}