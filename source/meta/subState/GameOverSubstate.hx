package meta.subState;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.Conductor.BPMChangeEvent;
import meta.data.Conductor;
import meta.state.*;
import meta.state.menus.*;

class GameOverSubstate extends MusicBeatSubState
{
	var colorScreen:FlxSprite;
	var bf:FlxSprite;
	var daBf:String = '';
	var hans:FlxSprite;
	var bucket:FlxSprite;
	var grpRope:FlxTypedGroup<FlxSprite>;
	var camFollow:FlxObject;
	var stageSuffix:String = "";
	var camZoomStage:Float = PlayState.defaultCamZoom;
	var hansGrab:Bool = false;
	var bucketEvent:Bool = false;
	var soundPlayed:Bool = false;
	var hansTween:Bool = false;
	var catchXPOS:Float = 0;
	var catchXHANS:Float = 0;

	public static var fishHadEnough:Int = 0;

	public function new(x:Float, y:Float)
	{
		switch (PlayState.curSong.toLowerCase())
		{
			case 'doodle-duel':
				daBf = 'BF_ERASED';
			case 'on-ice':
				daBf = 'SPING_DEATH';
			case 'plan-z':
				if (PlayState.ggSponge)
					daBf = 'GGSPONGE_DEATH';
				else
					daBf = 'SPONGE_DEATH';
			default:
				daBf = 'BF_DEATH';
		}
		
		if ((PlayState.curSong.toLowerCase() == 'nuts-and-bolts' || PlayState.curSong.toLowerCase() == 'scrapped-metal') && (!Init.trueSettings.get('Disable Death Lines')))
			fishHadEnough++;

		PlayState.boyfriend.visible = false;

		super();

		Conductor.songPosition = 0;

		if (PlayState.curSong.toLowerCase() == 'nuts-and-bolts'
			|| PlayState.curSong.toLowerCase() == 'scrapped-metal'
			|| PlayState.curSong.toLowerCase() == 'pimpin')
		{
			FlxG.camera.zoom = 1.2;
			hansGrab = true;
		}
		else if (PlayState.curSong.toLowerCase() == 'plan-z')
		{
			FlxG.camera.zoom = 1;
			if (!PlayState.ggSponge)
				bucketEvent = true;
		}

		colorScreen = new FlxSprite(-800, -200).makeGraphic(Std.int(FlxG.width * 5), Std.int(FlxG.height * 5), FlxColor.fromRGB(13, 14, 36));
		add(colorScreen);

		if (PlayState.curSong.toLowerCase() == 'plan-z' && PlayState.ggSponge)
		{
			grpRope = new FlxTypedGroup<FlxSprite>();
			add(grpRope);
			for(i in 0...2)
			{
				var rope:FlxSprite = new FlxSprite(x - 240, y - 900).loadGraphic(Paths.image('gameOver/rope'));
				rope.setGraphicSize(Std.int(rope.width * 0.4));
				rope.x += 60 * i;
				rope.antialiasing = true;
				grpRope.add(rope);
			}
		}

		bf = new FlxSprite(x, y);
		bf.frames = Paths.getSparrowAtlas('characters/' + daBf);
		bf.animation.addByPrefix('firstDeath', "bf death death0", 24, false);
		if (PlayState.ggSponge)
			bf.animation.addByPrefix('deathLoop', "bf death deathloop", 5, true);
		else
			bf.animation.addByPrefix('deathLoop', "bf death deathloop", 24, true);
			bf.animation.addByPrefix('deathConfirm', "bf death retry", 24, false);
		if (bucketEvent)
			bf.animation.addByPrefix('deathWait', "bf death deathWait", 24, true);
		bf.antialiasing = true;
		add(bf);

		if (daBf == 'BF_DEATH')
		{
			bf.setGraphicSize(Std.int(bf.width * 0.4));
			if (PlayState.curSong.toLowerCase() == 'pimpin')
			{
				bf.x -= 300;
				bf.y -= 450;
			}
			else
			{
				bf.x -= 130;
				bf.y -= 320;
			}
			catchXPOS = bf.x;
			hans = new FlxSprite(bf.x, bf.y + 200);
			hans.loadGraphic(Paths.image('gameOver/SB_Patchy_Hand'));
			hans.setGraphicSize(Std.int(hans.width * 0.7));
			catchXHANS = hans.x + 1000;
			hans.antialiasing = true;
			add(hans);
		}
		else if (daBf == 'SPONGE_DEATH')
		{
			bf.x += 90;
			bf.y += 95;
			bucket = new FlxSprite(bf.x - 155, bf.y - 1100);
			bucket.loadGraphic(Paths.image('gameOver/IMG_6539'));
			bucket.setGraphicSize(Std.int(bucket.width * 0.5));
			bucket.antialiasing = true;
			add(bucket);
			FlxTween.tween(bucket, {y: bf.y}, 0.5);
		}
		else if (daBf == 'GGSPONGE_DEATH')
		{
			bf.setGraphicSize(Std.int(bf.width * 0.8));
			bf.x -= 40;
			bf.y -= 80;
		}
		else if (daBf == 'SPING_DEATH')
		{
			bf.x += 210;
			bf.y += 90;
		}

		camFollow = new FlxObject(bf.getGraphicMidpoint().x + 20, bf.getGraphicMidpoint().y - 40, 1, 1);
		add(camFollow);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		if (!bucketEvent)
			bf.animation.play('firstDeath', true);
		else
			bf.animation.play('deathWait', true);
		FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		Conductor.changeBPM(75);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);

