package;

import lime.utils.Log;
#if discord_rpc
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = 
	[
		'story mode',
		'freeplay',
		'donate',
		'options'
	];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	public final fnfVersion = "0.2.8";

	override function create()
	{
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
		
		persistentUpdate = persistentDraw = true;
		
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		FlxG.camera.follow(camFollow, null, 0.06);

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scale.set(1.1, 1.1);
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set(0, 0.17);
		bg.antialiasing = true;
		// Some changes to help with not showing the border of this whenever we have more than 5 options
		if (optionShit.length >= 4)
		{
			final scaleMult = (optionShit.length - 1) + .81;
			bg.scale.x *= optionShit.length / scaleMult;
			bg.scale.y *= optionShit.length / scaleMult;

			final decimalShit = (optionShit.length <= 7) ? '0' : '';
			bg.scrollFactor.y -= Std.parseFloat('0.$decimalShit${optionShit.length + 2}');
		}
		add(bg);

		// Will have the same properties as the original (thanks to `copyFrom`)
		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.color = 0xFFfd719b;
		magenta.scale.copyFrom(bg.scale);
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.scrollFactor.copyFrom(bg.scrollFactor);
		magenta.antialiasing = bg.antialiasing;
		magenta.visible = false;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var opt_tex = Paths.getSparrowAtlas('FNF_main_menu_assets');
		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + ((i * 160) / 1.05));
			menuItem.frames = opt_tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = 0.135 * Math.round(optionShit.length - 2.15); // Just to make it feel better
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = true;
		}

		var versionShit:FlxText = new FlxText(5, FlxG.height - 36, 0, 
			"H-Engine v" + Application.current.meta.get('version') +
			"\nFriday Night Funkin' v" + fnfVersion
		, 16);
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.scrollFactor.set();
		add(versionShit);

		var tipTxt:FlxText = new FlxText(FlxG.width - 262, FlxG.height - 20, 0, "Press U to access Tools Menu", 12);
		tipTxt.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipTxt.scrollFactor.set();
		add(tipTxt);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
	
		if (!selectedSomethin)
		{
			if (FlxG.keys.justPressed.U)
			{
				selectedSomethin = true;
				FlxG.switchState(new ui.ToolsState());
			}

			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}


			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										FlxG.switchState(new StoryMenuState());
										trace("Story Menu Selected");
									case 'freeplay':
										FlxG.switchState(new FreeplayState());

										trace("Freeplay Menu Selected");

									case 'options':
										//FlxTransitionableState.skipNextTransIn = true;
										//FlxTransitionableState.skipNextTransOut = true;
										FlxG.switchState(new ui.OptionsState());
										trace("Options Menu Selected");
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(0, spr.getGraphicMidpoint().y);
				// Incase you selected the 5th option or higher, the camera goes up to avoid showing the boundaries of the background
				if (optionShit.length >= 5 && curSelected >= 3) camFollow.y -= optionShit.length * 10;
			}

			spr.updateHitbox();
		});
	}
}
