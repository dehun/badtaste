package com.exponentum.apps.flirt.model
{
import com.exponentum.apps.flirt.model.profile.User;

import flash.filters.ColorMatrixFilter;

public class Model
{
	public var owner:User = new User();

	public function Model()
	{
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