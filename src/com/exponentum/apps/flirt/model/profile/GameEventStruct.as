/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 8/14/12
 * Time: 9:42 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.model.profile
{
import flash.display.Sprite;

public class GameEventStruct
{
	private var _type:String = "";
	private var eventIco:Sprite;
	private var text:String;

	public function GameEventStruct()
	{
	}

	public function get type():String
	{
		return _type;
	}

	public function set type(value:String):void
	{
		_type = value;
	}
}
}
