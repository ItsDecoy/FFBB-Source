package gameObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import meta.state.PlayState;

using StringTools;

class Boyfriend extends Character
{
	public var stunned:Bool = false;

	public function new()
		super(true);

	override function update(elapsed:Float)
	{
		if (!debugMode)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
			{
				if (isAlt)
				{
					if (PlayState.idleAlt)
						playAnim('idle-alt', true, false, 10);
					else
						playAnim('idle', true, false, 10);
				}
				else
					playAnim('idle', true, false, 10);
			}
		}

		super.update(elapsed);
	}

}
