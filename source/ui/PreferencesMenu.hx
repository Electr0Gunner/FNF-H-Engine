package ui;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import ui.AtlasText.AtlasFont;
import ui.TextMenuList.TextMenuItem;

class PreferencesMenu extends ui.OptionsState.Page
{
	public static var preferences:Map<String, Dynamic> = new Map();
	// public static var numberSettings:Array<String> = [];

	var items:TextMenuList;

	var checkboxes:Array<CheckboxThingie> = [];
	var menuCamera:FlxCamera;
	var camFollow:FlxObject;

	public function new()
	{
		super();

		menuCamera = new SwagCamera();
		menuCamera.bgColor.alpha = 0;
		FlxG.cameras.add(menuCamera, false);
		camera = menuCamera;

		add(items = new TextMenuList());

		createPrefItem('Downscroll', 'downscroll', false);
		createPrefItem('Beat Camera Zoom', 'camera-zoom', true);
		createPrefItem('FPS Counter', 'fps-counter', true);

		createPrefItem('Use MP4s on Week 7 cutscenes', 'cutscenes', false);
		createPrefItem('Flashing Menu', 'flashing-menu', true);
		createPrefItem('Naughtyness', 'censor-naughty', true);

		createPrefItem('Ghost Tapping', 'ghost-tapping', false);
		createPrefItem('Botplay', 'botplay', false);
		createPrefItem('Unfocused Auto Pause', 'auto-pause', false);

		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		items.onChange.add((selectedOpt:TextMenuItem) -> camFollow.y = selectedOpt.y - (FlxG.height / 4));
		menuCamera.follow(camFollow, null, 0.06);
		menuCamera.deadzone.set(0, 160, menuCamera.width, 40);
		// menuCamera.minScrollY = 0;
	}

	/**
	 * You avoided 8 keystrokes, what a difference
	 * @param pref Preference you want to get
	 * @return 		 Dynamic (in here, the option type instead)
	 */
	public static function getPref(pref:String):Dynamic
		return preferences.get(pref);

	/**
	 * Easy shorthand, and will help better
	 * @param pref 				Preference you want to update
	 * @param value 			The value you'll set it to
	 * @param setCallback [Optional] Function that'll get called when updating the pref, kinda like the `set` method on properties
	 * 
	 * @see `get`/`set` methods, their usage (originally, not here): https://haxe.org/manual/class-field-property.html
	 */
	public static function setPref(pref:String, value:Dynamic, ?setCallback:Dynamic->Void)
	{
		preferences.set(pref, value);
		FlxG.save.data.gamePrefs = preferences;
		if (setCallback != null) setCallback(value);
	}

	public static function initPrefs()
	{
		if (FlxG.save.data.gamePrefs != null)
			preferences = FlxG.save.data.gamePrefs
		else
		{
			prefCheck('downscroll', false);
			prefCheck('camera-zoom', true);
			prefCheck('fps-counter', true);
			prefCheck('cutscenes', true);
			prefCheck('flashing-menu', true);
			prefCheck('censor-naughty', true);
			prefCheck('ghost-tapping', false);
			prefCheck('botplay', false);
			prefCheck('auto-pause', false);
		}

		if (Main.fpsCounter != null) Main.fpsCounter.alpha = (!getPref('fps-counter')) ? 0 : 1;
		FlxG.autoPause = getPref('auto-pause');
	}

	private function createPrefItem(prefName:String, prefString:String, prefValue:Dynamic)
	{
		items.createItem(220, (120 * items.length) + 30, prefName, AtlasFont.Default, function()
		{
			prefCheck(prefString, prefValue);
			if (Type.typeof(prefValue) == Type.ValueType.TBool) prefToggle(prefString);
		});

		switch (Type.typeof(prefValue).getName().substr(1))
		{
			case 'Bool': createCheckbox(prefString);
			// case 'Float': numberSettings.push(prefString);
		}
	}

	function createCheckbox(prefString:String)
	{
		var checkbox:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), getPref(prefString));
		checkboxes.push(checkbox);
		add(checkbox);
	}

	private function prefToggle(prefName:String)
	{
		var updateBehaviour:Bool->Void = null;
		switch (prefName)
		{
			case 'fps-counter': updateBehaviour = (val:Bool) -> Main.fpsCounter.alpha = (!val) ? 0 : 1;
			case 'auto-pause': updateBehaviour = (val:Bool) -> FlxG.autoPause = val;
		}

		var daSwap:Bool = !getPref(prefName);
		setPref(prefName, daSwap, updateBehaviour);
		checkboxes[items.selectedIndex].daValue = daSwap;
		#if debug FlxG.log.notice('$prefName was set to $daSwap'); #end
	}

	private static function prefCheck(prefString:String, prefValue:Dynamic)
	{
		if (getPref(prefString) != null) return;

		setPref(prefString, prefValue);
		#if debug FlxG.log.warn('The setting `${StringTools.replace(prefString, '-', ' ')}` didn\'t exist previously'); #end
	}
}

class CheckboxThingie extends FlxSprite
{
	public var daValue(default, set):Bool;
	function set_daValue(value:Bool):Bool
	{
		switch (value)
		{
			case true:
				animation.play('checked', true);
				offset.set(17, 70);
			case false:
				animation.play('static');
				offset.set();
		}

		return value;
	}

	public function new(x:Float, y:Float, daValue:Bool = false)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('checkboxThingie');
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		animation.addByPrefix('static', 'Check Box unselected', 1, false);
		animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);

		antialiasing = true;

		this.daValue = daValue;
	}

}