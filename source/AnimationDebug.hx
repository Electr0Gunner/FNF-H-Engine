package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUI;
import flixel.ui.FlxButton;

using StringTools;

/**
	*DEBUG MODE
 */
class AnimationDebug extends FlxState
{
	var char:Character;
	var charGhost:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;
	var UI_box:FlxUITabMenu;
	public static var curChar:String = "dad";
	

	public function new(daAnim:String = 'spooky', isPlayer:Bool = false)
	{
		super();
		this.daAnim = daAnim;
		isDad = !isPlayer;
	}

	override function create()
	{
		FlxG.mouse.visible = true;
		Character.inAnimState = true;

		FlxG.sound.music.stop();

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.text('characterList'));

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

		if (isDad)
		{
			charGhost = new Character(0, 0, daAnim);
			charGhost.alpha = 0.4;
			charGhost.color = FlxColor.BLACK;
			charGhost.debugMode = true;
			add(charGhost);

			char = new Character(0, 0, curChar);
			char.debugMode = true;
			add(char);
		}
		else
		{
			charGhost = new Character(0, 0, daAnim);
			charGhost.alpha = 0.4;
			charGhost.color = FlxColor.BLACK;
			charGhost.debugMode = true;
			add(charGhost);

			char = new Character(0, 0, curChar);
			char.debugMode = true;
			add(char);
		}

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		add(textAnim);

		var charDropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			curChar = characters[Std.parseInt(character)];
		});
		charDropDown.selectedLabel = curChar;

		var tabs = [
			{name: "Character Info", label: 'Character Info'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		UI_box.x += 100;
		add(UI_box);

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Character Info";
		tab_group_song.add(charDropDown);

		UI_box.addGroup(tab_group_song);

		var button = new FlxButton(800, 100, "Reload Character", updateChar);
		//button.screenCenter();
		add(button);

		genBoyOffsets();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

	function genBoyOffsets(pushList:Bool = true):Void
	{
		updateTexts();

		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = FlxColor.BLUE;
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	function updateChar(){
		animList = [];
		genBoyOffsets(true);

		charGhost.alpha = 0.0001;
		remove(charGhost);
		charGhost = new Character(0, 0, curChar);
		charGhost.alpha = 0.4;
		charGhost.color = FlxColor.BLACK;
		charGhost.debugMode = true;
		add(charGhost);

		char.alpha = 0.0001;
		remove(char);
		char = new Character(0, 0, curChar);
		add(char);
		char.alpha = 1;
	}

	override function update(elapsed:Float)
	{
		textAnim.text = char.animation.curAnim.name;

		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90;
			else
				camFollow.velocity.x = 0;
		}
		else
		{
			camFollow.velocity.set();
		}

		if (FlxG.keys.justPressed.W)
			{
				curAnim -= 1;
			}

			if (FlxG.keys.justPressed.S)
			{
				curAnim += 1;
			}

		if (curAnim < 0)
			curAnim = animList.length - 1;

		if (curAnim >= animList.length)
			curAnim = 0;

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
		{
			char.playAnim(animList[curAnim]);

			updateTexts();
			genBoyOffsets(false);
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (upP || rightP || downP || leftP)
		{
			if (upP)
				char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
			if (downP)
				char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
			if (leftP)
				char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
			if (rightP)
				char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;

			genBoyOffsets(false);
			char.playAnim(animList[curAnim]);
		}

		if (FlxG.keys.justPressed.ESCAPE)
			{
				Character.inAnimState = false;
				FlxG.mouse.visible = false;
				FlxG.switchState(new ui.ToolsState());
			}

		super.update(elapsed);
	}

	var _file:FileReference;

	private function saveOffsets(saveString:String)
	{
		if ((saveString != null) && (saveString.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(saveString, daAnim + "Offsets.txt");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	/**
	 * i snatched this from reflashed ngl
	 */
	function saveChar()
	{
		var char = {
			"img": char.jsonSystem.img,
			"charPosition": char.jsonSystem.charPosition,
			"charCamPosition": null,
			"anims": char.jsonSystem.anims,
			"flipX": char.jsonSystem.flipX,
			"flipY": char.jsonSystem.flipY,
			"gfIdle": char.jsonSystem.gfIdle,
			"iconColor": char.jsonSystem.iconColor,
			"charScale": char.jsonSystem.charScale
		};

		for (animOffset in animList)
		{
			for (anim in char.anims)
			{
				if (anim.prefix == animOffset)
				{
					anim.x = this.char.animOffsets.get(animOffset)[0];
					anim.y = this.char.animOffsets.get(animOffset)[1];
				}
			}
		}

		if (char.flipX != true && char.flipX != false)
			char.flipX = false;
		if (char.flipY != true && char.flipY != false)
			char.flipY = false;
		if (char.gfIdle != true && char.gfIdle != false)
			char.gfIdle = false;
		if (char.charPosition == null)
			char.charPosition = [0, 0];
		if (char.charCamPosition == null)
			char.charCamPosition = [0, 0];

		var data:String = haxe.Json.stringify(char);

		if ((data != null) && (data.length > 0))
		{
			var file = new FileReference();

			file.save(data, daAnim + '.json');
		}
	}
}