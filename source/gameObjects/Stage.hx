package gameObjects;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.util.FlxColor;
import gameObjects.background.*;
import meta.CoolUtil;
import meta.data.Conductor;
import meta.data.dependency.FNFSprite;
import meta.state.PlayState;

using StringTools;

/**
	This is the stage class. It sets up everything you need for stages in a more organised and clean manner than the
	base game. It's not too bad, just very crowded. I'll be adding stages as a separate
	thing to the weeks, making them not hardcoded to the songs.
**/
class Stage extends FlxTypedGroup<FlxBasic>
{
	var bg:FNFSprite;
	public var bgNote:FNFSprite;

	public var table:FNFSprite;
	public var krabs:FNFSprite;
	public var sandyTail:FNFSprite;
	public var smoke:FNFSprite;

	public var krustyKrabDancersBG:FlxTypedGroup<BackgroundDancer>;
	public var krustyKrabDancersFG:FlxTypedGroup<BackgroundDancer>;

	var fastCar:FNFSprite;

	var upperBoppers:FNFSprite;
	var bottomBoppers:FNFSprite;
	var santa:FNFSprite;

	public var curStage:String;

	var daPixelZoom = PlayState.daPixelZoom;

	public var foreground:FlxTypedGroup<FNFSprite>;
	public var betweenLayers:FlxTypedGroup<FNFSprite>;

	public var gfExist:Bool = true;
	public var doodleBFExist:Bool = true;
	public var smokeFade:Int = 0;

