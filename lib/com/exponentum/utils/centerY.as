package com.exponentum.utils
{
	/**
	 * ...
	 * @author @author Alexandr Glagoliev <alex.glagoliev@gmail.com>
	 */
	public function centerY(target:*, coordinateSpaceHeight:int):void 
	{
		target.y = (coordinateSpaceHeight - target.height) / 2;
	}
}