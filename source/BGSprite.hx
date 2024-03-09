package;

import flixel.FlxSprite;

/**
 * Basically `FlxSprite` but made to be used on the background stages.
 */
class BGSprite extends FlxSprite
{
	public var idleAnim:String;
	public var normalDance:Bool = true;

	@:allow(Stage)
	private function new(image:String, x:Float = 0, y:Float = 0, scrollX:Float = 1, scrollY:Float = 1, ?daAnimations:Array<String>, ?loopingAnim:Bool = false)
	{
		super(x, y);

		if (daAnimations != null)
		{
			frames = Paths.getSparrowAtlas(image, Stage.stageDirectory);
			for (anim in daAnimations)
			{
				animation.addByPrefix(anim, anim, 24, loopingAnim);
				animation.play(anim);
			}

			Stage.animatedSpritesList.add(this);
		}
		else
		{
			loadGraphic(Paths.image(image, Stage.stageDirectory));
			active = false;
		}

		scrollFactor.set(scrollX, scrollY);
		antialiasing = true;
	}

	@:allow(Stage)
	private function setScale(x:Float, ?y:Null<Float>)
	{
		if (y == null) y = x; // Aspect ratio will be kept if y isn't used

		scale.set(x, y);
		updateHitbox();
	}

	/**
	 * Does sprite animation shit.
	 * 
	 * It's an `Dynamic Function` so you can do:
	 * `stageSpr.dance = function() {}`
	 * 
	 * Btw, if you don't want this to get called forcefully on beat, set `normalDance` to false when overriding
	 */
	@:allow(Stage)
	private dynamic function dance()
	{
		if (idleAnim != null)
			animation.play(idleAnim);
	}
}
