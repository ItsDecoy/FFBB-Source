package gameObjects.userInterface;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

class SpatulaHUD extends FlxTypedGroup<FlxBasic>
{
    public var spatula:FlxSprite;
    var spatulaCount:FlxText;

    public function new(x:Float, y:Float)
    {
		super();

        spatula = new FlxSprite(x, y).loadGraphic(Paths.image('UI/default/base/goldenSpatula'));
		spatula.scrollFactor.set();
		spatula.antialiasing = true;
		add(spatula);

		spatulaCount = new FlxText();
		spatulaCount.setFormat(Paths.font("sponge.otf"), 55, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		spatulaCount.scrollFactor.set();
		spatulaCount.antialiasing = true;
		add(spatulaCount);
    }

    override public function update(elasped:Float)
    {
		super.update(elasped);

        spatulaCount.text = outputSpatCount(FlxG.save.data.spat);
		spatulaCount.alpha = spatula.alpha;
		spatulaCount.y = spatula.getGraphicMidpoint().y - 38;
		spatulaCount.x = spatula.getGraphicMidpoint().x + 55;
    }

    public function saveSpatCount(count:Int)
	{
		FlxG.save.data.spat = count;
		FlxG.save.flush();
	}

	public function outputSpatCount(count:Int):String
	{
		var amount:String = Std.string(count);
		return amount;
	}
}