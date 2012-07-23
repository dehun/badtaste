package com.exponentum.apps.flirt.view
{
import com.exponentum.apps.flirt.controller.Controller;
import com.exponentum.apps.flirt.controller.net.ServerConnector;
import com.exponentum.apps.flirt.model.Model;

import flash.display.Sprite;
import flash.events.MouseEvent;

public class View extends Sprite
{
	private var model:Model;
	private var controller:Controller;

	public function View(aModel:Model, aController:Controller)
	{
		model = aModel;
		controller = aController;
	}
}
}