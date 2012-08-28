/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 7/18/12
 * Time: 11:06 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.model.profile
{
import ru.evast.integration.IntegrationProxy;
import ru.evast.integration.core.SocialProfileVO;

public class User
{
	public var guid:String = "";
	public var id:String = "";
	public var name:String = "";
	public var city:String = "";
	public var photoLink:String = "";
	public var profileLink:String = "";
	private var _birthDate:String = "";
	public var zodiac:String = "";
	public var sex:int = 0; //Sex.MALE || Sex.Female
	public var isOnline:Boolean = false; //Sex.MALE || Sex.Female

	public var coins:int = 0;
	public var kisses:int = 0;

	public var userRate:Number = 0;
	public var lastRaters:Array = [];

	public var followers:Array = [];
	public var rebuyPrice:int = 0;
	
	public var decorations:Array = [];
	
	public var sympathies:Array = [];

	public var presents:Array = [];

	public var profileAvatarFrame:int = 1;
	public var gotGifts:int = 2;
	public var tasksDone:int = 4;
	public var placeInRating:int = 10;
	public var isVIP:Boolean = false;


	public var directMessages:Vector.<DirectMessageStruct> = new Vector.<DirectMessageStruct>();
	public var gameEvents:Vector.<GameEventStruct> = new Vector.<GameEventStruct>();

	public static const GOT_BASIC_USER_INFO:String = "gotBasicUserInfo";

	public function User()
	{

	}

	public function updateSocialInfo(data:SocialProfileVO):void
	{
		id = data.Uid;
		name = data.FirstName + " " + data.LastName;
		city = data.City;
		photoLink = data.PicBig;
		profileLink = data.UrlProfile;
		birthDate = data.BirthDate;
		sex = int(data.isMan);
	}

	public function set birthDate(value:String):void
	{
		_birthDate = value;
		zodiac = Zodiac.getByDate(value);
	}

	public function get birthDate():String
	{
		return _birthDate;
	}
}
}
