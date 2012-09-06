/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 9/2/12
 * Time: 12:38 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile.friends
{
import org.casalib.display.CasaSprite;

public class FriendListItem extends CasaSprite
{
	private var asset:FriendItemAsset = new FriendItemAsset();

	public function FriendListItem()
	{
		addChild(asset);

	}

	public function update(data:Object):void
	{

	}
}
}
