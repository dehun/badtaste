package com.exponentum.utils
{
	/**
	 * ...
	 * @author @author Alexandr Glagoliev <alex.glagoliev@gmail.com>
	 */
	public function centerX(target:*, coordinateSpaceWidth:int):void 
	{
		target.x = (coordinateSpaceWidth - target.width) / 2;
	}
}