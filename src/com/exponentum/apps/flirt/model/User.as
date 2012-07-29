/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 7/18/12
 * Time: 11:06 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.model
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
	public var birthDate:String = "";
	public var age:int = 0;
	public var zodiac:String = "d";
	public var sex:int = 0; //Sex.MALE || Sex.Female
	public var isOnline:Boolean = false; //Sex.MALE || Sex.Female

	public var coins:int = 0;
	public var kisses:int = 0;
	public var averageMark:Number = 0;
	public var sympathies:Array = [];
	public var likes:Array = [];
	public var liked:Array = [];

	public function User()
	{

	}

	public function updateSocialInfo(data:SocialProfileVO):void
	{
		id = data.Uid;
		name = data.FirstName + " " + data.LastName;
		city = data.City;
		photoLink = data.PicMedium;
		profileLink = data.UrlProfile;
		birthDate = data.BirthDate;
		sex = int(data.isMan);
	}
}
}
