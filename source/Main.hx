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
	public var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with. TitleState
	public var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	#if web
	public var framerate:Int = 60; // How many frames per second the game should run at.
	#else
	public var framerate:Int = 144; // How many frames per second the game should run at.
	#end
	public var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	public var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var buildNumber:Float = 0;

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

		#if !debug
		initialState = TitleState;
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash, startFullscreen));

		#if sys
		trace(Paths.text('buildNum'));

		if (Assets.exists(Paths.text('buildNum'))){
			var oldBuild = Std.parseFloat(Assets.getText(Paths.text('buildNum')));

			File.saveBytes(FileSystem.absolutePath(Paths.text('buildNum')), Bytes.ofString('${oldBuild += 1}'));

			buildNumber = Std.parseFloat(Assets.getText(Paths.text('buildNum')));
		}
		#else
		//nothing
		#end


		#if !mobile
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		#end
	}
}
