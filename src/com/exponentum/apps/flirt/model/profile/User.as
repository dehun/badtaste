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
	public var id:String = "";
	public var guid:String = "";
	public var name:String = "";
	public var city:String = "";
	public var photoLink:String = "";
	public var profileLink:String = "";
	private var _birthDate:String = "";
	public var zodiac:String = "";
	public var sex:int = 0; //Sex.MALE || Sex.Female
	public var isOnline:Boolean = false; //Sex.MALE || Sex.Female

	public var isLinkHidden:Boolean = false;
	public var isCityHidden:Boolean = false;
	public var isAgeHidden:Boolean = false;

	public var coins:int = 0;
	public var kisses:int = 0;
	public var userRate:Number = 0;
	public var lastRaters:Array = [];

	public var followers:Array = [];
	public var rebuyPrice:int = 0;

	private var _sympathies:Array = [];

	private var _decorations:Array = [];
	public var avatarFrame:int = 1;
	public var profileBackground:int = 1;

	private var _presents:Array = [];

	public var tasksDone:int = 4;
	public var placeInRating:int = 10;
	public var vipPoints:int = 0;

	public var directMessages:Vector.<DirectMessageStruct> = new Vector.<DirectMessageStruct>();
	public var gameEvents:Vector.<GameEventStruct> = new Vector.<GameEventStruct>();

	public static const GOT_BASIC_USER_INFO:String = "gotBasicUserInfo";
	public static const USER_INFO_UPDATED:String = "userInfoUpdated";
	public static const USER_MAILBOX_RECEIVED:String = "userMailboxReceived";

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


	// -- birthdate --
	public function set birthDate(value:String):void
	{
		_birthDate = value;
		zodiac = Zodiac.getByDate(value);
	}

	public function get birthDate():String
	{
		return _birthDate;
	}

	public function get sympathies():Array
	{
		return _sympathies;
	}

	public function set sympathies(value:Array):void
	{
		_sympathies = value;
	}

	public function get presents():Array
	{
		return _presents;
	}

	public function set presents(value:Array):void
	{
		_presents = value;
	}

	public function set decorations(value:Array):void
	{
		_decorations = value;
		avatarFrame = value[0];
		profileBackground = value[1];
	}
}
}
