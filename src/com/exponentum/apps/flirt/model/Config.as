/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 7/16/12
 * Time: 11:01 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.model
{
import org.osmf.events.FacetValueChangeEvent;

public class Config
{
	public static const DEV_MODE:Boolean = false;

	public static const TESTER:int = 0;


	public static const RESOURCES_SERVER:String = "";

	public static const JOBS_CONFIG_URL:String = "http://46.165.193.39/kissbang/cfg2/jobs.txt";
	public static var jobsData:Object = {};

	public static const GIFT_SHOP_CONFIG_URL:String = "http://46.165.193.39/kissbang/cfg2/gifts.txt";
	public static var giftShopData:Object = {};

	public static const DECOR_SHOP_CONFIG_URL:String = "http://46.165.193.39/kissbang/cfg2/decore.txt";
	public static var decorShopData:Object = {};
	//----------------------------------------------
	// View states constants
	//----------------------------------------------
	public static const GAMEFIELD:String = "gamefieldState";
	public static const PROFILE:String = "profile";
	public static const TASKS:String = "tasks";
	public static const RATINGS:String = "ratings";
}
}

