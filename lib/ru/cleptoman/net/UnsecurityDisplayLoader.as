package ru.cleptoman.net {
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	[Event(name = "open", type = "flash.events.Event.OPEN")]
	[Event(name = "complete", type = "flash.events.Event.COMPLETE")]
	[Event(name = "init", type = "flash.events.Event.INIT")]
	[Event(name = "progress", type = "flash.events.ProgressEvent.PROGRESS")]
	[Event(name = "securityError", type = "flash.events.SecurityErrorEvent.SECURITY_ERROR")]
	[Event(name = "ioError", type = "flash.events.IOErrorEvent.IO_ERROR")]
	
	/**
	 * @langversion 	Action Script 3.0
	 * @see				http://cleptoman.free-lance.ru
	 * @author 			Kutov Aleksey aka cleptoman
	 * @version 		0.02
	 * @playerversion	9
	 * Класс-надстройка над Loader. Предназначен для загрузки медийного контента форматов JPEG,GIF,PNG,SWF при необходимости игнорируя политику безопасности Flash Player.
	 */
	public class UnsecurityDisplayLoader extends EventDispatcher{
		
		protected var _loader:Loader;
		protected var _parameters:Object;
		protected var _loading:Boolean;
		protected var _isAfterFirstError:Boolean;
		protected var _content:DisplayObject;
		protected var _extractor:IContentExtractor;

		public function UnsecurityDisplayLoader() {
			super();
		}
		
		private function _create():void {
			_loader						= new Loader();
			_configHandlers();
		}
		
		private function _removeHandlers():void {
			var li:LoaderInfo			= _loader.contentLoaderInfo;
			li.removeEventListener(Event.COMPLETE, _onHandler);
			li.removeEventListener(Event.INIT, _onHandler);
			li.removeEventListener(ProgressEvent.PROGRESS, _onHandler);
			li.removeEventListener(Event.OPEN, _onHandler);
			li.removeEventListener(IOErrorEvent.IO_ERROR, _onHandler);
			li.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _onHandler);
		}
		
		private function _configHandlers():void {
			var li:LoaderInfo			= _loader.contentLoaderInfo;
			li.addEventListener(Event.COMPLETE, _onHandler);
			li.addEventListener(Event.INIT, _onHandler);
			li.addEventListener(ProgressEvent.PROGRESS, _onHandler);
			li.addEventListener(Event.OPEN, _onHandler);
			li.addEventListener(IOErrorEvent.IO_ERROR, _onHandler);
			li.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onHandler);
		}
		
		private function _skipLoad():void {
			if (_loader && _loading) {
				_loader.close();
			}
			_extractor					= null;
			_content					= null;
			_isAfterFirstError			= false;
			_parameters					= null;
			_loading					= false;
		}
		
		/**
		 * Пробуем достучаться до content у LoaderInfo. если не получается, то грузим байты методом loadBytes. Пробуем еще раз. если не получается, то думаем,что делать дальше с ексепшном )
		 * @param	e
		 */
		
		private function _onHandler(e:Event):void {
			if (e.type === Event.INIT) {
				if (_isAfterFirstError) {
					_content			= _extractor.extract(_loader.content);
					_isAfterFirstError			= false;
				}else{
					try{
						_content		= _loader.content;
					}catch (err:SecurityError) {
						_extractor				= (_loader.contentLoaderInfo.contentType.substring(0,5) === "image") ? new BitmapExtractor() : new MovieClipExtractor();
						_isAfterFirstError		= true;
						_loader.loadBytes(_loader.contentLoaderInfo.bytes);
						e.stopPropagation();
						return;
					}
					_parameters		= _loader.contentLoaderInfo.parameters;
				}
				_loading					= false;
			}
			
			if (e.type === ProgressEvent.PROGRESS && _isAfterFirstError) {
				return;
			}
			super.dispatchEvent(e);
		}
		
		public override function dispatchEvent (event:Event) : Boolean {
			throw new Error("Класс не реализует данный метод");
		}
		
		/**
		 * @return Возвращает последний объект, переданный в URLReqest#data в метод load. Не равен content.loaderInfo.parameters, если загрузка прошла игнорируя безопасность.
		 */
		
		public function get parameters():Object { return _parameters; }
		
		
		/**
		 * @return Возвращает медийный контент. Если загрузка произошла игнорируя политику безопасности, то content.loaderInfo.contentType для объектов будет application/x-shockwave-flash, а не image/jpeg.
		 */
		public function get content():DisplayObject { 
			return _content; 
		}
		/**
		 * @return Возвращает состояние: происходит загрузка в данный момент или нет.
		 */
		public function get loading():Boolean { return _loading; }
		
		public function load(request:URLRequest,context:LoaderContext = null):void {
			_skipLoad();
			if (!_loader) {
				_create();
			}
			
			_parameters				= request.data;
			_loader.load(request,context);
			_loading				= true;
		}
		public function loadBytes(bytes:ByteArray):void {
			_skipLoad();
			if (!_loader) {
				_create();
			}
			_parameters				= _loader.contentLoaderInfo.parameters;
			_loader.loadBytes(bytes);
			_loading				= true;
		}
		public function unload():void {
			_skipLoad();
			if(_loader){
				_loader.unload();
			}
		}
		public function unloadAndStop(gc:Boolean = true):void {
			_skipLoad();
			if(_loader){
				_loader.unloadAndStop(gc);
			}
		}
		public function close():void {
			_skipLoad();
		}
		
		/**
		 * Удаляет внутренние ссылки на используемые объекты. сохраните ссылку на полученный в ходе загрузки content перед вызовом метода
		 */
		public function destroy():void {
			if (_loader) {
				_skipLoad();
				_removeHandlers();
				_loader				= null;
			}
		}
		
		
	}

}
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
interface IContentExtractor {
	function extract(content:DisplayObject):DisplayObject;
}
class BitmapExtractor implements IContentExtractor {
	public function extract(content:DisplayObject):DisplayObject {
		return (content as DisplayObjectContainer).getChildAt(0);
	}
}
class MovieClipExtractor implements IContentExtractor {
	public function extract(content:DisplayObject):DisplayObject {
		return content;
	}
}