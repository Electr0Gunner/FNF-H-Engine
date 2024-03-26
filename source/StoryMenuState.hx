package;

import lime.utils.Assets;
import haxe.Json;
import sys.FileSystem;
#if discord_rpc import Discord.DiscordClient; #end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

typedef SongInfo = 
{
	name:String,
	icon:Null<String>,
	?difficulties:Array<String>,
	?color:FlxColor
}

typedef WeekInfo = 
{
	name:String,
	image:String,

	songs:Array<SongInfo>,
	chars:Array<String>,

	?unlockConditions:Array<Dynamic>,
	?difficulties:Array<String>,/*,
	// TODO: Add story mode BGS
	background:Null<String>
	*/
}

class StoryMenuState extends MusicBeatState
{
	public static var weeks:Array<WeekInfo> = [];
	static var weekSongs:Map<Int, Array<String>> = [];

	var curDifficulty:Int = 1;
	var curWeek:Int = 0;

	/* var weekData:Array<Dynamic> = [
		['Tutorial'],
		['Bopeebo', 'Fresh', 'Dadbattle'],
		['Spookeez', 'South', "Monster"],
		['Pico', 'Philly', "Blammed"],
		['Satin-Panties', "High", "Milf"],
		['Cocoa', 'Eggnog', 'Winter-Horrorland'],
		['Senpai', 'Roses', 'Thorns'],
		['Ugh', 'Guns', 'Stress']
	]; */
	

	/* public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true, true, true, true];

	var weekCharacters:Array<Dynamic> = [
		['dad', 'bf', 'gf'],
		['dad', 'bf', 'gf'],
		['spooky', 'bf', 'gf'],
		['pico', 'bf', 'gf'],
		['mom', 'bf', 'gf'],
		['parents-christmas', 'bf', 'gf'],
		['senpai', 'bf', 'gf'],
		['tankman', 'bf', 'gf']
	];

	var weekNames:Array<String> = [
		"How to Funk",
		"Daddy Dearest",
		"Spooky Month",
		"Pico",
		"MOMMY MUST MURDER",
		"Red Snow",
		"Hating Simulator ft. Moawling",
		"Tankman"
	]; */

	var txtWeekTitle:FlxText;
	var scoreText:FlxText;
	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;
	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var diffs:Array<String> = ["easy", "normal", "hard"];

