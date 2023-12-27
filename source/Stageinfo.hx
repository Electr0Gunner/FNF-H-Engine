package;

import sys.io.File;
import sys.FileSystem;
import openfl.utils.Assets;
import haxe.Json;
import Song;

typedef StageJson = {
	var defaultZoom:Float;
	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;
}
class StageInfo {


	public static function template():StageJson
	{
		return {
			defaultZoom: 0.9,
			boyfriend: [770, 100],
			girlfriend: [400, 130],
			opponent: [100, 100]
		};
	}


    public static function callStage(stageName:String){
        
    }
}
