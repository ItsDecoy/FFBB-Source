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
import flixel.util.FlxTimer;
import gameObjects.userInterface.ClassHUD;
import meta.MusicBeat.MusicBeatSubState;
import meta.state.*;
import meta.state.menus.*;

class PracticeResultSubState extends MusicBeatSubState
{
    var selectItems:Array<String> = ['Yes', 'No', 'Exit To Menu'];
    var curSelected:Int = 0;
	var grpSelection:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	var selectedSomething = false;
    var finishedTween:Bool = false;
	var squeakSound:Int = 1;
	var bubbleEffect:FlxTypedGroup<FlxSprite>;
	var transitionBG:FlxSprite;
	var loading:FlxText;

    public function new(x:Float, y:Float)
    {
        super();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var text:FlxText = new FlxText(0, 80, 'Wanna Play Without Practice?');
        text.setFormat(Paths.font("sponge.otf"), 54, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.screenCenter(X);
        text.antialiasing = true;
        text.alpha = 0;
        FlxTween.tween(text, {y: 73}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG});
        add(text);

		grpSelection = new FlxTypedGroup<FlxText>();
        add(grpSelection);
        for (i in 0...selectItems.length)
        {
			var textGet:FlxText = new FlxText(0, 210 + (i * 100), selectItems[i]);
			textGet.setFormat(Paths.font("sponge.otf"), 85, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			textGet.ID = i;
            textGet.antialiasing = true;
            textGet.alpha = 0;
            grpSelection.add(textGet);
        }

        FlxTween.tween(bg, {alpha: 0.6}, 0.5);
        FlxTween.tween(text, {alpha: 1}, 0.5, {onComplete: function(tween:FlxTween)
        {
			finishedTween = true;
        }});
		grpSelection.forEach(function(txt:FlxText)
		{
			if (curSelected == txt.ID)
			{
				txt.setGraphicSize(Std.int(txt.width * 1.1));
                txt.screenCenter(X);
				FlxTween.tween(txt, {alpha: 1}, 0.5);
			}
			else
			{
				txt.setGraphicSize(Std.int(txt.width * 0.9));
				txt.screenCenter(X);
				FlxTween.tween(txt, {alpha: 0.5}, 0.5);
			}
		});

		ClassHUD.practiceText.destroy();

		transitionBG = new FlxSprite(-85).loadGraphic(Paths.image('menus/base/transition/bgClouds'));
		transitionBG.setGraphicSize(Std.int(transitionBG.width * 2));
		transitionBG.visible = false;
		transitionBG.antialiasing = true;
		transitionBG.scrollFactor.set();
		transitionBG.updateHitbox();
		transitionBG.screenCenter();
		add(transitionBG);

		bubbleEffect = new FlxTypedGroup<FlxSprite>();
		add(bubbleEffect);

		for (i in 0...40)
		{
			var bubble:FlxSprite = new FlxSprite(-10 + (35 * i), 740 + (FlxG.random.int(10, 70) * i) + ((i >= 20) ? -100 : 0));
			bubble.loadGraphic(Paths.image('particles/BubbleTransition'));
			bubble.setGraphicSize(Std.int(bubble.width * FlxG.random.float(0.7, 1.1)));
			bubble.antialiasing = true;
			bubbleEffect.add(bubble);
		}

		loading = new FlxText(FlxG.width * 0.868, FlxG.height - 42, "LOADING.....");
		loading.setFormat(Paths.font("sponge.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loading.scrollFactor.set();
		loading.antialiasing = true;
		loading.visible = false;
		add(loading);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

        FlxG.sound.playMusic(Paths.music('breakfast'), 0);
		FlxG.sound.music.fadeIn(2, 0, 0.7);
		
		#if android
		addVirtualPad(UP_DOWN, A_B);
		#end
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		if (squeakSound > 2)
			squeakSound = 1;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
        if (!selectedSomething)
        {
			if (finishedTween && upP)
		    {
				changeSelection(-1);
				FlxG.sound.play(Paths.sound('squeak' + squeakSound), 0.7);
				squeakSound++;
            }
			if (finishedTween && downP)
		    {
				changeSelection(1);
				FlxG.sound.play(Paths.sound('squeak' + squeakSound), 0.7);
				squeakSound++;
            } 
        }
        if ((controls.ACCEPT) && !selectedSomething)
        {
            FlxG.sound.music.stop();
			selectedSomething = true;
            switch (curSelected)
            {
                case 0:
					PlayState.practiceMode = false;
					PlayState.SONG.speed = PlayState.speed;
					transition(false);
                case 1:
					transition(false);
                case 2:
					PlayState.practiceMode = false;
					PlayState.SONG.speed = PlayState.speed;
					transition(true);
            }
        }
    }

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = selectItems.length - 1;
		if (curSelected >= selectItems.length)
			curSelected = 0;

		grpSelection.forEach(function(txt:FlxText)
		{

			if (curSelected == txt.ID)
			{
                txt.alpha = 1;
				txt.setGraphicSize(Std.int(txt.width * 0.9));
				FlxTween.tween(txt.scale, {x: 1.1, y: 1.1}, 0.2, {ease: FlxEase.sineOut});
            }
            else
            {
			    FlxTween.cancelTweensOf(txt.scale);
				txt.alpha = 0.5;
				txt.setGraphicSize(Std.int(txt.width * 0.9));
            }
		});
	}

	function transition(isMainMenu:Bool)
	{
		transitionBG.visible = true;
		FlxG.sound.play(Paths.sound('transition'), 0.4);
		bubbleEffect.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {y: -100}, FlxG.random.float(0.8, 1.4), {ease: FlxEase.sineIn});
		});
		new FlxTimer().start(1.6, function(tmr:FlxTimer)
		{
			loading.visible = true;
			if (!isMainMenu)
				Main.switchState(this, new PlayState());
			else
			{
				ForeverTools.resetMenuMusic();
				PlayState.resetMusic();
				if (PlayState.isStoryMode)
				{
					Main.switchState(this, new TitleState());
				}
				else
					Main.switchState(this, new FreeplayState());
			}
		});
	}
}