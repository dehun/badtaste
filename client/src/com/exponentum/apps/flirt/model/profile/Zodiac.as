/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 7/18/12
 * Time: 11:17 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.model.profile
{
public class Zodiac
{
	public static const ARIES:String = "aries";
	public static const LEO:String = "leo";
	public static const SAGITTARIUS:String = "sagittarius";
	public static const TAURUS:String = "taurus";
	public static const VIRGO:String = "virgo";
	public static const CAPRICORN:String = "capricorn";
	public static const GEMINI:String = "gemini";
	public static const LIBRA:String = "libra";
	public static const AQUARIUS:String = "aquarius";
	public static const CANCER:String = "cancer";
	public static const SCORPIO:String = "scorpio";
	public static const PISCES:String = "pisces";


	public function Zodiac()
	{
	}

	public static function getByDate(strDate:String):String
	{
		var date:int = strDate.split(".")[0];
		var month:int = strDate.split(".")[1];

		if (month == 1 && date >=20 || month == 2 && date <=18) return AQUARIUS;
		if (month == 2 && date >=19 || month == 3 && date <=20) return PISCES;
		if (month == 3 && date >=21 || month == 4 && date <=19) return ARIES;
		if (month == 4 && date >=20 || month == 5 && date <=20) return TAURUS;
		if (month == 5 && date >=21 || month == 6 && date <=21) return GEMINI;
		if (month == 6 && date >=22 || month == 7 && date <=22) return CANCER;
		if (month == 7 && date >=23 || month == 8 && date <=22) return LEO;
		if (month == 8 && date >=23 || month == 9 && date <=22) return VIRGO;
		if (month == 9 && date >=23 || month == 10 && date <=22) return LIBRA;
		if (month == 10 && date >=23 || month == 11 && date <=21) return SCORPIO;
		if (month == 11 && date >=22 || month == 12 && date <=21) return SAGITTARIUS;
		if (month == 12 && date >=22 || month == 1 && date <=19) return CAPRICORN;

		return null;
	}
}
}
