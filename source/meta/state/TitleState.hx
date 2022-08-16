package meta.state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.effects.particles.FlxEmitter;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.SpatulaHUD;
import lime.app.Application;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.dependency.Discord;
import meta.state.menus.*;
import meta.subState.GameOverSubstate;
import openfl.Assets;

using StringTools;

/**
	I hate this state so much that I gave up after trying to rewrite it 3 times and just copy pasted the original code
	with like minor edits so it actually runs in forever engine. I'll redo this later, I've said that like 12 times now

	I genuinely fucking hate this code no offense ninjamuffin I just dont like it and I don't know why or how I should rewrite it
**/
class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;
	static var isMainMenu:Bool = false;
	static var startRandom:Bool = false;

	var warningText:FlxSprite;
	var black:FlxSprite;
	var warningSkip:Bool = false;

	var heavy:FlxSprite;
	var logoBl:FlxSprite;
	var spongeDance:FlxSprite;
	var menuBFGF:FlxSprite;
	var island:FlxSprite;
	var pineapple:FlxSprite;
	var danceLeft:Bool = false;
	var enterText:FlxText;
	var foreverText:FlxSprite;
	var tribute:FlxSprite;
	var bubbles:FlxSprite;
	var spatulaHUD:SpatulaHUD;
	var transitionBG:FlxSprite;
	var loading:FlxText;
	var diffText:FlxText;

	var particles:FlxTypedGroup<FlxEmitter>;
	var bubbleEffect:FlxTypedGroup<FlxSprite>;

	public static var titleImage:String = "";

	var squeakSound:Int = 1;

	var reverseAnim:Bool = false;
	var notLoopIsland:Bool = true;
	var fading:Bool = false;
	var bubblesDone:Bool = false;

	var optionShit:Array<String> = ['story mode', 'freeplay', 'options', 'achievements', 'credits'];
	var existingDifficulties:Array<String> = [];
	var menuItems:FlxTypedGroup<FlxSprite>;
	static var curSelected:Float = 0;
	static var curDifficulty:Int = 1;

	override public function create():Void
	{
		FlxG.mouse.visible = false;
		FlxG.mouse.enabled = false;
		FlxG.mouse.useSystemCursor = false;
		controls.setKeyboardScheme(None, false);
		titleImage = "freaky";
		super.create();

		persistentUpdate = true;

		GameOverSubstate.fishHadEnough = 0;

		for (i in CoolUtil.difficultyArray)
			existingDifficulties.push(i);

		pineapple = new FlxSprite().loadGraphic(Paths.image('menus/base/titleandmainmenu/mainmenuBG'));
		pineapple.setGraphicSize(Std.int(pineapple.width * 1.05));
		pineapple.antialiasing = true;
		pineapple.screenCenter();
		pineapple.y += 712*1.5;
		add(pineapple);

		spongeDance = new FlxSprite();
		spongeDance.frames = Paths.getSparrowAtlas('menus/base/titleandmainmenu/SPONGEHANDS');
		spongeDance.animation.addByPrefix('danceLeft', 'SB_DOUBLETIME0', 12, false);
		spongeDance.animation.addByPrefix('danceRight', 'SB_DOUBLETIMECHANGE', 12, false);
		spongeDance.antialiasing = true;
		add(spongeDance);

		menuBFGF = new FlxSprite(-130, -15);
		menuBFGF.loadGraphic(Paths.image('menus/base/titleandmainmenu/menuBFGF'), true, 975, 777);
		menuBFGF.animation.add('dance', [0,1,2,3,4,5], 12, false);
		menuBFGF.scrollFactor.set();
		menuBFGF.visible = false;
		menuBFGF.antialiasing = true;
		add(menuBFGF);

		island = new FlxSprite();
		island.loadGraphic(Paths.image('menus/base/titleandmainmenu/island'), true, 1272, 712);
		island.animation.add('loop', [0,1,2,3,4,5], 12, false);
		island.animation.add('loopReverse', [6,5,4,3,2,1], 12, false);
		island.animation.add('transition', [7,8,9,10,11,12,13,14,15,16,17], 30, false);
		island.animation.play('loop');
		island.setGraphicSize(Std.int(island.width * 1.05));
		island.antialiasing = true;
		island.screenCenter();
		add(island);

		heavy = new FlxSprite().loadGraphic(Paths.image('menus/base/titleandmainmenu/originalBy'));
		heavy.screenCenter();
		heavy.antialiasing = true;
		heavy.alpha = 0;
		add(heavy);

		foreverText = new FlxSprite().loadGraphic(Paths.image('menus/base/titleandmainmenu/forever'));
		foreverText.screenCenter();
		foreverText.antialiasing = true;
		foreverText.setGraphicSize(Std.int(foreverText.width * 1.2));
		foreverText.alpha = 0;
		add(foreverText);

		tribute = new FlxSprite().loadGraphic(Paths.image('menus/base/titleandmainmenu/tribute'));
		tribute.screenCenter();
		tribute.antialiasing = true;
		tribute.setGraphicSize(Std.int(tribute.width * 1.1));
		tribute.alpha = 0;
		add(tribute);

		bubbles = new FlxSprite();
		bubbles.loadGraphic(Paths.image('menus/base/titleandmainmenu/bubbles'), true, 1284, 724);
		bubbles.animation.add('rise', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], 30, false);
		bubbles.screenCenter();
		bubbles.visible = false;
		bubbles.antialiasing = true;
		add(bubbles);

		particles = new FlxTypedGroup<FlxEmitter>();

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
			particles.add(bubbleRise);
		}
		particles.visible = false;
		add(particles);

		logoBl = new FlxSprite().loadGraphic(Paths.image('menus/base/titleandmainmenu/icon'));
		logoBl.antialiasing = true;
		logoBl.scrollFactor.set();
		logoBl.screenCenter(Y);
		logoBl.x += 520;
		logoBl.visible = false;
		add(logoBl);

		enterText = new FlxText(0, 0, 'Press ENTER To Start');
		enterText.setFormat(Paths.font("sponge.otf"), 25, FlxColor.GREEN, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		enterText.scrollFactor.set();
		enterText.y += 650;
		enterText.x = logoBl.getGraphicMidpoint().x - (enterText.width - (enterText.width / 2));
		enterText.antialiasing = true;
		enterText.visible = false;
		add(enterText);

		menuItems = new FlxTypedGroup<FlxSprite>();

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(1300, 0 + (i * 142));
			menuItem.loadGraphic(Paths.image('menus/base/titleandmainmenu/menuSelection'), true, 453, 147);
			menuItem.animation.frameIndex = i;
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}
		add(menuItems);

		diffText = new FlxText(0, 42, 0, '<' + Std.string(existingDifficulties[curDifficulty]) + '>');
		diffText.setFormat(Paths.font("sponge.otf"), 45, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		diffText.scrollFactor.set();
		diffText.visible = false;
		diffText.antialiasing = true;
		add(diffText);

		spatulaHUD = new SpatulaHUD(0, -150);
		add(spatulaHUD);

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

		updateSelection();

		if (isMainMenu && initialized)
			backToMain();
		else
		{
			initialized = true;
			if (FlxG.save.data.firstLaunch == null)
			{
				ForeverTools.createSaveData();
				warning();
			}
			else
				startIntro();
		}
	}

	function startIntro()
	{
		ForeverTools.resetMenuMusic(true);
		FlxG.camera.fade(FlxColor.BLACK, 3, true);
		warningSkip = true;
	}

	var transitioning:Bool = false;
	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (island.animation.curAnim.name != 'transition')
		{
			if (island.animation.curAnim.finished && notLoopIsland)
			{
				reverseAnim = !reverseAnim;
				if (reverseAnim)
					island.animation.play('loopReverse', true);
				else
					island.animation.play('loop', true);
			}
		}
		else
			notLoopIsland = false;

		if (island.animation.curAnim.name == 'transition' && island.animation.curAnim.finished && !bubblesDone)
		{
			if (bubbles != null)
			{
				bubblesDone = true;
				bubbles.animation.play('rise');
				bubbles.visible = true;
			}
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
		var accepted = controls.ACCEPT;

		spongeDance.y = pineapple.getGraphicMidpoint().y + 1040;
		spongeDance.x = pineapple.getGraphicMidpoint().x - 500;

		logoBl.scale.x = FlxMath.lerp(1.18, logoBl.scale.x, 0.80);
		logoBl.scale.y = FlxMath.lerp(1.18, logoBl.scale.y, 0.80);

		enterText.scale.x = FlxMath.lerp(1, enterText.scale.x, 0.95);
		enterText.scale.y = FlxMath.lerp(1, enterText.scale.y, 0.95);

		if (!selectedSomethin && isMainMenu)
		{
			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected == 0)
				{
					diffText.visible = true;
					if (controls.UI_LEFT_P)
						changeDiff(1);
					if (controls.UI_RIGHT_P)
						changeDiff(-1);
				}
				else
				 diffText.visible = false;
			});
		}

		if (selectedSomethin)
		{
			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected == spr.ID)
				{
					spr.scale.x = FlxMath.lerp(1.05, spr.scale.x, 0.9);
					spr.scale.y = FlxMath.lerp(1.05, spr.scale.y, 0.9);
				}
			});
		}

		#if android
		for (touch in FlxG.touches.list)
			if (touch.justPressed)
				pressedEnter = true;
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro && !isMainMenu)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			enterText.scale.x = 0.8;
			enterText.scale.y = 0.8;
			FlxTween.tween(enterText, {alpha: 0}, 1, {onComplete: function(tween:FlxTween)
			{
				mainMenuSwitch();
			}});

			transitioning = true;
		}

		// hi game, please stop crashing its kinda annoyin, thanks!
		if (pressedEnter && FlxG.save.data.skipable && !skippedIntro && initialized && warningSkip && !isMainMenu)
		{
			skipIntro();
		}

		if (accepted && skippedIntro && isMainMenu && !selectedSomethin)
		{
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected == spr.ID)
				{
					spr.scale.x = 1.1;
					spr.scale.y = 1.1;
					FlxTween.tween(spr, {alpha: 0}, 0.5, {ease: FlxEase.sineOut, startDelay: 0.5, onComplete: function(tween:FlxTween)
					{
							var daChoice:String = optionShit[Math.floor(curSelected)];

							switch (daChoice)
							{
								case 'story mode':
									transition();
								case 'freeplay':
									Main.switchState(this, new FreeplayState());
								case 'options':
									transIn = FlxTransitionableState.defaultTransIn;
									transOut = FlxTransitionableState.defaultTransOut;
									Main.switchState(this, new OptionsMenuState());
								case 'achievements':
									Main.switchState(this, new AchievementsState());
								case 'credits':
									Main.switchState(this, new CreditState());
							}
					}});
				}
				else
				{
					FlxTween.tween(spr, {alpha: 0}, 0.5, {ease: FlxEase.sineOut});
				}
			});
		}

		if (FlxG.keys.justPressed.ESCAPE && !warningSkip && !isMainMenu && !fading)
		{
			fading = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.tween(warningText, {alpha: 0}, 1, {onComplete: function(tween:FlxTween)
			{
				FlxG.save.data.firstLaunch = true;
				startIntro();
				black.destroy();
			}});
		}

		if (pressedEnter && !warningSkip && !isMainMenu && !fading)
		{
			fading = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTween.tween(warningText, {alpha: 0}, 1, {
				onComplete: function(tween:FlxTween)
				{
					FlxG.save.data.firstLaunch = true;
					Main.switchState(this, new OptionsMenuState());
				}
			});
		}

		var up = controls.UP;
		var down = controls.DOWN;
		var up_p = controls.UI_UP_P;
		var down_p = controls.UI_DOWN_P;
		var controlArray:Array<Bool> = [up, down, up_p, down_p];

		if ((controlArray.contains(true)) && (!selectedSomethin) && (isMainMenu))
		{
			for (i in 0...controlArray.length)
			{
				if (controlArray[i] == true)
				{
					if (i > 1)
					{
						if (i == 2)
							curSelected--;
						else if (i == 3)
							curSelected++;

						FlxG.sound.play(Paths.sound('squeak' + squeakSound), 0.7);
						squeakSound++;
					}
					if (curSelected < 0)
						curSelected = optionShit.length - 1;
					else if (curSelected >= optionShit.length)
						curSelected = 0;
				}
			}
		}

		if (Math.floor(curSelected) != lastCurSelected)
			updateSelection();

		super.update(elapsed);
		
		diffText.x = (menuItems.members[0].x + 10) - diffText.width;
		diffText.alpha = menuItems.members[0].alpha;

		if (squeakSound > 2)
			squeakSound = 1;
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.scale.x = 1.28;
		logoBl.scale.y = 1.28;

		danceLeft = !danceLeft;

		if (danceLeft)
		{
			spongeDance.animation.play('danceRight', true);
			menuBFGF.animation.play('dance');
		}
		else
		{
			spongeDance.animation.play('danceLeft', true);
			menuBFGF.animation.play('dance');
		}

		FlxG.log.add(curBeat);

		if (!skippedIntro)
		{
			switch (curBeat)
			{
				case 2:
					FlxTween.tween(heavy, {alpha: 1}, 1, {ease: FlxEase.sineOut});
				case 4:
					FlxTween.tween(heavy, {alpha: 0}, 1, {ease: FlxEase.sineOut});
				case 6:
					FlxTween.tween(foreverText, {alpha: 1}, 1, {ease: FlxEase.sineOut});
				case 8:
					FlxTween.tween(foreverText, {alpha: 0}, 1, {ease: FlxEase.sineOut});
				case 10:
					FlxTween.tween(tribute, {alpha: 1}, 1, {ease: FlxEase.sineOut});
				case 12:
					FlxTween.tween(tribute, {alpha: 0}, 1, {ease: FlxEase.sineOut});
				case 14:
					island.animation.play('transition', true);
					FlxTween.tween(island, {y: -1500}, 0.7, {ease: FlxEase.sineIn});
					FlxTween.tween(pineapple, {y: -1920}, 1.2, {ease: FlxEase.sineInOut});
				case 16:
					skipIntro();
			}
		}
		}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			skippedIntro = true;
			FlxG.save.data.skipable = true;
			if (!Init.trueSettings.get('Disable Flashing Lights'))
				FlxG.camera.flash(FlxColor.WHITE, 4);
			else
				FlxG.camera.flash(FlxColor.BLACK, 4);
			particles.visible = true;
			logoBl.visible = true;
			heavy.visible = false;
			foreverText.visible = false;
			tribute.visible = false;
			enterText.visible = true;
			bubbles.destroy();
			FlxTween.cancelTweensOf(island);
			FlxTween.cancelTweensOf(pineapple);
			island.y = -1500;
			pineapple.y = -1920;
		}
	}

	function warning()
	{
		black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(black);

		warningText = new FlxSprite().loadGraphic(Paths.image('menus/base/titleandmainmenu/Warning'));
		warningText.setGraphicSize(Std.int(warningText.width * 1.3));
		warningText.antialiasing = true;
		warningText.screenCenter();
		add(warningText);

		#if android
		addVirtualPad(NONE, B);
		#end
	}

	function mainMenuSwitch()
	{
		FlxTween.tween(logoBl, {y: -1000}, 1.2, {ease: FlxEase.backIn, onComplete: function(tween:FlxTween)
		{
			menuItems.forEach(function (spr:FlxSprite)
			{
					FlxTween.tween(spatulaHUD.spatula, {y: 0}, 0.6, {ease: FlxEase.smootherStepOut});
					FlxTween.tween(spr, {x: 800}, 0.6, {ease: FlxEase.smootherStepOut, onComplete: function(tween:FlxTween)
					{
						isMainMenu = true;
						persistentUpdate = persistentDraw = true;
					}});
			});
		}});

		#if android
		addVirtualPad(LEFT_FULL, A);
		#end
	}

	var lastCurSelected:Int = 0;

	private function updateSelection()
	{
		menuItems.forEach(function(spr:FlxSprite)
		{
			if (curSelected == spr.ID)
			{
				spr.scale.x = 1.05;
				spr.scale.y = 1.05;
			}
			else
			{
				spr.scale.x = 1;
				spr.scale.y = 1;
			}
		});

		lastCurSelected = Math.floor(curSelected);
	}

	private function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty > existingDifficulties.length - 1)
			curDifficulty = 0;
		if (curDifficulty < 0)
			curDifficulty = existingDifficulties.length - 1;

		diffText.text = '<' + Std.string(existingDifficulties[curDifficulty]) + '>';
	}

	function backToMain()
	{
		persistentUpdate = persistentDraw = true;
		skippedIntro = true;
		particles.visible = true;
		logoBl.visible = false;
		heavy.visible = false;
		foreverText.visible = false;
		tribute.visible = false;
		enterText.visible = false;
		bubbles.destroy();
		FlxTween.cancelTweensOf(island);
		FlxTween.cancelTweensOf(pineapple);
		spatulaHUD.spatula.y = 0;
		island.y = -1500;
		pineapple.y = -1920;
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.x = 800;
		});
		if (startRandom)
		{
			var number:Int = FlxG.random.int(0, 1);
			if (number == 0)
			{
				menuBFGF.visible = true;
				spongeDance.visible = false;
			}
			else if (number == 1)
			{
				menuBFGF.visible = false;
				spongeDance.visible = true;
			}
		}
		if (FlxG.save.data.storyComplete && !startRandom)
		{
			menuBFGF.visible = true;
			spongeDance.visible = false;
			startRandom = true;
		}
	}

	function startStory()
	{
		PlayState.storyPlaylist = Main.gameWeeks[1][0].copy();
		PlayState.isStoryMode = true;

		var diffic:String = '-' + CoolUtil.difficultyFromNumber(curDifficulty).toLowerCase();
		diffic = diffic.replace('-normal', '');

		PlayState.storyDifficulty = curDifficulty;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
		PlayState.storyWeek = 1;
		PlayState.campaignScore = 0;
		FlxG.save.data.speedStore = true;
		Main.switchState(this, new PlayState());
	}

	function transition()
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
			startStory();
		});
	}
}