package ru.evast.integration 
{
	import com.greensock.TweenMax;
	import flash.events.EventDispatcher;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	import ru.evast.integration.core.IDataAdapter;
	import ru.evast.integration.core.SocialNetworkTypes;
	import ru.evast.integration.core.SocialProfileVO;
	import ru.evast.integration.inner.FB.FBDataAdapter;
	import ru.evast.integration.inner.Mamba.MambaInnerAdapter;
	import ru.evast.integration.inner.MM.MMInnerAdapter;
	import ru.evast.integration.inner.NextGame.NextGameInnerAdapter;
	import ru.evast.integration.inner.OK.OKInnerAdapter;
	import ru.evast.integration.inner.VK.VKInnerAdapter;
	import ru.evast.integration.outer.GPlus.GPlusOuterAdapter;
	import ru.evast.integration.outer.MM.MMOuterAdapter;
	import ru.evast.integration.outer.OK.OKOuterAdapter;
	import ru.evast.integration.outer.VK.VKOuterAdapter;
	/**
	 * ...
	 * @author ...
	 */
	public class IntegrationProxy
	{
		private static var _adapter:IDataAdapter;
		private static var _socialNetworkType:int;
		private static var isInit:Boolean = false;
		private static var _isInternal:Boolean;
		private static var _balanceUpdateFunction:Function;
		private static var _dispatcher:EventDispatcher = new EventDispatcher();
		
		public function IntegrationProxy() {
			
		}
		
		public static function init( params:Object, localType:int, isInternal:Boolean = true ):void {
			if ( isInit ) return;
			_isInternal = isInternal;
			
			if ( localType == SocialNetworkTypes.TEST_SERVER ) {
				_socialNetworkType = SocialNetworkTypes.MY_WORLD;
				_adapter = new MMInnerAdapter();
			}
			
			//Запускаемся внутри соц сети
			if ( isInternal ) {
				//Определяем соц сеть
				if ( params["nextgame"] != undefined || localType == SocialNetworkTypes.NEXT_GAME ) {
					//NextGame
					_adapter = new NextGameInnerAdapter();
					_socialNetworkType = SocialNetworkTypes.NEXT_GAME;
				} 
				else if ( params["partner_url"] != undefined || localType == SocialNetworkTypes.MAMBA ) {
					//Мамба
					_adapter = new MambaInnerAdapter();
					_socialNetworkType = SocialNetworkTypes.MAMBA;
				} 
				else if ( params [ "app_id" ] != undefined || localType == SocialNetworkTypes.MY_WORLD) {
					// Мой мир
					_socialNetworkType = SocialNetworkTypes.MY_WORLD;
					_adapter = new MMInnerAdapter();
				}
				else if ( params [ "api_id" ] != undefined || localType == SocialNetworkTypes.VKONTAKTE ) {
				   // Контакт
				   _socialNetworkType = SocialNetworkTypes.VKONTAKTE;
				   _adapter = new VKInnerAdapter();
				}
				else if ( params [ "access_token" ] != undefined || localType == SocialNetworkTypes.FACEBOOK) {
					// face
					_socialNetworkType = SocialNetworkTypes.FACEBOOK;
					_adapter = new FBDataAdapter();
				} 
				else if ( params ["application_key"] != undefined || localType == SocialNetworkTypes.ODNOKLASSNIKI) {
					// Однокласники
					_socialNetworkType = SocialNetworkTypes.ODNOKLASSNIKI;
					_adapter = new OKInnerAdapter();
				}
			//Запускаемся на внешнем сайте
			} else {
				if ( params["socialNetwork"] == "VK" || localType == SocialNetworkTypes.VKONTAKTE ) {
					_adapter = new VKOuterAdapter();
					_socialNetworkType = SocialNetworkTypes.VKONTAKTE;
				} 
				else if ( params["socialNetwork"] == "MM" || localType == SocialNetworkTypes.MY_WORLD ) {
					_adapter = new MMOuterAdapter();
					_socialNetworkType = SocialNetworkTypes.MY_WORLD;
				}
				else if ( params["socialNetwork"] == "FB" || localType == SocialNetworkTypes.FACEBOOK ) {
					_adapter = new FBDataAdapter();
					_socialNetworkType = SocialNetworkTypes.FACEBOOK;
				}
				else if ( params["socialNetwork"] == "OK" || localType == SocialNetworkTypes.ODNOKLASSNIKI ) {
					_adapter = new OKOuterAdapter();
					_socialNetworkType = SocialNetworkTypes.ODNOKLASSNIKI;
				}
				else if ( params["socialNetwork"] == "GPlus" || localType == SocialNetworkTypes.GPLUS ) {
					_adapter = new GPlusOuterAdapter();
					_socialNetworkType = SocialNetworkTypes.GPLUS;
				}
			}
			
			_adapter.init(params, localType != SocialNetworkTypes.AUTO_DETECT);
			
			isInit = true;
		}
		
		static public function get adapter():IDataAdapter {
			return _adapter;
		}
		
		static public function get socialNetworkType():int {
			return _socialNetworkType;
		}
		
		static public function get balanceUpdateFunction():Function {
			return _balanceUpdateFunction;
		}
		static public function set balanceUpdateFunction(value:Function):void {
			_balanceUpdateFunction = value;
		}
		
		static public function get isInternal():Boolean {
			return _isInternal;
		}
		
		[Event(name="user_balance_change", type="ru.evast.integration.core.IntegrationEvent")]
		static public function get dispatcher():EventDispatcher {
			return _dispatcher;
		}
		
		private static var socialProfileList:Dictionary = new Dictionary(); //Кэшированная информация о пользователях соц. сети
		private static var queueSocialRequests:Array = new Array();
		
		public static function batchLoadProfiles(uids:String, callback:Function):void {
			//trace("callback=" + callback);
			if ( uids == "" ) return;
			var arUids:Array = uids.split(",");
			
			//Если надо запросить более сотни пользователей, например в друзьях у человека больше 100 человек
			//тогда не заморачиваемся загружаем только 100. Иначе будут проблемы с соц сетью.
			if ( arUids.length > 100 )
				arUids = arUids.slice(0, 100);
				
			var arNewUids:Array = new Array();
			var SocProf:SocialProfileVO;
			var vInfo:Vector.<SocialProfileVO> = new Vector.<SocialProfileVO>();
			
			for each ( var s:String in arUids ) {
				if ( s == "" || s == "0" ) continue;
				SocProf = socialProfileList[s] as SocialProfileVO;
				if ( SocProf != null ) {
					vInfo.push(SocProf);
				} else {
					arNewUids.push(s);
				}
			}
			
			if ( arNewUids.length == 0 ) {
				//Если работаем в дебажном флеш плеере возможные ошибки не скрываем
				if ( Capabilities.isDebugger ) {
					callback.call(null, vInfo);
				} else {
					try{
						callback.call(null, vInfo);
					}catch ( e:Error ) {
						//TODO: Написать нормальный обработчик ошибок
					}
				}
				
				return;
			}
			
			var rs:RequestStruct = new RequestStruct();
			rs.callback = callback;
			rs.vInfo = vInfo;
			rs.NewUids = arNewUids.join(",");
			
			queueSocialRequests.push( rs );
			
			if( queueSocialRequests.length == 1 ) 
				adapter.GetProfiles(rs.NewUids, onLoadProfilesComplete);
		}
		public static function cancelRequestByCallback( callback:Function ):void {
			if ( queueSocialRequests.length == 0 ) return;
			var r:RequestStruct;
			
			/*
			 * Если отменяем текущий запрос устанавливаем флаг иначе удаляем его из очереди
			 */
			
			r = queueSocialRequests[0] as RequestStruct;
			if ( r.callback == callback ) r.isCanceled = true;
			
			for ( var a:int = 1; a < queueSocialRequests.length; a++ ) {
				r = queueSocialRequests[a] as RequestStruct;
				if ( r.callback == callback ) {
					queueSocialRequests.splice(a, 1);
				}
			}
		}
		private static function onLoadProfilesComplete(ar:Array):void {
			var rs:RequestStruct = queueSocialRequests.shift() as RequestStruct;
			
			var SocProf:SocialProfileVO;
			for each( var a:SocialProfileVO in ar) {
				socialProfileList[a.Uid] = a;
			}
			
			if( rs.isCanceled == false ) {
				var arNewUids:Array = rs.NewUids.split(',');
				
				for each( var i:String in arNewUids ) {
					SocProf = socialProfileList[i];
					if ( SocProf == null && Capabilities.isDebugger == false ) 	continue; //Если пришли не все профили. В случае дебажного плеера даём ошибке произойти
					rs.vInfo.push(SocProf);
				}
				
				if ( Capabilities.isDebugger ) {
					rs.callback.call(null, rs.vInfo);
				} else {
					try{
						rs.callback.call(null, rs.vInfo);
					}catch ( e:Error ) {
						
					}
				}
				
			}
			
			if ( queueSocialRequests.length != 0 ) {
				rs = queueSocialRequests[0];
				if ( socialNetworkType == SocialNetworkTypes.VKONTAKTE ) {
					TweenMax.delayedCall(0.3, _adapter.GetProfiles, [ rs.NewUids, onLoadProfilesComplete ]);
				} else
					adapter.GetProfiles(rs.NewUids, onLoadProfilesComplete);
			}
		}
	}

}
import ru.evast.integration.core.SocialProfileVO;

internal class RequestStruct {
	public var callback:Function;
	public var vInfo:Vector.<SocialProfileVO>;
	public var NewUids:String;
	public var isCanceled:Boolean = false;
}