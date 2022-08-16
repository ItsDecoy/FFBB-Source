package meta.subState;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.userInterface.ClassHUD;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.dependency.Discord;
import meta.state.*;
import meta.state.menus.*;

class AchievementGetSubState extends MusicBeatSubState
{
	var iconRPC:String = "";
	var earned:FlxSound;
	var achievementNumber:Int = 0;
    public function new(x:Float, y:Float)
    {
        super();

		earned = new FlxSound().loadEmbedded(Paths.sound('earnedAchievement'));
		earned.play();
		earned.onComplete = changeState;
        
		if (PlayState.curSong == 'on-ice')
		{
			achievementNumber = 2;
			FlxG.save.data.achievement1 = true;
		}
        if (PlayState.curSong == 'nuts-and-bolts')
		{
			achievementNumber = 3;
			FlxG.save.data.achievement2 = true;
		}
		else if (PlayState.curSong == 'doodle-duel')
		{
			achievementNumber = 4;
			FlxG.save.data.achievement3 = true;
		}
		else if (PlayState.curSong == 'plan-z')
		{
			achievementNumber = 5;
			FlxG.save.data.achievement4 = true;
		}
		else if (PlayState.curSong == 'pimpin')
		{
			achievementNumber = 6;
			FlxG.save.data.achievement5 = true;
		}
		else if (PlayState.curSong == 'scrapped-metal')
		{
			achievementNumber = 7;
			FlxG.save.data.achievement6 = true;
		}

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var text:FlxText = new FlxText(0, 50, 'You Earned An Achievement!!!');
		text.setFormat(Paths.font("sponge.otf"), 50, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter(X);
		text.alpha = 0;
		text.antialiasing = true;
		add(text);

        var achievementGrab:FlxSprite = new FlxSprite();
        achievementGrab.loadGraphic(Paths.image('menus/base/achievements/achievementGrid'), true, 160, 160);
        achievementGrab.alpha = 0;
		achievementGrab.setGraphicSize(Std.int(achievementGrab.width * 0.7));
        achievementGrab.screenCenter();
        achievementGrab.antialiasing = true;
        achievementGrab.animation.frameIndex = achievementNumber;
		add(achievementGrab);

		var description:FlxText = new FlxText(0, 580, 'Get 0 misses on '+PlayState.curSong.toLowerCase()+' on the hardest difficulty');
		description.setFormat(Paths.font("sponge.otf"), 25, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		description.screenCenter(X);
		description.alpha = 0;
		description.antialiasing = true;
		add(description);

		FlxTween.tween(bg, {alpha: 0.6}, 0.3);
		FlxTween.tween(text, {alpha: 1}, 0.3);
		FlxTween.tween(achievementGrab, {alpha: 1}, 0.3);
		FlxTween.tween(achievementGrab.scale, {x: 2, y: 2}, 0.5, {ease: FlxEase.backOut, onComplete: function(tween:FlxTween)
		{
				FlxTween.tween(description, {alpha: 1}, 0.6);
		}});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

	function getAchievementName():String
	{
		if (PlayState.curSong.toLowerCase() == 'on-ice')
			return "My Drink";
		else if (PlayState.curSong.toLowerCase() == 'nuts-and-bolts')
			return "Losing Your Head";
		else if (PlayState.curSong.toLowerCase() == 'doodle-duel')
			return "Destroyer Of Evil";
		else if (PlayState.curSong.toLowerCase() == 'plan-z')
			return "All Hail Plankton";
		else if (PlayState.curSong.toLowerCase() == 'pimpin')
			return "Cha Ching";
		else
			return "Mediocre";
	}

	function changeState():Void
	{
		ForeverTools.resetMenuMusic();
		if (PlayState.isStoryMode)
			Main.switchState(this, new TitleState());
		else
			Main.switchState(this, new FreeplayState());
	}
}