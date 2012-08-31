package com.exponentum.apps.flirt.model
{
import com.exponentum.apps.flirt.model.profile.User;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filters.ColorMatrixFilter;
import flash.utils.Dictionary;

public class Model extends EventDispatcher
{
	public var owner:User = new User();

	public static var userCache:Dictionary = new Dictionary();

	public function Model()
	{
	}

	public function basicUserInfoCollected():void
	{
		dispatchEvent(new Event(User.GOT_BASIC_USER_INFO));
	}

	public function userInfoUpdated():void
	{
		dispatchEvent(new Event(User.USER_INFO_UPDATED));
	}

	//greyscale
	public static function get grayscale():ColorMatrixFilter
	{
		var matrix:Array= new Array();

		matrix = matrix.concat([1, 1, 1, 0, 0]); // red
		matrix = matrix.concat([1, 1, 1, 0, 0]); // green
		matrix = matrix.concat([1, 1, 1, 0, 0]); // blue
		matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha

		return new ColorMatrixFilter(matrix);
	}


}
}