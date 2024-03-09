package;

import haxe.Json;
import Section.SwagSection;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import haxe.io.Path;
import stageObjects.*;

using StringTools;

typedef AnimLoader =
{
	var prefix:String;
	var postfix:String;
	var x:Float;
	var y:Float;
	var fps:Int;
	var looped:Bool;
	var indices:Array<Int>;
}

typedef CharLoader =
{
	var img:String;
	var iconColor:String;
	var flipX:Bool;
	var flipY:Bool;
	var usesAtlas:Bool;
	var gfIdle:Bool;
	var anims:Array<AnimLoader>;
	var charScale:Float;
	var charPosition:Array<Float>;
	var antialiasing:Bool;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var scalevalue:Float;
	public var usesAtlas:Bool = false;

	public var animationNotes:Array<Dynamic> = [];
	
	public var danceIdle:Bool = false;
	public var iconColor:FlxColor;

	public var jsonSystem:CharLoader;

	public var startedDeath:Bool = false;

	public static var inAnimState:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{

			default:
				if (Assets.exists(Paths.json(curCharacter, 'characters')))
					jsonSystem = Json.parse(Assets.getText(Paths.json(curCharacter, 'characters')));
				else
					jsonSystem = Json.parse(Assets.getText(Paths.json('dad', 'characters')));

				if (jsonSystem.flipX != true && jsonSystem.flipX != false)
					jsonSystem.flipX = false;

				if (jsonSystem.flipY != true && jsonSystem.flipY != false)
					jsonSystem.flipY = false;

				if (jsonSystem.usesAtlas != true && jsonSystem.usesAtlas != false)
					jsonSystem.usesAtlas = false;

				if (jsonSystem.gfIdle != true && jsonSystem.gfIdle != false)
					jsonSystem.gfIdle = false;

				if (jsonSystem.antialiasing != true && jsonSystem.antialiasing != false)
					jsonSystem.antialiasing = true; // it will be changed after we get the antialiasing option


				if(jsonSystem.usesAtlas){
					tex = Paths.getPackerAtlas('characters/${jsonSystem.img}');
				}
				else
					tex = Paths.getSparrowAtlas('characters/${jsonSystem.img}');

				frames = tex;



				for (anim in jsonSystem.anims){
					if (anim.fps < 1)
						anim.fps = 24;
					
					if (anim.looped != true && anim.looped != false)
						anim.looped = false;

					if (anim.indices != null)
						animation.addByIndices(anim.prefix, anim.postfix, anim.indices, "", anim.fps, anim.looped);
					else
						animation.addByPrefix(anim.prefix, anim.postfix, anim.fps, anim.looped);
						addOffset(anim.prefix, anim.x, anim.y);
				}

				flipX = jsonSystem.flipX;
				flipY = jsonSystem.flipY;
				usesAtlas = jsonSystem.usesAtlas;
				antialiasing = jsonSystem.antialiasing;
				danceIdle = jsonSystem.gfIdle;
				
				if(jsonSystem.charScale != 1) {
					scalevalue = jsonSystem.charScale;
					setGraphicSize(Std.int(width * scalevalue));
					updateHitbox();
				}
				
		}

		dance();
		animation.finish();

		switch(curCharacter)
		{
			case 'pico-speaker':
				if (!inAnimState){
					loadMappedAnims();	
				}
				playAnim("shoot1");
		}

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	public function loadMappedAnims()
	{
		if (Assets.exists('assets/data/${PlayState.SONG.song.toLowerCase()}/picospeaker.json')){
		var swagshit = Song.loadFromJson('picospeaker', PlayState.SONG.song.toLowerCase());

		var notes = swagshit.notes;

		for (section in notes)
		{
			for (idk in section.sectionNotes)
			{
				animationNotes.push(idk);
			}
		}

		TankmenBG.animationNotes = animationNotes;

		trace(animationNotes);
		animationNotes.sort(sortAnims);
		}
	}

	function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]);
	}

	function quickAnimAdd(name:String, prefix:String)
	{
		animation.addByPrefix(name, prefix, 24, false);
	}

	private function loadOffsetFile(offsetCharacter:String)
	{
		var daFile:Array<String> = CoolUtil.coolTextFile(Paths.file("characters/" + offsetCharacter + "Offsets", "images", 'txt'));

		for (i in daFile)
		{
			var splitWords:Array<String> = i.split(" ");
			addOffset(splitWords[0], Std.parseInt(splitWords[1]), Std.parseInt(splitWords[2]));
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		} else {
			if (animation.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}
				else
					holdTimer = 0;
	
				if (animation.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
				{
					playAnim('idle', true, false, 10);
				}
	
				if (animation.name == 'firstDeath' && animation.curAnim.finished && startedDeath)
				{
					playAnim('deathLoop');
				}
		}

		if (curCharacter.endsWith('-car'))
		{
			// looping hair anims after idle finished
			if (!animation.name.startsWith('sing') && animation.curAnim.finished)
				playAnim('idleHair');
		}

		if (danceIdle){
			if (animation.name == 'hairFall' && animation.curAnim.finished)
				playAnim('danceRight');
		}	
		switch (curCharacter)
		{
				
			case "pico-speaker":
				// for pico??
				if (animationNotes.length > 0)
				{
					if (Conductor.songPosition > animationNotes[0][0])
					{
						trace('played shoot anim' + animationNotes[0][1]);

						var shootAnim:Int = 1;

						if (animationNotes[0][1] >= 2)
							shootAnim = 3;

						shootAnim += FlxG.random.int(0, 1);

						playAnim('shoot' + shootAnim, true);
						animationNotes.shift();
					}
				}

				if (animation.curAnim.finished)
				{
					playAnim(animation.name, false, false, animation.curAnim.numFrames - 3);
				}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			if(danceIdle){
				danced = !danced;

				if (danced)
					playAnim('danceRight');
				else
					playAnim('danceLeft');
			}
			else
				playAnim('idle');
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}