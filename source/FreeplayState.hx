package;

import haxe.Json;
#if discord_rpc import Discord.DiscordClient; #end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
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

typedef Idk = 
{
	data:StoryMenuState.SongInfo,
	weekID:Int
}

class FreeplayState extends MusicBeatState
{
	var songs:Array<Idk> = [];

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

		for (week in StoryMenuState.weeks)
		{
			for (song in week.songs)
			{
				if (song.color == null) song.color = 0xFF9271FD;

				var fuckingID:Int = 0;
				for (idAttempt in 0...StoryMenuState.weeks.length)
				{
					if (StoryMenuState.weeks[idAttempt].songs.contains(song))
					{
						fuckingID = idAttempt;
						// break;
					}
				}

				var songStuff:Idk = {data: song, weekID: fuckingID};
				if (!songs.contains(songStuff)) songs.push(songStuff); // avoiding duplicate week song entries
			}
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
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].data.name, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].data.icon);
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
		if (songs[curSelected].data.color != bg.color)
			bg.color = FlxColor.interpolate(bg.color, songs[curSelected].data.color, CoolUtil.camLerpShit(0.045));

		scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);
		positionHighscore();

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

		/* if (controls.ACCEPT)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName, songs[curSelected].songDifficultys[curDifficulty]);
			PlayState.SONG = Song.loadFromJson(poop);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = songs[curSelected].songDifficultys[curDifficulty];

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState());
		} */
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;
		var difficulties:Array<String> = songs[curSelected].data.difficulties;

		if (curDifficulty < 0)
			curDifficulty = difficulties.length - 1;
		if (curDifficulty > difficulties.length - 1)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].data.name, difficulties[curDifficulty]);
		PlayState.storyDifficulty = difficulties[curDifficulty];

		diffText.text = '< ${difficulties[curDifficulty].toUpperCase()} >';
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

		var difficulties:Array<String> = songs[curSelected].data.difficulties;

		intendedScore = Highscore.getScore(songs[curSelected].data.name, difficulties[curDifficulty]);

		#if sys
		FlxG.sound.playMusic(Paths.song(songs[curSelected].data.name, 'Inst', difficulties[curDifficulty]), 0);
		#end

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}
		iconArray[curSelected].alpha = 1;
		
		var bullShit:Int = 0;
		for (item in grpSongs.members)
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
