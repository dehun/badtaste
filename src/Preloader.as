package
{
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.getDefinitionByName;

/**
 * ...
 * @author @author Alexandr Glagoliev <alex.glagoliev@gmail.com>
 */
public class Preloader extends MovieClip
{
	public function Preloader()
	{
		if (stage)
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
		}
		addEventListener(Event.ENTER_FRAME, checkFrame);
		loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
		loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
		showLoader();
	}

	private function showLoader():void
	{
	}

	private function ioError(e:IOErrorEvent):void
	{
		trace(e.text);
	}

	private function progress(e:ProgressEvent):void
	{
		trace("Loading " + int(e.bytesLoaded / e.bytesTotal) * 100 + "%");
	}

	private function checkFrame(e:Event):void
	{
		if (currentFrame == totalFrames)
		{
			stop();
			loadingFinished();
		}
	}

	private function loadingFinished():void
	{
		removeEventListener(Event.ENTER_FRAME, checkFrame);
		loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
		loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
		var mainClass:Class = getDefinitionByName("Kiss") as Class;
		addChild(new mainClass() as DisplayObject);
	}
}
}