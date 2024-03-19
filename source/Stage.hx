package;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.group.FlxGroup;

import stageObjects.*;
import shaderslmfao.*;

class Stage
{
	private var game(default, null):Dynamic = PlayState.instance;
	/**
	 * Override this if you aren't on PlayState and you want foreground sprites.
	 * Or if you want foreground sprites to go under specific layering, idk
	 */
	public var fgSprPath:flixel.util.typeLimit.OneOfThree<FlxTypedGroup<BGSprite>, FlxGroup, FlxTypedGroup<flixel.FlxSprite>>;
	public static var animatedSpritesList:FlxTypedGroup<BGSprite> = new FlxTypedGroup<BGSprite>();

	public static var stageDirectory:String;
	public static var zoom:Float = 0.85;

	public function new(?stage:Null<String>, ?pos:haxe.PosInfos)
	{
		fgSprPath = game.foregroundSprites;

		// Will work in other States
		if (pos.className != 'PlayState')
		{
			trace(pos.className);
			
			game = Type.resolveClass(pos.className);
			fgSprPath = game;
		}

		switch (stage)
		{
			// I'll add softcoded stages later on -BerGP
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
			case 'halloween':
				stageDirectory = 'week2';

				var bg:BGSprite = new BGSprite('halloween_bg', -200, -100);
				bg.animation.addByIndices('idle', 'halloweem bg', [0], '', 1);
				bg.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				bg.normalDance = false;
				animatedSpritesList.add(bg);
				add(bg);
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
		else // Reflect.field had to be used as just saying add would think we're referring to this
			addFunction = (daSpr:BGSprite) -> Reflect.callMethod(fgSprPath, Reflect.field(fgSprPath, 'add'), [daSpr]);

		addFunction(spr);
	}

	// private function push(spr:BGSprite) game.insert(null, spr);
}