package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var fg:FlxSprite;
	var bg2:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var offsetThing:Float = -75;

	override function create()
	{

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		add(bg);
		bg.screenCenter();

		bg2 = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		add(bg2);
		bg2.screenCenter();
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);


		var pisspoop:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			['Electr0Gunner',		'Electr0Gunner',		' - Creator of Engine \n - Lead Coder', 'https://www.youtube.com/channel/UCWirfEOLNcRU9Z00Ra2Pzqw'],
			[''],
            ['TheRealJake_12',		'TheRealJake_12',		' - Person who helped \n   Electr0Gunner understand \n the code', 'https://www.youtube.com/channel/UCYy-RfMjVx-1dYnmNQGB2sw'],
			[''],
			['GANGSTER_BACON3',		'GANGSTER_BACON3',		' - Person who made the\n   Credits state', 'https://www.youtube.com/channel/UCvdmgoCsWhcVPSwB7h91GEg'],
            [''],
			['NINJAMUFFIN',		'NINJAMUFFIN',		' - Friday Night Funkin Dev \n - Check out their \n   kickstarter!', 'https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game'],
			['PHANTOMARCADE',		'PHANTOMARCADE',		' - Friday Night Funkin Dev \n - Check out their \n   kickstarter!', 'https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game'],
			['KAWAISPRITE',		'KAWAISPRITE',		' - Friday Night Funkin Dev \n - Check out their \n   kickstarter!', 'https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game'],
			['EVILSKR',		'EVILSKR',		' - Friday Night Funkin Dev \n - Check out their \n   kickstarter!', 'https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game'],

		];
		
		for(i in pisspoop){
			creditsStuff.push(i);
		}
	
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0,0,creditsStuff[i][0], true);
			optionText.isFreeItem = true;
			optionText.targetY = i;
			grpOptions.add(optionText);
			optionText.x += 30;

			if(isSelectable) {
				if(creditsStuff[i][5] != null)
				{
				
				}


				if(curSelected == -1) curSelected = i;
			}
		}
		

		descText = new FlxText(750, FlxG.height + offsetThing - 25, 1180, "");
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
		descText.scrollFactor.set();
		descText.screenCenter(Y);
		add(descText);



		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}


			if(controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)) {
				/*
				//CoolUtil.browserLoad(creditsStuff[curSelected][3]);
                #if linux
                // Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
                Sys.command('/usr/bin/xdg-open', [
                    creditsStuff[curSelected][3],
                    "&"
                ]);
                #else
                // FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
        
                FlxG.openURL(creditsStuff[curSelected][3]);
                #end
				*/
			}
			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(new MainMenuState());
				quitting = true;
			}
		}

		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int =  getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		//descText.y = FlxG.height - descText.height + offsetThing - 60;

	}

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}