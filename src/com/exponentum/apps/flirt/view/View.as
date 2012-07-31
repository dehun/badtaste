package com.exponentum.apps.flirt.view
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.controller.net.ServerConnector;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.view.pages.Profile;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

public class View extends Sprite
{
	private var model:Model;
	private var controller:Controller;
	
	//pages
	private var profile:Profile;
	
	public function View(aModel:Model, aController:Controller)
	{
		model = aModel;
		controller = aController;
		

	}

	public function showProfile():void
	{
		profile = new Profile(model.owner);
		addChild(profile);
	}
}
}