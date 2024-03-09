package ui;

import haxe.Json;
#if discord_rpc
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;


class ToolsState extends MusicBeatState
{

	// var selector:FlxText;
	var curSelected:Int = 0;
	var bg:FlxSprite;
	var scoreBG:FlxSprite;

	var tools:Array<String> = [
		'Chart Menu',
		'Offsets Menu'
	];

	
	private var grpTools:FlxTypedGroup<Alphabet>;

	override function create()
	{
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpTools = new FlxTypedGroup<Alphabet>();
		add(grpTools);

		var randInfo:FlxText = new FlxText(970, FlxG.height - 18, 0, "the offsets menu is still a wip",  12);
		randInfo.scrollFactor.set();
		randInfo.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(randInfo);


		for (i in 0...tools.length)
		{
			var toolText:Alphabet = new Alphabet(0, (70 * i) + 30, tools[i], true, false);
			toolText.isMenuItem = true;
			toolText.targetY = i;
			grpTools.add(toolText);
		}

		changeSelection();

		super.create();
	}


	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
		{
			if (FlxG.sound.music.volume < 0.7)
			{
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			}
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		if (FlxG.mouse.wheel != 0)
			changeSelection(-Math.round(FlxG.mouse.wheel / 4));

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			switch(tools[curSelected]) {
				case 'Chart Menu'://felt it would be cool maybe
					FlxG.switchState(new ChartingState());
				case 'Offsets Menu':
					FlxG.switchState(new AnimationDebug("dad",false));
			}
		}

	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = tools.length - 1;
		if (curSelected >= tools.length)
			curSelected = 0;

		var bullShit:Int = 0;
		for (item in grpTools.members)
		{			
			item.targetY = bullShit - curSelected;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}

			bullShit++;
		}
	}
}
