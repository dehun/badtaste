/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/6/12
 * Time: 10:30 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile
{
import com.exponentum.utils.centerX;

import org.casalib.display.CasaSprite;
import org.casalib.layout.Distribution;

public class FriendsList extends CasaSprite
{
	private const MAX_FRIENDS:int = 6;
	private var bg:FriendList = new FriendList();
	private var container:Distribution = new Distribution();

	public function FriendsList()
	{
		addChild(bg);

		container.y = 72;
		addChild(container);

		for (var i:int = 0; i < MAX_FRIENDS; i++)
		{
			container.addChildWithDimensions(new FriendItem(), 97);
			container.position();
			centerX(container, bg.width);
		}

	}
}
}
