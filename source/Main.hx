package;

#if sys
import sys.FileSystem;
import haxe.io.Bytes;
import sys.io.File;
#end
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.media.Video;
import openfl.net.NetStream;

class Main extends Sprite
{
	/**
	 * Width of the game in pixels.
	 * 
	 * Can differ deppending on the zoom
	 */
	public var gameWidth:Int = 1280;
	/**
	 * Height of the game in pixels.
	 * 
	 * Can differ deppending on the zoom
	 */
	public var gameHeight:Int = 720;

	/**
	 * The `FlxState` the game starts with.
	 */
	public var initialState:Class<FlxState> = TitleState;
	/**
	 * The zoom of the game.
	 * 
	 * When it's value is `-1`; It's automatically calculated to fit the window dimensions.
	 */
	public var zoom:Float = -1;
	/**
	 * How many Frames Per Second the game should run at.
	 */
	public var framerate:Int = #if !web 120 #else 60 #end;
	public var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	public var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var fpsCounter:FPS;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		initialState = TitleState;

		addChild(new FlxGame(gameWidth, gameHeight, initialState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash, startFullscreen));

		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
	}
}