	public function new(curStage)
	{
		super();
		this.curStage = curStage;

		/// get hardcoded stage type if chart is fnf style
		if (PlayState.determinedChartType == "FNF")
		{
			// this is because I want to avoid editing the fnf chart type
			// custom stage stuffs will come with forever charts
			switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
			{
				//finally code something in 🅱️ - Vibe
				case 'plan-z':
					curStage = 'krustykrab';
				case 'doodle-duel':
					curStage = 'doodleBG';
				case 'nuts-and-bolts' | 'icy-destruction':
					curStage = 'poseidome';
				case 'on-ice':
					curStage = 'joke';
				case 'scrapped-metal':
					curStage = 'squid';
				case 'pimpin':
					curStage = 'pimpbob';
			}

			PlayState.curStage = curStage;
		}

		betweenLayers = new FlxTypedGroup<FNFSprite>();
		foreground = new FlxTypedGroup<FNFSprite>();

		switch (curStage)
		{		
			case 'doodleBG':
				PlayState.defaultCamZoom = 0.7;
				var house:FlxSprite = new FlxSprite(-850, 25).loadGraphic(Paths.image('backgrounds/doodlebg/1246_Sem_Titulo_20220501180739'));
				house.setGraphicSize(Std.int(house.width * 1.1));
				add(house);

				smoke = new FNFSprite(-830, 550);
				smoke.loadGraphic(Paths.image('backgrounds/doodlebg/Smoke'), true, 752, 501);
				smoke.animation.add('smoking', [0,1,2], 12, true);
				smoke.animation.play('smoking');
				smoke.antialiasing = true;
				smoke.alpha = 0;
				foreground.add(smoke);

			case 'poseidome':
				PlayState.defaultCamZoom = 0.6;
				bg = new FNFSprite(-300, -150).loadGraphic(Paths.image('backgrounds/poseidome/BG'));
				bg.setGraphicSize(Std.int(bg.width * 1.8));
				bg.antialiasing = true;
				add(bg);

				sandyTail = new FNFSprite(-330, 150);
				sandyTail.loadGraphic(Paths.image('characters/robosandyTail'), true, 650, 630);
				sandyTail.animation.add('loopLeft', [0,1,2,3,4,5,4,3,2,1], 12, true);
				sandyTail.animation.add('loopRight', [6,7,8,9,10,11,10,9,8,7], 12, true);
				sandyTail.setGraphicSize(Std.int(sandyTail.width * 1.05));
				sandyTail.visible = false;
				sandyTail.antialiasing = true;
				add(sandyTail);

				var stageLights:FNFSprite = new FNFSprite(-300, -150).loadGraphic(Paths.image('backgrounds/poseidome/stageLights'));
				stageLights.setGraphicSize(Std.int(stageLights.width * 1.8));
				stageLights.blend = ADD;
				stageLights.antialiasing = true;
				foreground.add(stageLights);

			case 'krustykrab':
				PlayState.defaultCamZoom = 0.6;
				bg = new FNFSprite(-550, -510).loadGraphic(Paths.image('backgrounds/KK/IMG_3471'), true, 2560, 1440);
				bg.antialiasing = true;
				add(bg);

				bgNote = new FNFSprite(-550, -510).loadGraphic(Paths.image('backgrounds/KK/IMG_3471Lights'), true, 2560, 1440);
				bgNote.alpha = 0;
				bgNote.antialiasing = true;
				bgNote.visible = false;
				add(bgNote);

				krabs = new FNFSprite(1300, 370).loadGraphic(Paths.image('backgrounds/KK/FrozenKrabs'));
				krabs.setGraphicSize(Std.int(krabs.width * 0.75));
				krabs.antialiasing = true;
				add(krabs);

				krustyKrabDancersBG = new FlxTypedGroup<BackgroundDancer>();
				krustyKrabDancersFG = new FlxTypedGroup<BackgroundDancer>();

				var crowd:BackgroundDancer = new BackgroundDancer(-530, 335, 'crowd', 665, 471);
				krustyKrabDancersBG.add(crowd);

				var mindy:BackgroundDancer = new BackgroundDancer(965, 440, 'mindy', 300, 304);
				mindy.setGraphicSize(Std.int(mindy.width * 1.1));
				krustyKrabDancersBG.add(mindy);

				var squidward:BackgroundDancer = new BackgroundDancer(670, 300, 'squidward', 171, 473);
				squidward.setGraphicSize(Std.int(squidward.width * 0.8));
				krustyKrabDancersBG.add(squidward);

				table = new FNFSprite(-550, -510).loadGraphic(Paths.image('backgrounds/KK/IMG_5531'), true, 2560, 1440);
				table.antialiasing = true;

				var topLayer:FNFSprite = new FNFSprite(-550, -510).loadGraphic(Paths.image('backgrounds/KK/IMG_5530'), true, 2560, 1440);
				topLayer.antialiasing = true;
				foreground.add(topLayer);

				var zombieLeft:BackgroundDancer = new BackgroundDancer(-575, 410, 'fgZombieLeft', 505, 492);
				zombieLeft.scrollFactor.set(0.95, 0.95);
				krustyKrabDancersFG.add(zombieLeft);

				var zombieRight:BackgroundDancer = new BackgroundDancer(1570, 490, 'fgZombieRight', 526, 480);
				zombieRight.scrollFactor.set(0.95, 0.95);
				krustyKrabDancersFG.add(zombieRight);

			// Decoy is responsible for porting over 'on-ice' to this engine, props to him - doubletime32
			case 'joke':
				PlayState.defaultCamZoom = 0.87;
				bg = new FNFSprite(-600, -200).loadGraphic(Paths.image('backgrounds/stagejoke/joke'));
				bg.antialiasing = true;
				bg.x += 300;
				bg.y -= 30;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);
				
			case 'squid':
				PlayState.defaultCamZoom = 0.6;
				bg = new FNFSprite(-700, -230).loadGraphic(Paths.image('backgrounds/robosquid/bg1'));
				bg.antialiasing = true;
				add(bg);

				var platform:FNFSprite = new FNFSprite(-700, -230).loadGraphic(Paths.image('backgrounds/robosquid/platform'));
				platform.antialiasing = true;
				betweenLayers.add(platform);

				var pillar:FNFSprite = new FNFSprite(-700, -230).loadGraphic(Paths.image('backgrounds/robosquid/bg3'));
				pillar.antialiasing = true;
				betweenLayers.add(pillar);

				var topLayer:FNFSprite = new FNFSprite(-700, -230).loadGraphic(Paths.image('backgrounds/robosquid/gradient'));
				topLayer.blend = ADD;
				topLayer.antialiasing = true;
				foreground.add(topLayer);

			case 'pimpbob':
				PlayState.defaultCamZoom = 0.8;
				bg = new FNFSprite(-200, -150).loadGraphic(Paths.image('backgrounds/pimpbob/pimpbobbg'));
				bg.antialiasing = true;
				add(bg);
		}
	}

	// return the girlfriend's type
	public function returnGFtype(curStage)
	{
		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'krustykrab':
				gfVersion = 'strip-pat';
			case 'pimpbob':
				gfVersion = 'gf-boat';
		}

		return gfVersion;
	}

	// get the dad's position
	public function dadPosition(curStage, boyfriend:Character, dad:Character, gf:Character, camPos:FlxPoint):Void
	{
		var characterArray:Array<Character> = [dad, boyfriend];
		for (char in characterArray) {
			switch (char.curCharacter)
			{
				case 'gf':
					char.setPosition(gf.x, gf.y);
					gf.visible = false;
				/*
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
				}*/
				/*
				case 'spirit':
					var evilTrail = new FlxTrail(char, null, 4, 24, 0.3, 0.069);
					evilTrail.changeValuesEnabled(false, false, false, false);
					add(evilTrail);
					*/
			}
		}
	}

	public function repositionPlayers(curStage, boyfriend:Character, dad:Character, gf:Character):Void
	{
		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'doodleBG':
				dad.y += 240;
				dad.x -= 380;
				gf.x -= 180;
				gf.y -= 65;
			case 'poseidome':
				dad.y += 150;
				dad.x -= 480;
				boyfriend.x += 480;
				boyfriend.y += 55;
				gf.x += 150;
				gf.y += 200;
				doodleBFExist = false;
			case 'krustykrab':
				dad.y += 150;
				dad.x -= 150;
				boyfriend.x += 380;
				boyfriend.y += 20;
				gf.y -= 210;
				gf.x += 312;
				doodleBFExist = false;
			case 'joke':
				dad.y -= 115;
				dad.x -= 250;
				boyfriend.y -= 185;
				boyfriend.x -= 300;
				gfExist = false;
				doodleBFExist = false;
			case 'squid':
				dad.y += 755;
				dad.x -= 540;
				boyfriend.y += 60;
				boyfriend.x += 90;
				gfExist = false;
				doodleBFExist = false;
			case 'pimpbob':
				dad.y += 420;
				dad.x += 100;
				boyfriend.visible = false;
				gf.x += 700;
				gf.y -= 30;
				doodleBFExist = false;
		}
	}

	var curLight:Int = 0;
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var startedMoving:Bool = false;

	public function stageUpdate(curBeat:Int, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		// trace('update backgrounds');
		switch (PlayState.curStage)
		{
			case 'poseidome':
				if (curBeat == 352)
				{
					sandyTail.playAnim('loopLeft', true);
					sandyTail.visible = true;
				}
			case 'doodleBG':
			if (curBeat == 177)
				smokeFade = 1;
			case 'krustykrab':
			if (curBeat % 2 == 0)
			{
				krustyKrabDancersBG.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});
				krustyKrabDancersFG.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});
			}
				if (curBeat == 325)
				{
					bgNote.visible = true;
					bg.animation.frameIndex = 1;
					table.animation.frameIndex = 1;
					foreground.members[0].animation.frameIndex = 1;
				}
		}
	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		switch (PlayState.curStage)
		{
			case 'krustykrab':
				bgNote.alpha = FlxMath.lerp(0, bgNote.alpha, 0.99);
			case 'doodleBG':
				smoke.alpha = FlxMath.lerp(smokeFade, smoke.alpha, 0.94);
		}
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}
}
