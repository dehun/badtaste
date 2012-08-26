/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/24/12
 * Time: 8:35 AM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.prizetasks
{
import flash.events.MouseEvent;

import org.casalib.display.CasaSprite;
import org.casalib.layout.Distribution;

public class PrizeTasksWindow extends CasaSprite
{
	private var asset:PrizeTasksAsset = new PrizeTasksAsset();
	private var tasksDistr:Distribution = new Distribution();

	private var taskDetails:TaskDetailsAsset = new TaskDetailsAsset();

	public function PrizeTasksWindow()
	{
		createView();
		createTasks();
	}

	private function createTasks():void
	{
		tasksDistr.x = 5;
		tasksDistr.y = 3;
		asset.taskContainer.addChild(tasksDistr);
		for (var i:int = 0; i < 10; i++)
		{
			var taskButton:TaskButton = new TaskButton();
			taskButton.label.text = (i + 1).toString();
			taskButton.label.mouseEnabled = false;
			taskButton.addEventListener(MouseEvent.CLICK, onTaskButtonClick);
			taskButton.addEventListener(MouseEvent.MOUSE_OVER, onTaskButtonOver);
			taskButton.addEventListener(MouseEvent.MOUSE_OUT, onTaskButtonOut);
			tasksDistr.addChildWithDimensions(taskButton, taskButton.width + 3);
		}
		tasksDistr.position();
	}

	private function onTaskButtonClick(e:MouseEvent):void
	{

	}

	private function onTaskButtonOver(e:MouseEvent):void
	{
		taskDetails.x = e.currentTarget.x + 30;
		taskDetails.y = 165;
		taskDetails.visible = true;
	}

	private function onTaskButtonOut(e:MouseEvent):void
	{
		taskDetails.visible = false;
	}

	private function createView():void
	{
		addChild(asset);

		asset.closeButton.addEventListener(MouseEvent.CLICK, onClose);
		asset.addChild(taskDetails);
		taskDetails.visible = false;
	}

	private function onClose(e:MouseEvent):void
	{
		trace("soClose!");
	}
}
}
