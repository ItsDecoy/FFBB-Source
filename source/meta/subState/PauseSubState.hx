package meta.subState;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.*;
import gameObjects.userInterface.SpatulaHUD;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.*;
import meta.state.*;
import meta.state.menus.*;

class PauseSubState extends MusicBeatSubState
{
	var grpMenuShit:FlxTypedGroup<FlxText>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Practice Mode', 'Exit to menu'];
	var menuItemsToggle:Array<String> = ['Resume', 'Exit Practice Mode', 'Go To Start', 'Scroll Speed', 'Exit to menu'];
	var curSelected:Int = 0;
	var bg:FlxSprite;
	var splash:FlxSprite;
	var levelInfo:FlxText;
	var goldenSpatula:FlxSprite;
	var levelDifficulty:FlxText;
	var scoreText:FlxText;
	var scrollControl:FlxText;
	var shinies:FlxSprite;
	var spatCount:SpatulaHUD;
	var frame:FlxSprite;
	public static var scrollSpeedSelect:Bool = false;
	public static var scrollSpeed:Float = 1;

	var bg2:FlxSprite;
	var scrollText:FlxText;

	var bubbles:FlxTypedGroup<FlxEmitter>;
	var bubbleEffect:FlxTypedGroup<FlxSprite>;

	var transitionBG:FlxSprite;
	var loading:FlxText;

	var pauseMusic:FlxSound;
	var squeakSound:Int = 1;

	var finishedTween:Bool = false;
	var onTween:Bool = false;
	var selectedSomething:Bool = false;

	public function new(x:Float, y:Float)
	{
		super();

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().loadGraphic(Paths.image('menus/base/pause/sand'));
		bg.alpha = 0;
		bg.scrollFactor.set();
		bg.setGraphicSize(Std.int(bg.width * 1.8));
		bg.screenCenter();
		bg.scale.x = 2.3;
		bg.antialiasing = true;
		add(bg);

		splash = new FlxSprite().loadGraphic(Paths.image('menus/base/pause/PauseSplash'));
		splash.alpha = 0;
		splash.scrollFactor.set();
		splash.screenCenter();
		splash.antialiasing = true;
		add(splash);

		levelInfo = new FlxText(0, 180, 0, "", 32);
		levelInfo.text += CoolUtil.dashToSpace(PlayState.SONG.song);
		levelInfo.alpha = 0;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font('sponge.otf'), 45, FlxColor.fromRGB(0, 71, 88), CENTER);
		levelInfo.screenCenter(X);
		levelInfo.antialiasing = true;
		add(levelInfo);

		goldenSpatula = new FlxSprite(0, 255);
		if ((PlayState.curSong.toLowerCase() == 'doodle-duel' && !FlxG.save.data.doodleComplete)
			|| (PlayState.curSong.toLowerCase() == 'plan-z' && !FlxG.save.data.neptuneComplete)
			|| (PlayState.curSong.toLowerCase() == 'pimpin' && !FlxG.save.data.pimpbobComplete)
			|| (PlayState.curSong.toLowerCase() == 'scrapped-metal' && !FlxG.save.data.squidComplete)
			|| (PlayState.curSong.toLowerCase() == 'on-ice' && !FlxG.save.data.drinkComplete)
			|| (PlayState.curSong.toLowerCase() == 'nuts-and-bolts' && !FlxG.save.data.storyComplete))
			goldenSpatula.loadGraphic(Paths.image("UI/default/base/goldenSpatulaNotEarned"));
		else if ((PlayState.curSong.toLowerCase() == 'doodle-duel' && FlxG.save.data.doodleComplete)
			|| (PlayState.curSong.toLowerCase() == 'plan-z' && FlxG.save.data.neptuneComplete)
			|| (PlayState.curSong.toLowerCase() == 'pimpin' && FlxG.save.data.pimpbobComplete)
			|| (PlayState.curSong.toLowerCase() == 'scrapped-metal' && FlxG.save.data.squidComplete)
			|| (PlayState.curSong.toLowerCase() == 'on-ice' && FlxG.save.data.drinkComplete)
			|| (PlayState.curSong.toLowerCase() == 'nuts-and-bolts' && FlxG.save.data.storyComplete))
			goldenSpatula.loadGraphic(Paths.image("UI/default/base/goldenSpatula"));
		goldenSpatula.screenCenter(X);
		goldenSpatula.alpha = 0;
		goldenSpatula.setGraphicSize(Std.int(goldenSpatula.width * 1.2));
		goldenSpatula.antialiasing = true;
		add(goldenSpatula);

