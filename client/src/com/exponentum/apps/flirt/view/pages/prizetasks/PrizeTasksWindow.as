/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/24/12
 * Time: 8:35 AM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages.prizetasks
{
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;

import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;

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
		this.filters = [new DropShadowFilter(0, 45, 0x0, 1, 30, 30, 1, 3)];
	}

	private function createTasks():void
	{
		var tasks:Object = Config.jobsData;
		tasksDistr.x = 3;
		tasksDistr.y = 3;
		asset.taskContainer.addChild(tasksDistr);
		for (var i:int = 0; i < (tasks.jobs as Array).length; i++)
		{
			var completed:Boolean = false;
			for (var j:int = 0; j < Model.instance.owner.jobsCompleted.length; j++)
			{
				var completedJob:Object = Model.instance.owner.jobsCompleted[j];
				if(completedJob.jobGuid == tasks.jobs[i].guid && completedJob.areCompleted == "true") {
					completed = true;
					break;
				}
			}
			var taskButton:TaskButton = new TaskButton();
			taskButton.label.text = (i + 1).toString();
			taskButton.label.mouseEnabled = false;
			if(!completed){
				taskButton.addEventListener(MouseEvent.CLICK, onTaskButtonClick);
				taskButton.addEventListener(MouseEvent.MOUSE_OVER, onTaskButtonOver);
				taskButton.addEventListener(MouseEvent.MOUSE_OUT, onTaskButtonOut);
			}else
			{
				taskButton.alpha = .3;
			}
			tasksDistr.addChildWithDimensions(taskButton, taskButton.width + 3);
		}
		tasksDistr.position();
	}

	private function onTaskButtonClick(e:MouseEvent):void
	{

	}

	private function onTaskButtonOver(e:MouseEvent):void
	{
		var taskNum:int = int(e.currentTarget.label.text) - 1;
		if(!Config.jobsData.jobs[taskNum]) return;
		taskDetails.x = e.currentTarget.x + 30;
		taskDetails.y = 165;
		taskDetails.visible = true;
		taskDetails.mouseEnabled = taskDetails.mouseChildren = false;
		taskDetails.taskSummary.text = Config.jobsData.jobs[taskNum].title;
		taskDetails.taskDetail.text = Config.jobsData.jobs[taskNum].description;
		taskDetails.taskDetail.multiline = taskDetails.taskDetail.wordWrap = true;
		taskDetails.reward.text = Config.jobsData.jobs[taskNum].guid;
		if(int(e.currentTarget.label.text) == 11)taskDetails.x = e.currentTarget.x + 10;
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
		destroy();
	}

	override public function destroy():void
	{
		removeChildren(true, true);
		asset = null;
		taskDetails = null;
		tasksDistr = null;
		super.destroy();
	}

}
}
