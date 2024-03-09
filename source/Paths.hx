package;

import openfl.Assets;
import flixel.FlxG;
#if sys
import sys.FileSystem;
#end
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Paths
{
	public static function file(key:String, location:String, extension:String):String
	{
		if (location.startsWith('null')) location = location.substr(5);
		return 'assets/$location/$key.$extension';
	}

	public static function image(key:String/* , forceLoadFromDisk:Bool = false */, ?location:String):Dynamic
	{
		return file(key, '$location/images', 'png');
	}

	public static function xml(key:String, ?location:String = 'images')
	{
		return file(key, location, 'xml');
	}

	public static function text(key:String, ?location:String = 'data')
	{
		return file(key, location, 'txt');
	}

	public static function json(key:String, ?location:String = 'data')
	{
		return file(key, location, 'json');
	}

	public static function sound(key:String)
	{
		return file(key, 'sounds', 'ogg');
	}

	public static function music(key:String)
	{
		return file(key, 'music', 'ogg');
	}

	public static function song(song:String, type:String = 'Inst', diff:String = 'NORMAL'):String
	{
		song = song.toLowerCase();
		diff = diff.toLowerCase();
		
		var formatSong = '$song/$type';
		if (Assets.exists('$formatSong-$diff.ogg')) formatSong += '-$diff';

		return file(formatSong, 'songs', 'ogg');
	}

	public static function getSparrowAtlas(key:String, ?location:String)
	{
		var imageKey = {name: key, directory: '$location/images'};
		return FlxAtlasFrames.fromSparrow(image(imageKey.name), xml(imageKey.name, imageKey.directory));
	}

	public static function getPackerAtlas(key:String, ?location:String)
	{
		var imageKey = {name: key, directory: '$location/images'};
		return FlxAtlasFrames.fromSpriteSheetPacker(image(imageKey.name), text(imageKey.name, imageKey.directory));
	}

	public static function video(key:String)
	{
		return file(key, "videos", "mp4");
	}

	public static function font(key:String, ?extension:String = "ttf")
	{
		return file(key, "fonts", extension);
	}
}