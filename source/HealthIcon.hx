package;

import openfl.Assets;
import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public var curCharacter:String = '';
	var isPlayer:Bool = false;

	public function new(char:String, isPlayer:Bool = false)
	{
		super();

		this.isPlayer = isPlayer;

		changeIcon(char);
		antialiasing = true;
		scrollFactor.set();
	}

	public function changeIcon(newChar:String):Void
	{
		if (newChar != curCharacter)
		{
			if (animation.getByName(newChar) == null)
			{
				var path:String = Paths.image('icons/icon-$newChar');
				if (!Assets.exists(path)) path = Paths.image('icons/icon-face');

				loadGraphic(path, true, 150, 150);
				animation.add(newChar, [0, 1], 0, false, isPlayer);
			}
			animation.play(newChar);
			curCharacter = newChar;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition((sprTracker.x + sprTracker.width) + 10, sprTracker.y - 30);
	}
}
