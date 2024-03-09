package;

import openfl.Assets;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var pauseOG:Array<String> = [
		'Resume',
		'Restart Song',
		'Options',
		'Change Difficulty',
		'Toggle Practice Mode',
		'Exit to menu'
	];
	var difficultyChoices:Array<String> = ['EASY', 'NORMAL', 'HARD', 'BACK'];

	var menuItems:Array<String> = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var practiceText:FlxText;
	var composer:Null<String>;

	public function new(x:Float, y:Float)
	{
		super();
		// cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		menuItems = pauseOG;

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var composerValue = Paths.text('composer', 'data/${PlayState.SONG.song.toLowerCase}');
		if (Assets.exists(composerValue)) composer = Assets.getText(composerValue);

		final songText:String = StringTools.replace(PlayState.SONG.song, '-', ' '); // Dashes mean spaces in song names, this is to respect that
		var levelInfo:FlxText = new FlxText(20, 15, 0, songText, 32);
		if (composer != null) levelInfo.text += ' - $composer';
		levelInfo.setFormat("VCR OSD Mono", 32);
		// levelInfo.updateHitbox();
		levelInfo.scrollFactor.set();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, PlayState.storyDifficulty.toUpperCase(), 32);
		levelDifficulty.setFormat("VCR OSD Mono", 32);
		// levelDifficulty.updateHitbox();
		levelDifficulty.scrollFactor.set();
		add(levelDifficulty);

		var deathCounter:FlxText = new FlxText(20, 15 + 64, 0, 'Blueballed: ${PlayState.deathCounter}', 32);
		deathCounter.setFormat("VCR OSD Mono", 32);
		// deathCounter.updateHitbox();
		deathCounter.scrollFactor.set();
		add(deathCounter);

		practiceText = new FlxText(20, 15 + 64 + 32, 0, 'PRACTICE MODE', 32);
		practiceText.setFormat("VCR OSD Mono", 32);
		// practiceText.updateHitbox();
		practiceText.scrollFactor.set();
		practiceText.visible = PlayState.practiceMode;
		add(practiceText);
		
		for (daText in [levelInfo, levelDifficulty, deathCounter, practiceText])
		{
			daText.x = FlxG.width - (daText.width + 20);
			daText.alignment = RIGHT;
			if (daText != practiceText) daText.alpha = 0;
		}

		final sharedTweenProperties = {
			duration: 0.4,
			ease: FlxEase.quartInOut,
			baseDelay: 0.3
		};

		FlxTween.tween(bg, {alpha: 0.6}, sharedTweenProperties.duration, {ease: sharedTweenProperties.ease});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, sharedTweenProperties.duration, 
		{
			ease: sharedTweenProperties.ease,
			startDelay: sharedTweenProperties.baseDelay
		});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, sharedTweenProperties.duration, 
		{
			ease: sharedTweenProperties.ease,
			startDelay: (sharedTweenProperties.baseDelay + 0.2)
		});
		FlxTween.tween(deathCounter, {alpha: 1, y: deathCounter.y + 5}, sharedTweenProperties.duration, 
		{
			ease: sharedTweenProperties.ease,
			startDelay: (sharedTweenProperties.baseDelay + 0.4)
		});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
	}

	private function regenMenu():Void
	{
		while (grpMenuShit.members.length > 0)
		{
			grpMenuShit.remove(grpMenuShit.members[0], true);
		}

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		curSelected = 0;
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if (controls.UI_UP_P) changeSelection(-1);
		if (controls.UI_DOWN_P) changeSelection(1);

		if (controls.ACCEPT)
		{
			switch (menuItems[curSelected].toLowerCase())
			{
				// Song related
				case 'resume': close();
				case 'restart song': FlxG.resetState();
				case 'exit to menu':
					PlayState.seenCutscene = false;
					PlayState.deathCounter = 0;

					final daMenu:flixel.FlxState = (PlayState.isStoryMode) ? new StoryMenuState() : new FreeplayState();
					FlxG.switchState(daMenu);

				case 'options':
					FlxG.switchState(new ui.OptionsState());
					ui.OptionsState.fromPlayState = true;

				// Difficulty change
				case 'change difficulty':
					menuItems = difficultyChoices;
					regenMenu();
				case 'easy' | 'normal' | 'hard':
					var daDiff:String = difficultyChoices[curSelected];
					PlayState.SONG = Song.loadFromJson(Highscore.formatSong(PlayState.SONG.song, daDiff));
					PlayState.storyDifficulty = daDiff.toLowerCase();

					FlxG.resetState();
				case 'back':
					menuItems = pauseOG;
					regenMenu();

				case 'Toggle Practice Mode': PlayState.practiceMode = !PlayState.practiceMode;
			}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;
		for (item in grpMenuShit.members)
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