	override function create()
	{
		persistentUpdate = true;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		scoreText = new FlxText(10, 10, 0, "", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		final ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		if (weeks.length == 0) initWeeks();

		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...weeks.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, weeks[i].image);
			// weekThing.updateHitbox();
			weekThing.screenCenter(X);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			weekThing.antialiasing = true;
			grpWeekText.add(weekThing);

			// Needs an offset thingie
			if (weeks[i].unlockConditions != null && !weeks[i].unlockConditions[0])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}
		}

		for (char in 0...3)
		{
			var daChar:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, weeks[curWeek].chars[char]);
			daChar.y += 70;
			switch (daChar.character)
			{
				case 'dad' | 'gf':
					daChar.setGraphicSize(Std.int(daChar.width * 0.5));
					daChar.updateHitbox();
				case 'bf':
					daChar.setGraphicSize(Std.int(daChar.width * 0.9));
					daChar.updateHitbox();
					daChar.x -= 80;
				case 'pico':
					daChar.flipX = true;
				case 'parents-christmas':
					daChar.setGraphicSize(Std.int(daChar.width * 0.9));
					daChar.updateHitbox();
			}
			daChar.antialiasing = true;
			grpWeekCharacters.add(daChar);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		changeDifficulty();
		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		add(yellowBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks\n???", 32);
		txtTracklist.setFormat("VCR OSD Mono", 32, 0xFFe55777, CENTER);
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		super.create();
	}

	public static function initWeeks()
	{
		pushWeekJsons("assets/weeks");
		#if !desktop return; #end
		
		final selectedMod:String = 'mods/${Assets.getText(Paths.text('modSelected'))}';
		if (FileSystem.exists('$selectedMod/weeks')) pushWeekJsons('$selectedMod/weeks');
	}

	private static var songID:Int; // Had to define it here outside or the value would keep resetting
	private static function pushWeekJsons(weekDir:String)
	{
		final dirOutput:Array<String> = FileSystem.readDirectory(weekDir);
		for (file in dirOutput)
		{
			if (!file.endsWith('.json')) break; // Only when the file is a json, we keep going
			
			final fileWithoutExt = file.substring(0, file.lastIndexOf('.'));
			var rawFile = Assets.getText(Paths.json(fileWithoutExt, 'weeks')).trim();

			var week:WeekInfo = Json.parse(rawFile);
			if (week.difficulties == null) week.difficulties = ['easy', 'normal', 'hard'];

			var songList:Array<String> = [];
			for (song in week.songs)
			{
				songList.push(song.name);
				if (song.difficulties == null) song.difficulties = week.difficulties;
			}

			if (!weeks.contains(week)) weeks.push(week);
			weekSongs.set(songID, songList);

			songID++;

			// TODO: Make a difficulties array specific to a week json
			// FIXME: When the array's lenth goes smaller than 3, the difficulty system goes crazy
			// if (daJson.difficulties != null) diffs = daJson.difficulties;
		}
	}

	override function update(elapsed:Float)
	{
		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.5);

		scoreText.text = 'SCORE: ${Math.round(lerpScore)}';

		txtWeekTitle.text = weeks[curWeek].name.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		grpLocks.forEach((lock:FlxSprite) -> lock.y = grpWeekText.members[lock.ID].y);

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UI_UP_P)
				{
					changeWeek(-1);
				}

				if (controls.UI_DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.UI_RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.UI_LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.UI_RIGHT_P)
					changeDifficulty(1);
				if (controls.UI_LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		final canPlay:Bool = (weeks[curWeek].unlockConditions != null) ? weeks[curWeek].unlockConditions[0] : true;
		if (!canPlay)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}

		if (!stopspamming)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));

			grpWeekText.members[curWeek].startFlashing();
			grpWeekCharacters.members[1].animation.play('bfConfirm');
			stopspamming = true;
		}
		selectedWeek = true;
		PlayState.isStoryMode = true;

		PlayState.storyPlaylist = weekSongs.get(curWeek);
		PlayState.storyDifficulty = diffs[curDifficulty];

		var diffic:String = null;
		switch (curDifficulty)
		{
			case 0: diffic = 'easy';
			case 2: diffic = 'hard';
		}
		var songJson:String = weekSongs.get(curWeek)[0]; // The first track of the list, it's the same as PlayState.storyPlaylist[0]
		if (diffic != null) songJson += '-$diffic';
		PlayState.SONG = Song.loadFromJson(songJson);

		PlayState.storyWeek = curWeek;
		PlayState.campaignScore = 0;
		LoadingState.loadAndSwitchState(new PlayState(), true);
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = diffs.length - 1;
		if (curDifficulty > diffs.length - 1)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, diffs[curDifficulty].toLowerCase());

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0)
	{
		curWeek += change;

		if (curWeek >= weeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weeks.length - 1;

		var bullShit:Int = 0;
		var vis:Bool = (weeks[curWeek].unlockConditions != null) ? weeks[curWeek].unlockConditions[0] : true;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && vis)
				item.alpha = 1;
			else
				item.alpha = 0.6;

			bullShit++;
		}

		difficultySelectors.visible = vis;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		grpWeekCharacters.members[0].animation.play(weeks[curWeek].chars[0]);
		grpWeekCharacters.members[1].animation.play(weeks[curWeek].chars[1]);
		grpWeekCharacters.members[2].animation.play(weeks[curWeek].chars[2]);

		switch (grpWeekCharacters.members[0].animation.name)
		{
			case 'parents-christmas':
				grpWeekCharacters.members[0].offset.set(200, 200);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 0.99));

			case 'senpai':
				grpWeekCharacters.members[0].offset.set(130, 0);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1.4));

			case 'mom':
				grpWeekCharacters.members[0].offset.set(100, 200);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1));

			case 'dad':
				grpWeekCharacters.members[0].offset.set(120, 200);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1));
			case 'tankman':
				grpWeekCharacters.members[0].offset.set(60, -20);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1));

			default:
				grpWeekCharacters.members[0].offset.set(100, 100);
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1));
				// grpWeekCharacters.members[0].updateHitbox();
		}

		txtTracklist.text = "Tracks\n";
		for (songName in weekSongs.get(curWeek)) txtTracklist.text += '\n$songName';
		txtTracklist.text = txtTracklist.text.toUpperCase();
		txtTracklist.x = FlxG.width * 0.05;

		intendedScore = Highscore.getWeekScore(curWeek, diffs[curDifficulty].toLowerCase());
	}
}