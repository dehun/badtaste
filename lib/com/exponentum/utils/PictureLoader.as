package com.exponentum.utils {
	import com.core.ImageTransformer;
	import com.exponentum.gui.assets.RoundedPreloader;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	public class PictureLoader extends Sprite {
		private var _preloader : RoundedPreloader = new RoundedPreloader();
		private var _loader : Loader = new Loader();
		private var _image : Sprite = new Sprite();

		private var _w : int;
		private var _h : int;

		private var _bitmap : Bitmap;
		private var _source : String = '';
		private var _constrain:Boolean = true;

		public static const LOAD_COMPLETE : String = 'load_complete';

		public function PictureLoader(w : int, h : int, constrain:Boolean = true) {
			_w = w;
			_h = h;
			_constrain = constrain;
			createPreloader();
		}

		private function createPreloader() : void {
			_preloader = new RoundedPreloader();
			_preloader.x = 280;
			_preloader.y = 350;
			_preloader.color = 0xFFFFFF;
			//addChild(_preloader);
			
//			_preloader.segmentLength = 40;
//			_preloader.segmentsCount = 20;
//			_preloader.speed = 200;
//			_preloader.minRadius = 20;
		}

		public function load(link : String) : void {
			_source = link;
			if(contains(_image)) {
				removeChild(_image);
				_image = new Sprite();
			}
			
			showPreloader();
			
			_loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			try {
                _loader.load(new URLRequest(link), new LoaderContext(true));
            }catch(e:SecurityError) {
                trace(e);
                return;
            }
			
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
            trace("ioErrorHandler: " + event);
        }

		public function unload() : void {
			_loader.unload();
		}

		private function showPreloader() : void {
			_preloader.x = (_w ) / 2;
			_preloader.y = (_h ) / 2;
			
			addChild(_preloader);
			_preloader.play();
		}

		private function hidePreloader() : void {
			if(this.contains(_preloader)) {
				removeChild(_preloader);
			} else {
				trace('ERROR: [PictureLoader] : no preloader!');
			}
		}

		private function onLoadComplete(e : Event) : void {
			hidePreloader();
			if(_constrain) {
				var bmp : Bitmap = ImageTransformer.resize(_loader.content as Bitmap, _w, _h);
			}else{
				(_loader.content as Bitmap).width = _w;
				(_loader.content as Bitmap).height = _h;
				bmp = (_loader.content as Bitmap);
			}
			_bitmap = bmp;
			_image.addChild(bmp);
			_image.width = _w;
			_image.height = _h;
			_image.x = (_w - _image.width) / 2;
			_image.y = (_h - _image.height) / 2;
			
			
			addChild(_image);
			dispatchEvent(new Event(LOAD_COMPLETE));
		}

		public function get w() : int {
			return _image.width;
		}

		public function get h() : int {
			return _image.height;
		}

		public function get imageX() : int {
			return _image.x;
		}

		public function get imageY() : int {
			return _image.y;
		}

		public function get bmp() : Bitmap {
			return _bitmap;
		}
		
		public function set bmp(bmp:Bitmap) : void {
			_bitmap = bmp;
		}

		public function get source() : String {
			return _source;
		}
	}
}