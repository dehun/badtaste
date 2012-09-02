package com.exponentum.apps.flirt.model
{
import com.exponentum.apps.flirt.model.profile.User;
import com.exponentum.apps.flirt.view.View;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filters.ColorMatrixFilter;
import flash.utils.Dictionary;

public class Model extends EventDispatcher
{
	private var _owner:User = new User();

	public var userCache:Dictionary = new Dictionary();
	public var view:View;
	
	private static var _instance:Model;
	public static function get instance():Model
	{
		if(!_instance)
			_instance = new Model();

		return _instance;
	}
	
	public function Model()
	{
		_instance = this;
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

	////////////////////////////////////////////////////////////////////////////////////////
	//
	////////////////////////////////////////////////////////////////////////////////////////
	private var _mail:Array = [];

	public function get mail():Array
	{
		return _mail;

	}

	public function set mail(value:Array):void
	{
		_mail = value;
		dispatchEvent(new Event(User.USER_MAILBOX_RECEIVED));
	}

	public function get owner():User
	{
		if(!userCache[_owner.guid]) userCache[_owner.guid] = _owner;
		return userCache[_owner.guid];
	}

	public function set owner(value:User):void
	{
		_owner = value;
	}
}
}