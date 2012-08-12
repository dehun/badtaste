package
{
import com.greensock.TweenMax;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.getDefinitionByName;

import org.osmf.events.FacetValueChangeEvent;

/**
 * ...
 * @author @author Alexandr Glagoliev <alex.glagoliev@gmail.com>
 */
public class Preloader extends MovieClip
{
	private var bg:Background = new Background();
	private var logo:Logo = new Logo();
	private var pbBackground:ProgressbarBg = new ProgressbarBg();
	private var pbBar:preloaderBar = new preloaderBar();
	private var pbMask:PreloaderMask = new PreloaderMask();
	private var preloaderText:PreloaderText = new PreloaderText();
	private var notationText:NotationText = new NotationText();

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
		addChild(bg);
		
		logo.x = 175;
		logo.y = 200;
		logo.alpha = 0;
		addChild(logo);

		pbBackground.x = 225;
		pbBackground.y = 525;
		addChild(pbBackground);

		pbBar.x = 229;
		pbBar.y = 529;
		addChild(pbBar);
		
		pbMask.x = pbBar.x;
		pbMask.y = pbBar.y;
		pbMask.width = 5;
		addChild(pbMask);
		pbBar.mask = pbMask;

		
		preloaderText.x = pbBar.x;
		preloaderText.y = pbBar.y;
		addChild(preloaderText);
		preloaderText.preloaderText.text = "Loading: 0%";

		notationText.x = 228;
		notationText.y = 690;
		addChild(notationText);

		TweenMax.to(logo, 2, {alpha:1});
	}

	private function ioError(e:IOErrorEvent):void
	{
		trace(e.text);
	}

	private function progress(e:ProgressEvent):void
	{
		preloaderText.preloaderText.text = "Loading: " + int(e.bytesLoaded / e.bytesTotal) * 100 + "%";
		pbMask.width = e.bytesLoaded / e.bytesTotal * pbBar.width;
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
		bg.visible = false;
		logo.visible = false;
		pbBackground.visible = false;
		pbBar.visible = false;
		pbMask.visible = false;
		preloaderText.visible = false;
		notationText.visible = false;
		
		removeEventListener(Event.ENTER_FRAME, checkFrame);
		loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
		loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
		var mainClass:Class = getDefinitionByName("Kiss") as Class;
		addChild(new mainClass() as DisplayObject);
	}
}
}