		#if android
		addVirtualPad(NONE, A_B);
		addPadCamera();
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!Init.trueSettings.get('Disable Death Lines'))
		{
			if (daBf == 'BF_ERASED' && !soundPlayed)
			{
				soundPlayed = true;
				FlxG.sound.play(Paths.soundRandom('doodleDeath', 1, 4), 1);
			}
			else if (PlayState.curSong.toLowerCase() == 'plan-z' && !PlayState.ggSponge && !soundPlayed)
			{
				soundPlayed = true;
				FlxG.sound.play(Paths.soundRandom('planktonDeath', 1, 3), 1);
			}
			else if (PlayState.curSong.toLowerCase() == 'plan-z' && PlayState.ggSponge && !soundPlayed)
			{
				soundPlayed = true;
				FlxG.sound.play(Paths.soundRandom('planktonDeath', 4, 6), 1);
			}
			else if ((PlayState.curSong.toLowerCase() == 'on-ice' || PlayState.curSong.toLowerCase() == 'pimpin') && !soundPlayed)
			{
				soundPlayed = true;
				FlxG.sound.play(Paths.soundRandom('frenchDie', 1, 4), 1);
			}
			else if ((PlayState.curSong.toLowerCase() == 'nuts-and-bolts' || PlayState.curSong.toLowerCase() == 'scrapped-metal')
				&& !soundPlayed)
			{
				if (fishHadEnough % 5 != 0)
				{
					soundPlayed = true;
					FlxG.sound.play(Paths.soundRandom('fishDeath', 1, 6), 1);
				}
				else
				{
					soundPlayed = true;
					FlxG.sound.play(Paths.sound('fishDeathTooMany'), 1);
				}
			}
		}
		
		if (hansGrab)
			bf.x = hans.x + 50;

		if (bucketEvent && bf.animation.curAnim.name != 'deathConfirm' )
		{
			if (bucket.y >= bf.y - 320)
			{
				bf.animation.play('firstDeath', true);
				bucket.visible = false;
				bucketEvent = false;
				FlxG.sound.play(Paths.sound('bucketOn'), 0.9);
			}
		}

		if (controls.ACCEPT)
			endBullshit();

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			ForeverTools.resetMenuMusic();

			if (PlayState.isStoryMode)
			{
				Main.switchState(this, new TitleState());
			}
			else
				Main.switchState(this, new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			bf.animation.play('deathLoop', true);
			if (hansGrab && !hansTween)
				FlxTween.tween(hans, {x: catchXHANS}, 1.5, {ease: FlxEase.sineInOut});
		}

		// if (FlxG.sound.music.playing)
		//	Conductor.songPosition = FlxG.sound.music.time;
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if (PlayState.curSong.toLowerCase() == 'doodle-duel' || (PlayState.curSong.toLowerCase() == 'plan-z' && !PlayState.ggSponge))
				bf.animation.play('deathConfirm', true);

			if (hansGrab)
			{
				FlxTween.cancelTweensOf(hans);
				hans.x = catchXHANS;
				hansTween = true;
				FlxTween.tween(hans, {x: catchXPOS}, 1, {ease:FlxEase.sineInOut, onComplete:function(tween:FlxTween)
				{
					bf.animation.play('deathConfirm', true);
					FlxG.sound.play(Paths.sound('ai'), 1);
					hansGrab = false;
						FlxTween.tween(hans, {x: catchXHANS}, 1, {ease: FlxEase.sineInOut});
						new FlxTimer().start(0.7, function(tmr:FlxTimer)
						{
							FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
							{
								Main.switchState(this, new PlayState());
							});
						});
				}});
			}
			if (daBf == 'SPONGE_DEATH')
				bucket.visible = false;
			else if (daBf == 'GGSPONGE_DEATH')
			{
				FlxTween.tween(bf, {y: bf.y + 200}, 2, {ease:FlxEase.sineIn});
				grpRope.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {y: spr.y + 200}, 2, {ease: FlxEase.sineIn});
				});
			}
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			if (!hansGrab)
			{
				new FlxTimer().start(0.7, function(tmr:FlxTimer)
				{
					FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
					{
						Main.switchState(this, new PlayState());
					});
				});
			}
			//
		}
	}
}
