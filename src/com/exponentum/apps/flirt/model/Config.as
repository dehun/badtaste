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
	public static var DEV_MODE:Boolean = true;

	public static var RESOURCES_SERVER:String = "";

	//----------------------------------------------
	// View states constants
	//----------------------------------------------
	public static const GAMEFIELD:String = "gamefieldState";
	public static const PROFILE:String = "profile";
	public static const TASKS:String = "tasks";
	public static const RATINGS:String = "ratings";
}
}
