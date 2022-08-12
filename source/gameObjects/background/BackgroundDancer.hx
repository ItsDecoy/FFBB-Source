package gameObjects.background;

import flixel.graphics.frames.FlxAtlasFrames;
import meta.data.dependency.FNFSprite;

class BackgroundDancer extends FNFSprite
{
	public function new(x:Float, y:Float, sprite:String, width:Int, height:Int)
	{
		super(x, y);
		
		loadGraphic(Paths.image("backgrounds/KK/"+sprite), true, width, height);
		animation.add('dance', [0,1,2,3], 12, false);
		animation.play('dance');
		antialiasing = true;
	}

	public function dance():Void
	{
		animation.play('dance');
	}
}
