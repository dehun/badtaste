package ru.evast.integration.core 
{
	/**
	 * ...
	 * @author Pavlov Andrey; mail: obsidium@yandex.ru skype: ctrl_break
	 */
	public class SocialDefaults 
	{
		
		public function SocialDefaults() 
		{
			
		}
		
		public static const DefaultPickSmall:String = "http://cdn2.appsmail.ru/hosting/485879/no-image-36.jpg";
		public static const DefaultPickMedium:String  = "http://cdn0.appsmail.ru/hosting/485879/no-image-75.jpg";
		public static const DefaultPickBig:String = "http://cdn8.appsmail.ru/hosting/485879/no-image-128.jpg";
		
		public static function GetDefaultProfileRu(uid:String = ""):SocialProfileVO {
			var vo:SocialProfileVO = new SocialProfileVO();
			vo.FirstName = "Неизвестно";
			vo.LastName = "Неизвестно";
			vo.isMan = true;
			vo.PicBig = DefaultPickBig;
			vo.PicMedium = DefaultPickMedium;
			vo.PicSmall = DefaultPickSmall;
			vo.Uid = uid;
			vo.UrlProfile = "";
			return vo;
		}
		
		public static function GetDefaultProfileEng(uid:String = ""):SocialProfileVO {
			var vo:SocialProfileVO = new SocialProfileVO();
			vo.FirstName = "Unknow";
			vo.LastName = "Unknow";
			vo.isMan = true;
			vo.PicBig = DefaultPickBig;
			vo.PicMedium = DefaultPickMedium;
			vo.PicSmall = DefaultPickSmall;
			vo.Uid = uid;
			vo.UrlProfile = "";
			return vo;
		}
	}

}