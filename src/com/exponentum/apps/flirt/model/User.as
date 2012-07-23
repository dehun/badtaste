/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 7/18/12
 * Time: 11:06 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.model
{
public class User
{
	private var guid:String = "";
	private var name:String = "";
	private var city:String = "";
	private var photoLink:String = "";
	private var profileLink:String = "";
	private var birthDate:int = 0;
	private var age:int = 0;
	private var zodiac:String = 0;
	private var sex:int = 0; //Sex.MALE || Sex.Female
	private var isOnline:Boolean = false; //Sex.MALE || Sex.Female

	private var coins:int = 0;
	private var kisses:int = 0;
	private var averageMark:Number = 0;
	private var sympathies:Array = [];
	private var likes:Array = [];
	private var liked:Array = [];

	public function User()
	{
	}
}
}
