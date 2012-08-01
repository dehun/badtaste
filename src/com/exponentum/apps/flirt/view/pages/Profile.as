/**
 * Created by IntelliJ IDEA.
 * User: Exponentum
 * Date: 7/31/12
 * Time: 10:09 PM
 * To change this template use File | Settings | File Templates.
 */
package com.exponentum.apps.flirt.view.pages
{
import com.exponentum.apps.flirt.model.Config;
import com.exponentum.apps.flirt.model.Model;
import com.exponentum.apps.flirt.model.User;

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.events.Event;

import org.casalib.display.CasaSprite;
import org.casalib.events.LoadEvent;
import org.casalib.load.SwfLoad;

public class Profile extends CasaSprite
{
	private var bgLoad:SwfLoad;
	private var background:CasaSprite = new CasaSprite();
	private var foreground:CasaSprite = new CasaSprite();

	private var tasksButton:SimpleButton = new TasksButton();
	private var ratingsButton:SimpleButton = new RatingsButton();
	private var zodiacSign:ZodiacSign = new ZodiacSign();
	private var shelf:Shelf = new Shelf();

	private var profileDetails:ProfileDetails = new ProfileDetails();

	private var _user:User;

	public function Profile(user:User)
	{
		_user = user;

		init();
	}

	private function init():void
	{
		addChild(background);
		setBackground(1);

		tasksButton.x = -5;
		tasksButton.y = 176;
		addChild(tasksButton);
		
		ratingsButton.x = tasksButton.x;
		ratingsButton.y = 312;
		addChild(ratingsButton);

		zodiacSign.x = 215;
		zodiacSign.y = 195;
		addChild(zodiacSign);
		zodiacSign.gotoAndStop(_user.zodiac);

		shelf.x = 60;
		shelf.y = 455;
		addChild(shelf);

		createProfileDetails();
	}

	private function createProfileDetails():void
	{
		profileDetails.x = 312;
		profileDetails.y = 133;
		addChild(profileDetails);

		profileDetails.sexIndicator.gotoAndStop(_user.sex);
		profileDetails.nameText.text = _user.name;
		profileDetails.ageText.text = _user.birthDate;
		profileDetails.cityText.text = _user.city;
	}


	public function setBackground(bgId:int):void
	{
		bgLoad = new SwfLoad(Config.RESOURCES_SERVER + "backgrounds/bg" + bgId + ".swf");
		bgLoad.addEventListener(LoadEvent.COMPLETE, onBgLoaded);
		bgLoad.start();
	}

	private function onBgLoaded(e:LoadEvent):void
	{
		background.removeChildren(true, true);
		background.addChild(bgLoad.contentAsMovieClip);
	}
}
}
