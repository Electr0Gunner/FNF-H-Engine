package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var stage:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	public var showGF:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var separtedVocals:Bool = false;
	public var showGF:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:Null<String>):SwagSong
	{
		jsonInput = jsonInput.toLowerCase();
		if (folder == null) folder = jsonInput;
		// Can't really think of a way to check for this -BerGP
		if (folder.endsWith('-easy') || folder.endsWith('-hard')) folder = folder.substring(0, folder.lastIndexOf('-'));
		folder = folder.toLowerCase();

		var rawJson = Assets.getText(Paths.json(jsonInput, 'data/$folder')).trim();
		// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