		levelDifficulty = new FlxText(20, 380, 0, "");
		levelDifficulty.text += CoolUtil.difficultyFromNumber(PlayState.storyDifficulty);
		levelDifficulty.alpha = 0;
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('sponge.otf'), 45, FlxColor.fromRGB(0, 71, 88), CENTER);
		levelDifficulty.screenCenter(X);
		levelDifficulty.antialiasing = true;
		add(levelDifficulty);

		if (PlayState.practiceMode)
			menuItems = menuItemsToggle;

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:FlxText = new FlxText(770, 455, menuItems[i]);
			songText.setFormat(Paths.font('sponge.otf'), 25, FlxColor.fromRGB(0, 71, 88), CENTER);
			songText.x -= 80 * i;
			songText.alpha = 0;
			if (menuItems == menuItemsToggle)
				songText.y += 30 * i;
			else
				songText.y += 40 * i;
			songText.ID = i;
			songText.antialiasing = true;
			grpMenuShit.add(songText);
		}

		scoreText = new FlxText(0, 100, Std.string(PlayState.songScore));
		scoreText.setFormat(Paths.font('sponge.otf'), 40, FlxColor.YELLOW, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.alpha = 0;
		scoreText.antialiasing = true;
		add(scoreText);

		shinies = new FlxSprite(0, scoreText.getGraphicMidpoint().y - 40).loadGraphic(Paths.image("UI/default/base/shinies"));
		shinies.setGraphicSize(Std.int(shinies.width * 0.55));
		shinies.alpha = 0;
		shinies.antialiasing = true;
		add(shinies);

		spatCount = new SpatulaHUD(130, scoreText.getGraphicMidpoint().y - 25);
		spatCount.spatula.alpha = 0;
		add(spatCount);

		frame = new FlxSprite().loadGraphic(Paths.image('menus/base/pause/BambooFrame'));
		frame.screenCenter();
		frame.alpha = 0;
		frame.antialiasing = true;
		add(frame);

		FlxTween.tween(bg, {alpha: 1}, 0.4, {ease: FlxEase.quadInOut, onComplete: function(tween:FlxTween)
		{
			finishedTween = true;
		}});
		FlxTween.tween(splash, {alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
		FlxTween.tween(goldenSpatula, {alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
		FlxTween.tween(scoreText, {alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
		FlxTween.tween(shinies, {alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
		FlxTween.tween(levelInfo, {alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
		FlxTween.tween(levelDifficulty, {alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
		FlxTween.tween(spatCount.spatula, {alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
		FlxTween.tween(frame, {alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
		grpMenuShit.forEach(function(txt:FlxText)
		{
			if (curSelected == txt.ID)
				FlxTween.tween(txt, {alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
			else
				FlxTween.tween(txt, {alpha: 0.6}, 0.4, {ease: FlxEase.quadInOut});
		});

		bubbles = new FlxTypedGroup<FlxEmitter>();

		for (i in 0...5)
		{
			var bubbleRise:FlxEmitter = new FlxEmitter(-1000, 850);
			bubbleRise.launchMode = FlxEmitterMode.SQUARE;
			bubbleRise.velocity.set(-50, -150, 50, -550, -100, 0, 100, -100);
			bubbleRise.scale.set(0.6, 0.6, 1.2, 1, 0.6, 0.6, 0.9, 0.8);
			bubbleRise.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
			bubbleRise.width = 4000;
			bubbleRise.alpha.set(1, 1, 0, 0);
			bubbleRise.lifespan.set(3, 5);
			bubbleRise.loadParticles(Paths.image('particles/BubbleHit' + i), 500, 16, true);

			bubbleRise.start(false, FlxG.random.float(0.35, 0.4), 1000000);
			bubbles.add(bubbleRise);
		}
		add(bubbles);

		bg2 = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg2.alpha = 0;
		bg2.screenCenter();
		bg2.scrollFactor.set();
		add(bg2);

		scrollText = new FlxText();
		scrollText.setFormat(Paths.font("sponge.otf"), 150, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scrollText.alpha = 0;
		add(scrollText);

		scrollControl = new FlxText(0, 40, "Use The UP And DOWN Arrows \nTo Choose A New Scroll Speed\nPress Your Back Button To Exit\n");
		scrollControl.setFormat(Paths.font("sponge.otf"), 45, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scrollControl.screenCenter(X);
		scrollControl.antialiasing = true;
		scrollControl.alpha = 0;
		FlxTween.tween(scrollControl, {y: 33}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG});
		add(scrollControl);

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

		#if android
		addVirtualPad(UP_DOWN, A_B);
		addPadCamera();
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		scrollText.screenCenter();

		if (scrollSpeed < 1)
			scrollSpeed = 1;
		if (scrollSpeed > PlayState.speed)
			scrollSpeed = PlayState.speed;

		scrollText.text = Std.string(scrollSpeed);

		if (squeakSound > 2)
			squeakSound = 1;

		scoreText.x = (FlxG.width * 0.85) - scoreText.width;
		shinies.x = ((FlxG.width * 0.789) - scoreText.width) - 10;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (finishedTween)
		{
			if (upP && !scrollSpeedSelect && !selectedSomething && !onTween)
				changeSelection(-1);
			else if (upP && scrollSpeedSelect && !selectedSomething && !onTween)
			{
				FlxG.sound.play(Paths.sound('squeak' + squeakSound), 0.7);
				squeakSound++;
				scrollSpeed = scrollSpeed + 0.1;
			}
			if (downP && !scrollSpeedSelect && !selectedSomething && !onTween)
				changeSelection(1);
			else if (downP && scrollSpeedSelect && !selectedSomething && !onTween)
			{
				FlxG.sound.play(Paths.sound('squeak' + squeakSound), 0.7);
				squeakSound++;
				scrollSpeed = scrollSpeed - 0.1;
			}

			if (accepted && !selectedSomething && !onTween)
			{
				if (!scrollSpeedSelect)
				{					
					var daSelected:String = menuItems[curSelected];

					switch (daSelected)
					{
						case "Resume":
							selectedSomething = true;
							fadeOut();
						case "Restart Song":
							selectedSomething = true;
							transition(false, false);
						case "Exit Practice Mode":
							selectedSomething = true;
							PlayState.practiceMode = false;
							PlayState.SONG.speed = PlayState.speed;
							transition(false, false);
						case "Practice Mode":
							selectedSomething = true;
							PlayState.practiceMode = true;
							scrollSpeed = PlayState.speed;
							fadeOut();
						case "Go To Start":
							selectedSomething = true;
							transition(false, true);
						case "Scroll Speed":
							trace(PlayState.speed);
							scrollSpeedSelect = true;
							onTween = true;
							FlxTween.tween(bg2, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
							FlxTween.tween(scrollControl, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});
							FlxTween.tween(scrollText, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, onComplete: function(tween:FlxTween)
							{
								onTween = false;
							}});
						case "Exit to menu":
							selectedSomething = true;
							PlayState.practiceMode = false;
							transition(true, false);
					}
				}
				else
				{
					PlayState.SONG.speed = scrollSpeed;
					scrollSpeedSelect = false;
					selectedSomething = true;
					transition(false, false);
				}
			}

			if (controls.BACK && scrollSpeedSelect && !onTween && !selectedSomething)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				scrollSpeedSelect = false;
				onTween = true;
				FlxTween.tween(bg2, {alpha: 0}, 0.4, {ease: FlxEase.sineOut});
				FlxTween.tween(scrollControl, {alpha: 0}, 0.4, {ease: FlxEase.sineOut});
				FlxTween.tween(scrollText, {alpha: 0}, 0.4, {ease: FlxEase.sineOut, onComplete: function(tween:FlxTween)
				{
					onTween = false;
				}});
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}

		#if debug
		// trace('music volume increased');
		#end

		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('squeak' + squeakSound), 0.7);
		squeakSound++;

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		for (item in grpMenuShit.members)
		{
			item.alpha = 0.6;

			if (item.ID == curSelected)
				item.alpha = 1;
		}

		#if debug
		// trace('finished selection');
		#end
		//
	}

	function transition(isMainMenu:Bool, quickReset:Bool)
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
			{
				if (!quickReset)
					Main.switchState(this, new PlayState());
				else
					FlxG.switchState(new PlayState());
			}
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

	function fadeOut()
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		grpMenuShit.forEach(function(txt:FlxText)
		{
			if (curSelected == txt.ID)
				FlxTween.tween(txt, {alpha: 0}, 0.5, {ease: FlxEase.sineOut});
			else
				FlxTween.tween(txt, {alpha: 0}, 0.5, {ease: FlxEase.sineOut});
		});
		FlxTween.tween(bg, {alpha: 0}, 0.55, {ease: FlxEase.sineOut});
		FlxTween.tween(splash, {alpha: 0}, 0.55, {ease: FlxEase.sineOut});
		FlxTween.tween(goldenSpatula, {alpha: 0}, 0.55, {ease: FlxEase.sineOut});
		FlxTween.tween(scoreText, {alpha: 0}, 0.55, {ease: FlxEase.sineOut});
		FlxTween.tween(shinies, {alpha: 0}, 0.55, {ease: FlxEase.sineOut});
		FlxTween.tween(levelInfo, {alpha: 0}, 0.55, {ease: FlxEase.sineOut});
		FlxTween.tween(levelDifficulty, {alpha: 0}, 0.55, {ease: FlxEase.sineOut});
		FlxTween.tween(frame, {alpha: 0}, 0.55, {ease: FlxEase.sineOut});
		FlxTween.tween(spatCount.spatula, {alpha: 0}, 0.55, {ease: FlxEase.sineOut, onComplete: function(tween:FlxTween)
		{
			close();
		}});
	}
}
