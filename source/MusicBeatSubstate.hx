package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState
{
	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;
	function get_controls():Controls
		return PlayerSettings.player1.controls;
	
	public function new()
	{
		#if flash openfl.system.System.gc(); #end
		
		super();
	}

	override function update(elapsed:Float)
	{
		var oldStep:Int = curStep;

		updateStep();
		updateBeat();

		if (oldStep != curStep && curStep >= 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}
	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}
