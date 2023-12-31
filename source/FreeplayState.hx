package;

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

typedef SongLoader =
{
	var songs:Array<String>;
	var icons:Array<String>;
	var colors:Array<String>;
	var diffs:Array<Array<String>>;
	var week:Int;
	var locked:Bool;
}

typedef FreeplayLoader =
{
	var addBaseGame:Bool;
	var weeks:Array<SongLoader>;
}

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	// var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	var bg:FlxSprite;
	var scoreBG:FlxSprite;

	var jsonSystem:FreeplayLoader;

	override function create()
	{
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		#if debug
		addSong('Test', 1, 'bf-pixel', ['easy', 'normal', 'hard'], 0xff9271fd);
		#end

		if (Assets.exists(Paths.json('songList')))
		{
			jsonSystem = Json.parse(openfl.Assets.getText(Paths.json('songList')));

			for (i => thing in jsonSystem.weeks)
			{
				addSong(thing.songs[i], thing.week, thing.icons[i], thing.diffs[i], FlxColor.fromString(thing.colors[i]));
			}
		}

		if (jsonSystem == null || jsonSystem.addBaseGame) {
			addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['gf', 'dad', 'dad', 'dad'], [['easy', 'normal', 'hard'], ['easy', 'normal', 'hard'], ['easy', 'normal', 'hard']], [0xff9271fd, 0xff9271fd, 0xff9271fd, 0xff9271fd]);

			addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky', 'spooky', 'monster'], [['easy', 'normal', 'hard'], ['easy', 'normal', 'hard'], ['easy', 'normal', 'hard']], [0xff223344, 0xff223344, 0xff223344]);
	
			addWeek(['Pico', 'Philly', 'Blammed'], 3, ['pico', 'pico', 'pico'], [['easy', 'normal', 'hard'], ['easy', 'normal', 'hard'], ['easy', 'normal', 'hard']], [0xFF941653, 0xFF941653, 0xFF941653]);
	
			addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom', 'mom', 'mom'], [['easy', 'normal', 'hard'], ['easy', 'normal', 'hard'], ['easy', 'normal', 'hard']], [0xFFfc96d7, 0xFFfc96d7, 0xFFfc96d7]);
	
			addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas'], [['easy', 'normal', 'hard'], ['easy', 'normal', 'hard'], ['easy', 'normal', 'hard']], [0xFFa0d1ff, 0xFFa0d1ff, 0xFFa0d1ff]);
	
			addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit'], [['easy', 'normal', 'hard'], ['easy', 'normal', 'hard'], ['easy', 'normal', 'hard']], [0xffff78bf, 0xffff78bf, 0xffff78bf]);
	
			addWeek(['Ugh', 'Guns', 'Stress'], 7, ['tankman', 'tankman', 'tankman'], [['easy', 'normal', 'hard'], ['easy', 'normal', 'hard'], ['easy', 'normal', 'hard']], [0xfff6b604, 0xfff6b604, 0xfff6b604]);	
		}

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0x99000000);
		scoreBG.antialiasing = false;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, songDifficultys:Array<String>, songColor:FlxColor)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, songDifficultys, songColor));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, songDifficultys:Array<Array<String>>, songColors:Array<FlxColor>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		for (i => song in songs)
		{
			addSong(song, weekNum, songCharacters[i], songDifficultys[i], songColors[i]);
		}
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

		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.4);
		bg.color = FlxColor.interpolate(bg.color, songs[curSelected].songColor, CoolUtil.camLerpShit(0.045));

		scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);

		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		if (FlxG.mouse.wheel != 0)
			changeSelection(-Math.round(FlxG.mouse.wheel / 4));

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), songs[curSelected].songDifficultys[curDifficulty].toLowerCase());
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = songs[curSelected].songDifficultys[curDifficulty];

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState());
		}

		#if debug
		if (FlxG.keys.justPressed.U)
		{
			PlayState.isStoryMode = true;
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), songs[curSelected].songDifficultys[curDifficulty].toLowerCase());
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState());
		}
		#end
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = songs[curSelected].songDifficultys.length - 1;
		if (curDifficulty > songs[curSelected].songDifficultys.length - 1)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, songs[curSelected].songDifficultys[curDifficulty]);

		PlayState.storyDifficulty = songs[curSelected].songDifficultys[curDifficulty];

		diffText.text = "< " + songs[curSelected].songDifficultys[curDifficulty].toUpperCase() + " >";
		positionHighscore();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, songs[curSelected].songDifficultys[curDifficulty]);
		// lerpScore = 0;

		#if sys
		FlxG.sound.playMusic(Paths.song(songs[curSelected].songName.toLowerCase(), "Inst", "Normal"), 0);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		changeDiff();
	}

	function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;

		diffText.x = Std.int(scoreBG.x + scoreBG.width / 2);
		diffText.x -= (diffText.width / 2);
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var songDifficultys:Array<String> = ["easy", "normal", "hard"];
	public var songColor:FlxColor = 0xff9271fd;

	public function new(song:String, week:Int, songCharacter:String, songDifficultys:Array<String>, songColor:FlxColor)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.songDifficultys = songDifficultys;
		this.songColor = songColor;
	}
}
