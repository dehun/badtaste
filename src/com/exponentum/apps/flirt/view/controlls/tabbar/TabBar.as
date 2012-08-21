/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/4/12
 * Time: 1:28 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.controlls.tabbar
{
import flash.events.Event;
import flash.utils.Dictionary;

import org.casalib.display.CasaSprite;
import org.casalib.layout.Distribution;
import org.osmf.events.FacetValueChangeEvent;

public class TabBar extends CasaSprite
{
	private var tabsDistribution:Distribution = new Distribution();
	private var tabs:Dictionary = new Dictionary();
	private var doNotToggle:Boolean = false;

	public function TabBar()
	{
		addChild(tabsDistribution);
	}

	public function addTab(tab:TabButton, label:String, id:String, width:int = 0, doNotToggle:Boolean = false):void
	{
		tabsDistribution.addChildWithDimensions(tab, width);
		tabsDistribution.position();
		tabs[id] = tab;
		if(label != "") tab.label = label;
		tab.toggle = !doNotToggle;
		tab.addEventListener(TabButton.TAB_SELECTED, onTabSelected);
	}

	private function onTabSelected(e:Event):void
	{
		for (var id:String in tabs)
		{
			if(tabs[id] == e.currentTarget){
				dispatchEvent(new Event(id));
				if(!e.currentTarget.toggle) (tabs[id] as TabButton).deselect();
			}else{
				(tabs[id] as TabButton).deselect();
			}
		}

	}
}
}
