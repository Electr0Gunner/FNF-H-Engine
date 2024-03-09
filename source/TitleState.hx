package;

import flixel.FlxG;
import openfl.Assets;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import shaderslmfao.ColorSwap;
import ui.PreferencesMenu;
import flixel.input.gamepad.FlxGamepad;

#if discord_rpc import Discord.DiscordClient; #end

using StringTools;

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;
	var startedIntro:Bool;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];
	// var wackyImage:FlxSprite; // Maybe on a future build ;) -BerGP
	var lastBeat:Int = 0;
	var swagShader:ColorSwap;
	
	override public function create()
	{
		startedIntro = false;

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = [ZERO];

		// Initializing some classes
		#if sys
		polymod.Polymod.init({
			modRoot: "mods",
			dirs: [Assets.getText(Paths.text('modSelected')), 'global'],
			errorCallback: (e) ->
			{
				trace(e.message);
			},
			frameworkParams: {
				assetLibraryPaths: [
					"songs" 	=> "assets/songs",
					"images" 	=> "assets/images",
					"data" 		=> "assets/data",
					"fonts" 	=> "assets/fonts",
					"sounds" 	=> "assets/sounds",
					"music" 	=> "assets/music",
				]
			}
		});

		HScript.parser = new hscript.Parser();
		HScript.parser.allowJSON = true;
		HScript.parser.allowMetadata = true;
		HScript.parser.allowTypes = true;
		HScript.parser.preprocesorValues = [
			"desktop" 		=> #if desktop true #else false #end,
			"windows" 		=> #if windows true #else false #end,
			"mac" 				=> #if mac true #else false #end,
			"linux"			 	=> #if linux true #else false #end,
			"debugBuild" 	=> #if debug true #else false #end
		];
		#end

		#if discord_rpc
		DiscordClient.initialize();
		lime.app.Application.current.onExit.add((exitCode) -> DiscordClient.shutdown());
		#end

		swagShader = new ColorSwap();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		FlxG.save.bind('Funkin-Source', 'Electr0');
		PreferencesMenu.initPrefs();
		PlayerSettings.init();
		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		new FlxTimer().start(1, (tmr) -> startIntro());

		super.create();
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.bpm = 102;
		persistentUpdate = true;

		logoBl = new FlxSprite(-130, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.updateHitbox();
		logoBl.shader = swagShader.shader;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.antialiasing = true;
		add(logoBl);

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.updateHitbox();
		gfDance.shader = swagShader.shader;
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		// titleText.updateHitbox();
		// titleText.screenCenter(X);
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.animation.play('idle');
		titleText.antialiasing = true;
		add(titleText);

		credGroup = new FlxGroup();
		textGroup = new FlxGroup();
		add(credGroup);
		add(textGroup);

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52, Paths.image('newgrounds_logo'));
		ngSpr.scale.set(0.8, 0.8);
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.visible = false;
		ngSpr.antialiasing = true;
		credGroup.add(ngSpr);

		if (!initialized) initialized = true;
		if (initialized) startedIntro = true;
	}

	private function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.text('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F) FlxG.fullscreen = !FlxG.fullscreen;

		// Other possible Enter inputs
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
		#if (mobile || !FLX_NO_TOUCH)
		for (touch in FlxG.touches.list)
			if (touch.justPressed) pressedEnter = true;
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			if (gamepad.justPressed.A || gamepad.justPressed.START)
				pressedEnter = true;
		}

		if (pressedEnter && skippedIntro)
		{
			if (FlxG.sound.music != null) FlxG.sound.music.onComplete = null;

			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
			titleText.animation.play('press');

			// Gotta give it some time for a good transition
			new FlxTimer().start(0.57, tmr -> FlxG.switchState(new MainMenuState()));
		}
		else if (pressedEnter && !skippedIntro && initialized) skipIntro();

		if (controls.UI_LEFT) 	swagShader.update(-elapsed * 0.1);
		if (controls.UI_RIGHT) 	swagShader.update(elapsed * 0.1);

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, (i * 60) + 200, textArray[i], true, false);
			money.screenCenter(X);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, (textGroup.length * 60) + 200, text, true, false);
		coolText.screenCenter(X);
		textGroup.add(coolText);
	}

	inline function deleteCoolText()
	{
		while (textGroup.members.length > 0)
			textGroup.remove(textGroup.members[0], true);
	}

	private var danced:Bool = false;
	private var daAnim:String = 'danceLeft';
	override function beatHit()
	{
		super.beatHit();

		if (!startedIntro) return;

		if (skippedIntro)
		{
			logoBl.animation.play('bump');

			danced = !danced;
			if (danced) daAnim = 'danceRight';
			else 				daAnim = 'danceLeft';

			gfDance.animation.play(daAnim);
		}
		else
		{
			// if the user is draggin the window some beats will
			// be missed so this is just to compensate
			if (curBeat > lastBeat)
			{
				// @Electr0Gunner, why are you tracing this again?
				#if debug FlxG.watch.addQuick('curBeat', curBeat); #end

				for (beat in lastBeat + 1...curBeat + 1)
				{
					switch (beat)
					{
						case 1: createCoolText(['The FNF Crew']); // They moved to FNFCrew
						case 3: addMoreText('presents');
						case 4: deleteCoolText();

						case 5: createCoolText(['In association', 'with']);
						case 7:
							addMoreText('newgrounds');
							ngSpr.visible = true;
						case 8:
							deleteCoolText();
							ngSpr.destroy(); // We don't need this anymore, this gets rid entirely of it

						case 9:  createCoolText([curWacky[0]]);
						case 11: addMoreText(curWacky[1]);
						case 12: deleteCoolText();

						case 13: createCoolText(['Friday', 'Night']);
						case 14: addMoreText('Funkin');
						case 15: addMoreText('H-Engine');
						case 16: skipIntro();
					}
				}
			}
		}
	}

	var skippedIntro:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 4);
			// credGroup for sprites, textGroup for Alphabet sprites (intro texts)
			credGroup.destroy();
			textGroup.destroy();

			skippedIntro = true;
		}
	}
}
