/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/13/12
 * Time: 7:49 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.profile.news
{
import org.casalib.display.CasaSprite;

public class NewsItem extends CasaSprite
{
	private var asset:NewsItemAsset = new NewsItemAsset();

	public function NewsItem(newsObject:Object)
	{
		addChild(asset);
		asset.textTf.text = "Вася прислал вам подарок";
	}
}
}
