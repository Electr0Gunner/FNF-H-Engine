package;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.group.FlxGroup;

import BGSprite;
import shaderslmfao.*;

// TODO: Make it in a stageObjects folder, so no individual imports are needed
import BackgroundDancer;
import BackgroundGirls;

class Stage
{
	private var game(default, null):PlayState = PlayState.instance;
	public static var stageDirectory:String;

	public static var animatedSpritesList:FlxTypedGroup<BGSprite> = new FlxTypedGroup<BGSprite>();

	public var zoom:Float = 0.9;

	public function new(?stage:String)
	{
		switch (stage)
		{
			default:
				if (stage != 'stage') FlxG.log.warn("Current stage isn't defined dumbass! Come back to Stage.hx and define it");

				stageDirectory = 'week1';

				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setScale(1.1);
				add(stageFront);

				var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
				stageCurtains.setScale(0.9);
				add(stageCurtains, true);
		}

		game.defaultCamZoom = zoom;
	}

	public static function objectIdles()
	{
		for (animatedSpr in animatedSpritesList)
			if (animatedSpr.normalDance) animatedSpr.dance();
	}

	private function add(spr:BGSprite, ?inFront:Bool = false)
	{
		var addFunction:BGSprite -> Void;
		if (!inFront)
			addFunction = (daSpr:BGSprite) -> game.add(daSpr);
		else
			addFunction = (daSpr:BGSprite) -> game.foregroundSprites.add(daSpr);

		addFunction(spr);
	}

	// private function push(spr:BGSprite) game.insert(null, spr);
}