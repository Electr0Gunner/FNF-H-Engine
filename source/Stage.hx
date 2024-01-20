package;

import lime.system.BackgroundWorker;
import HScript;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.addons.effects.FlxTrail;
import flixel.FlxBasic;
import flixel.FlxSprite;
import PlayState;
import flixel.group.FlxGroup;

typedef CamPos = {
	var bfCamX:Float;
	var bfCamY:Float;
	var gfCamX:Float;
	var gfCamY:Float;
	var dadCamX:Float;
	var dadCamY:Float;
}

class Stage extends FlxTypedGroup<FlxBasic> {
	//public var curStage:String = '';
    var playStateInstance:PlayState;
	public var isPixel:Bool = false;
	public var offsets:CamPos = {
		bfCamX: 0,
		bfCamY: 0,
		gfCamX: 0,
		gfCamY: 0,
		dadCamX: 0,
		dadCamY: 0,
	}
	public var script:HScript;

    public function new(stageName:String, playStateInstance:PlayState) {
		super(0);
		PlayState.curStage = stageName;
		#if (flixel > "5.0.0")
		if (isPixel == true)
			FlxSprite.defaultAntialiasing = false;
		#end

		script = new HScript('assets/stages/$stageName');
		if (!script.isBlank && script.expr != null) {
			script.interp.scriptObject = playStateInstance;
			script.setValue("add", add);
			script.setValue("insert", insert);
			script.setValue("remove", remove);
			script.setValue("camOffsets", offsets);
			script.setValue("addScript", function(scriptPath:String) {
				playStateInstance.scripts.push(new HScript(scriptPath));
			});
			script.interp.execute(script.expr);
		} else {
			script.setValue("create", function() {
				playStateInstance.defaultCamZoom = 0.9;

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;

				add(stageCurtains);
			});
		}
		script.callFunction("create");

		var addGF:Null<Bool> = script.getValue("addGF");
		if (addGF == null || addGF == false)
			add(playStateInstance.gf);
		var addDad:Null<Bool> = script.getValue("addDad");
		if (addDad == null || addDad == false)
			add(playStateInstance.dad);
		var addBF:Null<Bool> = script.getValue("addBF");
		if (addBF == null || addBF == false)
			add(playStateInstance.boyfriend);

        trace(addBF);

		this.playStateInstance = playStateInstance;

        add(playStateInstance.gf);

		add(playStateInstance.dad);
		add(playStateInstance.boyfriend);
        
    }

    override public function update(elapsed:Float) {
		super.update(elapsed);
		callFromScript("update", [elapsed]);
	}

	public function stepHit(curStep:Int)
		callFromScript("stepHit");

	public function beatHit(curBeat:Int)
		callFromScript("beatHit");

    public function callFromScript(name:String, ?params:Array<Dynamic>) 
        script.callFunction(name, params);
}