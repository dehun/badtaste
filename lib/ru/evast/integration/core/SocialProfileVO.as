package ru.evast.integration.core 
{
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import ru.evast.integration.IntegrationProxy;
	/**
	 * ...
	 * @author 
	 */
	public class SocialProfileVO 
	{
		
		public function SocialProfileVO() {   }
		
		public var Uid:String;
		public var FirstName:String;
		public var LastName:String;
		public var UrlProfile:String;
		public var isMan:Boolean;
		public var PicSmall:String;
		public var PicMedium:String;
		public var PicBig:String;
		
		public function GotoUserPage():void {
			if ( IntegrationProxy.socialNetworkType != SocialNetworkTypes.NEXT_GAME ) {
				navigateToURL(new URLRequest(UrlProfile), "_blank");
			} else {
				if ( ExternalInterface.available )
					ExternalInterface.call("users.showProfile(" + Uid + ")");
			}
		}
		
	}

}