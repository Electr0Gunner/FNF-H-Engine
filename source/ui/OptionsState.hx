package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.util.FlxSignal;

// typedef OptionsState = OptionsMenu_old;
// class OptionsState_new extends MusicBeatState
class OptionsState extends MusicBeatState
{
	var pages = new Map<PageName, Page>();
	var currentName:PageName = Options;
	var currentPage(get, never):Page;
	public static var fromPlayState:Bool = false;

	inline function get_currentPage()
		return pages[currentName];

	override function create()
	{
		var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.scale.set(1.1, 1.1);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var options = addPage(Options, new OptionsMenu(false));
		var preferences = addPage(Preferences, new PreferencesMenu());
		var controls = addPage(Controls, new ControlsMenu());
		// var colors = addPage(Colors, new ColorsMenu());

		#if cpp
		//var mods = addPage(Mods, new ModMenu());
		#end

		if (options.hasMultipleOptions())
		{
			options.onExit.add(exitToMainMenu);
			controls.onExit.add(switchPage.bind(Options));
			// colors.onExit.add(switchPage.bind(Options));
			preferences.onExit.add(switchPage.bind(Options));

			#if cpp
			//mods.onExit.add(switchPage.bind(Options));
			#end
		}
		else
		{
			// No need to show Options page
			controls.onExit.add(exitToMainMenu);
			setPage(Controls);
		}

		// disable for intro transition
		currentPage.enabled = false;
		super.create();
	}

	function addPage<T:Page>(name:PageName, page:T)
	{
		page.onSwitch.add(switchPage);
		pages[name] = page;
		add(page);
		page.exists = currentName == name;
		return page;
	}

	function setPage(name:PageName)
	{
		if (pages.exists(currentName))
			currentPage.exists = false;

		currentName = name;

		if (pages.exists(currentName))
			currentPage.exists = true;
	}

	override function finishTransIn()
	{
		super.finishTransIn();

		currentPage.enabled = true;
	}

	function switchPage(name:PageName)
	{
		// Todo animate?
		setPage(name);
	}

	function exitToMainMenu()
	{
		currentPage.enabled = false;
		// Todo animate?
		// Todo make the exiting go to playstate if going in from there -electr0
		if (!fromPlayState)
			FlxG.switchState(new MainMenuState());
		else
			LoadingState.loadAndSwitchState(new PlayState());
	}
}

class Page extends FlxGroup
{
	public var onSwitch(default, null) = new FlxTypedSignal<PageName->Void>();
	public var onExit(default, null) = new FlxSignal();

	public var enabled(default, set) = true;
	public var canExit = true;

	var controls(get, never):Controls;

	inline function get_controls()
		return PlayerSettings.player1.controls;

	var subState:FlxSubState;

	inline function switchPage(name:PageName)
	{
		onSwitch.dispatch(name);
	}

	inline function exit()
	{
		onExit.dispatch();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (enabled)
			updateEnabled(elapsed);
	}

	function updateEnabled(elapsed:Float)
	{
		if (canExit && controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			exit();
		}
	}

	function set_enabled(value:Bool)
	{
		return this.enabled = value;
	}

	function openPrompt(prompt:Prompt, onClose:Void->Void)
	{
		enabled = false;
		prompt.closeCallback = function()
		{
			enabled = true;
			if (onClose != null)
				onClose();
		}

		FlxG.state.openSubState(prompt);
	}

	override function destroy()
	{
		super.destroy();
		onSwitch.removeAll();
	}
}

class OptionsMenu extends Page
{
	var items:TextMenuList;

	public function new(showDonate:Bool)
	{
		super();

		add(items = new TextMenuList());
		createItem('preferences', function() switchPage(Preferences));
		createItem("controls", function() switchPage(Controls));
		// createItem('colors', function() switchPage(Colors));
		#if cpp
		//createItem('mods', function() switchPage(Mods));
		#end

		#if CAN_OPEN_LINKS
		if (showDonate)
		{
			var hasPopupBlocker = #if web true #else false #end;
			createItem('donate', selectDonate, hasPopupBlocker);
		}
		#end
		createItem("exit", exit);
	}

	function createItem(name:String, callback:Void->Void, fireInstantly = false)
	{
		var item = items.createItem(0, 100 + items.length * 100, name, Bold, callback);
		item.fireInstantly = fireInstantly;
		item.screenCenter(X);
		return item;
	}

	override function set_enabled(value:Bool)
	{
		items.enabled = value;
		return super.set_enabled(value);
	}

	/**
	 * True if this page has multiple options, excluding the exit option.
	 * If false, there's no reason to ever show this page.
	 */
	public function hasMultipleOptions():Bool
	{
		return items.length > 2;
	}

	#if CAN_OPEN_LINKS
	function selectDonate()
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
		#else
		FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
		#end
	}
	#end

}

enum PageName
{
	Options;
	Controls;
	Colors;
	//Mods;
	Preferences;
}
