/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/11/12
 * Time: 4:14 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.gamefield
{
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.view.pages.BackGroundedPage;
import com.exponentum.utils.centerX;

import flash.display.MovieClip;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.load.SwfLoad;

public class GameField extends BackGroundedPage
{
	private var tableLoad:SwfLoad;
	private var tableContainer:CasaSprite = new CasaSprite();

	private var chatBG:MovieClip = new MovieClip();
	
	public function GameField()
	{
		setBackground(1);
		setTable(2);

		createView();
	}

	private function createView():void
	{
		chatBG = new BackGround();
		chatBG.x = 0;
		chatBG.y = -130;
		addChild(chatBG);


	}

	public function setTable(tableId:int):void
	{
		if(!contains(tableContainer)) addChild(tableContainer);
		tableLoad = new SwfLoad(Config.RESOURCES_SERVER + "tables/table" + tableId + ".swf");
		tableLoad.addEventListener(LoadEvent.COMPLETE, onBgLoaded);
		tableLoad.start();
	}

	private function onBgLoaded(e:LoadEvent):void
	{
		tableContainer.removeChildren(true, true);
		tableContainer.addChild(tableLoad.contentAsMovieClip);
		centerX(tableContainer, 760);
	}
}
}
