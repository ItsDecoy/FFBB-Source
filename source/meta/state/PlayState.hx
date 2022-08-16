package meta.state;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import gameObjects.*;
import gameObjects.userInterface.*;
import gameObjects.userInterface.notes.*;
import gameObjects.userInterface.notes.Strumline.UIStaticArrow;
import meta.*;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Song.SwagSong;
import meta.state.charting.*;
import meta.state.menus.*;
import meta.subState.*;
import openfl.display.GraphicsShader;
import openfl.events.KeyboardEvent;
import openfl.filters.ShaderFilter;
import openfl.media.Sound;
import openfl.utils.Assets;
import sys.io.File;

using StringTools;

#if !html5
import meta.data.dependency.Discord;
#end

class PlayState extends MusicBeatState
{
	public static var startTimer:FlxTimer;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 2;

	public static var songMusic:FlxSound;
	public static var vocals:FlxSound;

	public static var campaignScore:Int = 0;

	public static var dadOpponent:Character;
	public static var doodleBF:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	private var fishAnnouncer:FlxSprite;

	public static var assetModifier:String = 'base';
	public static var changeableSkin:String = 'default';

	private var unspawnNotes:Array<Note> = [];
	private var ratingArray:Array<String> = [];
	private var allSicks:Bool = true;

	// if you ever wanna add more keys
	private var numberOfKeys:Int = 4;

	// get it cus release
	// I'm funny just trust me
	private var curSection:Int = 0;
	private var camFollow:FlxObject;
	private var camFollowPos:FlxObject;
	private var alphaFade:Int = 1;

	// Discord RPC variables
	public static var curImage:String = "";
	public static var songDetails:String = "";
	public static var detailsSub:String = "";
	public static var detailsPausedText:String = "";

	private static var prevCamFollow:FlxObject;

	public static var curSong:String = "";
	private var gfSpeed:Int = 1;

	public static var combo:Int = 0;
	public static var drainHealth:Int = 0;
	public var songDivide:Int = 0;
	public var eachIndex:Array<Int> = [];
	public static var underwearHealth:Int = 5;
	public static var underwearHealthHeal:Float = 0.3;
	public var earnedSpatula:Bool = false;

	public static var misses:Int = 0;
	private var missOffset:Bool = false;

	public var sectionAlt:Bool = false;
	public static var practiceMode = false;
	public static var timeStamp:Float = 0;
	public static var ggSponge:Bool = false;

	public var generatedMusic:Bool = false;

	private var startingSong:Bool = false;
	public static var songRestart:Bool = false;
	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var inCutscene:Bool = false;

	var canPause:Bool = true;

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	public var bubbles:FlxTypedGroup<FlxEmitter>;

	private var switchOpponent:Bool = false;
	private var playTogether:Bool = false;
	private var sustainNoteLength = 0;
	private var directionCall:String;
	private var storeStep:Int = 0;
	public static var idleAlt:Bool = false;

	private var sizeChange:Bool = false;

	private var scatScene:Bool = false;

	public static var speed:Float = 0;

	var blackScreenCover:FlxSprite;

	public static var camHUD:FlxCamera;
	public static var camGame:FlxCamera;
	public static var bubbleHUD:FlxCamera;
	public static var pauseHUD:FlxCamera;

	public var camDisplaceX:Float = 0;
	public var camDisplaceY:Float = 0; // might not use depending on result
	public static var cameraSpeed:Float = 1;

	public static var defaultCamZoom:Float = 1.05;

	public static var forceZoom:Array<Float>;

	public static var songScore:Int = 0;

	var storyDifficultyText:String = "";

	public static var iconRPC:String = "";

	public static var songLength:Float = 0;

	private var stageBuild:Stage;

	public static var uiHUD:ClassHUD;
	public var spatulaHUD:SpatulaHUD;

	public static var daPixelZoom:Float = 6;
	public static var determinedChartType:String = "";

	// strumlines
	private var dadStrums:Strumline;
	private var boyfriendStrums:Strumline;

	public static var strumLines:FlxTypedGroup<Strumline>;
	public static var strumHUD:Array<FlxCamera> = [];

	private var allUIs:Array<FlxCamera> = [];

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo objects in an array
	public static var lastCombo:Array<FlxSprite>;

	// at the beginning of the playstate
	override public function create()
	{
		super.create();

		// reset any values and variables that are static
		songScore = 0;
		combo = 0;
		drainHealth = 0;
		underwearHealth = 5;
		underwearHealthHeal = 0.3;
		misses = 0;
		ggSponge = false;
		idleAlt = false;
		// sets up the combo object array
		lastCombo = [];

		defaultCamZoom = 1.05;
		cameraSpeed = 1;
		forceZoom = [0, 0, 0, 0];

		Timings.callAccuracy();

		assetModifier = 'base';
		changeableSkin = 'default';

		// stop any existing music tracks playing
		resetMusic();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// create the game camera
		camGame = new FlxCamera();

		// create the hud camera (separate so the hud stays on screen)
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		bubbleHUD = new FlxCamera();
		bubbleHUD.bgColor.alpha = 0;
		pauseHUD = new FlxCamera();
		pauseHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(bubbleHUD);
		allUIs.push(camHUD);
		FlxCamera.defaultCameras = [camGame];

		// default song
		if (SONG == null)
			SONG = Song.loadFromJson('test', 'test');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		/// here we determine the chart type!
		// determine the chart type here
		determinedChartType = "FNF";

		//

		// set up a class for the stage type in here afterwards
		curStage = "";
		// call the song's stage if it exists
		if (SONG.stage != null)
			curStage = SONG.stage;

		// cache shit
		displayRating('sick', true);
		popUpCombo(true);
		//

		stageBuild = new Stage(curStage);
		add(stageBuild);

		/*
			Everything related to the stages aside from things done after are set in the stage class!
			this means that the girlfriend's type, boyfriend's position, dad's position, are all there

			It serves to clear clutter and can easily be destroyed later. The problem is,
			I don't actually know if this is optimised, I just kinda roll with things and hope
			they work. I'm not actually really experienced compared to a lot of other developers in the scene,
			so I don't really know what I'm doing, I'm just hoping I can make a better and more optimised
			engine for both myself and other modders to use!
		 */

		// set up characters here too
		if (stageBuild.gfExist)
		{
			gf = new Character();
			gf.adjustPos = false;
			gf.setCharacter(300, 100, stageBuild.returnGFtype(curStage));
			gf.scrollFactor.set(0.95, 0.95);
		}

		dadOpponent = new Character().setCharacter(50, 850, SONG.player2);
		if (stageBuild.doodleBFExist)
		{
			doodleBF = new Character().setCharacter(dadOpponent.x - 750, dadOpponent.y + 850, 'doodlebf');
			doodleBF.visible = false;
		}
		boyfriend = new Boyfriend();
		boyfriend.setCharacter(750, 850, SONG.player1);
		// if you want to change characters later use setCharacter() instead of new or it will break

		var camPos:FlxPoint = new FlxPoint(gf.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

		stageBuild.repositionPlayers(curStage, boyfriend, dadOpponent, gf);
		stageBuild.dadPosition(curStage, boyfriend, dadOpponent, gf, camPos);

		changeableSkin = Init.trueSettings.get("UI Skin");
		if ((curStage.startsWith("school")) && ((determinedChartType == "FNF")))
			assetModifier = 'pixel';

		// add characters
		if (stageBuild.gfExist)
			add(gf);

		// add limo cus dumb layering
		if (curStage == 'krustykrab')
		{
			add(stageBuild.krustyKrabDancersBG);
			add(stageBuild.table);
		}

		add(dadOpponent);
		if (curStage == 'squid')
			add(stageBuild.betweenLayers);
		add(boyfriend);
		if (stageBuild.doodleBFExist)
			add(doodleBF);

		add(stageBuild.foreground);
		if (curStage == 'krustykrab')
			add(stageBuild.krustyKrabDancersFG);

		// force them to dance
		dadOpponent.dance();
		gf.dance();
		boyfriend.dance();

		// This is where I coded the particle effects for the HUD so bubbles rise up, giving it a more underwater feel - doubletime32
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

		// set song position before beginning
		Conductor.songPosition = -(Conductor.crochet * 4);

		// EVERYTHING SHOULD GO UNDER THIS, IF YOU PLAN ON SPAWNING SOMETHING LATER ADD IT TO STAGEBUILD OR FOREGROUND
		// darken everything but the arrows and ui via a flxsprite
		var darknessBG:FlxSprite = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		darknessBG.alpha = (100 - Init.trueSettings.get('Stage Opacity')) / 100;
		darknessBG.scrollFactor.set(0, 0);
		add(darknessBG);

		// strum setup
		strumLines = new FlxTypedGroup<Strumline>();

		// generate the song
		generateSong(SONG.song);

		// set the camera position to the center of the stage
		switch (curSong.toLowerCase())
		{
			case 'doodle-duel':
				camPos.set(gf.x + (gf.frameWidth / 2), gf.y + (gf.frameHeight - 250));
			case 'plan-z':
				camPos.set(gf.x + (gf.frameWidth / 3), gf.y + (gf.frameHeight / 3));
			case 'pimpin':
				camPos.set(dadOpponent.getGraphicMidpoint().x - 30, dadOpponent.getGraphicMidpoint().y - 220);
			case 'on-ice':
				camPos.set(dadOpponent.getGraphicMidpoint().x + 400, dadOpponent.getGraphicMidpoint().y - 10);
			case 'nuts-and-bolts':
				camPos.set(gf.x + 200, gf.y + 300);
			case 'scrapped-metal':
				camPos.set(gf.x + (gf.frameWidth / 2) - 100, gf.y + (gf.frameHeight - 250));
			default:
				camPos.set(gf.x + (gf.frameWidth / 2), gf.y + (gf.frameHeight / 2));
		}

		// create the game camera
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(camPos.x, camPos.y);
		// check if the camera was following someone previously
		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);
		add(camFollowPos);

		// actually set the camera up
		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		// initialize ui elements
		startingSong = true;
		startedCountdown = true;

		//
		var placement = (FlxG.width / 2);
		dadStrums = new Strumline(placement - (FlxG.width / 4), this, dadOpponent, false, true, false, 4, Init.trueSettings.get('Downscroll'));
		dadStrums.visible = !Init.trueSettings.get('Centered Notefield');
		if (curSong.toLowerCase() != 'pimpin')
			boyfriendStrums = new Strumline(placement + (!Init.trueSettings.get('Centered Notefield') ? (FlxG.width / 4) : 0), this, boyfriend, true, false, true,
				4, Init.trueSettings.get('Downscroll'));
		else
			boyfriendStrums = new Strumline(placement, this, boyfriend, true, false,
				true, 4, Init.trueSettings.get('Downscroll'));

		strumLines.add(dadStrums);
		strumLines.add(boyfriendStrums);

		// strumline camera setup
		strumHUD = [];
		for (i in 0...strumLines.length)
		{
			// generate a new strum camera
			strumHUD[i] = new FlxCamera();
			strumHUD[i].bgColor.alpha = 0;

			strumHUD[i].cameras = [camHUD];
			allUIs.push(strumHUD[i]);
			FlxG.cameras.add(strumHUD[i]);
			// set this strumline's camera to the designated camera
			strumLines.members[i].cameras = [strumHUD[i]];
		}
		add(strumLines);

		FlxG.cameras.add(pauseHUD);

		if (curSong.toLowerCase() == 'pimpin')
			dadStrums.visible = false;

		uiHUD = new ClassHUD();
		add(uiHUD);
		uiHUD.cameras = [camHUD];
		bubbles.cameras = [bubbleHUD];
		add(bubbles);

		spatulaHUD = new SpatulaHUD(-200, 250);
		spatulaHUD.cameras = [camHUD];
		add(spatulaHUD);

		fishAnnouncer = new FlxSprite(962, 150);
		fishAnnouncer.loadGraphic(Paths.image('UI/default/base/fishAnnouncer'), true, 390, 355);
		fishAnnouncer.animation.add('speak', [0, 0, 1, 2, 3, 4], 14, false);
		fishAnnouncer.animation.add('go', [0, 0, 0, 0, 1, 2, 3, 4], 13, false);
		fishAnnouncer.animation.frameIndex = 4;
		fishAnnouncer.antialiasing = true;
		fishAnnouncer.cameras = [camHUD];
		add(fishAnnouncer);

		// Creating the opponent's health - doubletime32
		songDivide = Math.floor(Std.int(songMusic.length / 9));
		eachIndex.push(100);
		for(i in 1...9)
		{
			var track:Int = 0;
			track = songDivide * i;
			eachIndex.unshift(track);
		}

		if (FlxG.save.data.speedStore)
		{
			speed = SONG.speed;
			FlxG.save.data.speedStore = false;
		}

		// This tracks what song is playing so it changes the image on Discord to the proper song - doubletime32
		switch (curSong.toLowerCase())
		{
			case 'doodle-duel':
				curImage = "doodleshit";
			case 'nuts-and-bolts':
				curImage = "deezandnuts";
			case 'on-ice':
				curImage = "onfart";
			case 'scrapped-metal':
				curImage = "scrappedcoochie";
			case 'plan-z':
				curImage = "bald";
			case 'pimpin':
				curImage = "helookslikemyuncle";
			default:
				curImage = "freaky";
		}

		#if android
		addAndroidControls();
		#end

		//
		keysArray = [
			copyKey(Init.gameControls.get('LEFT')[0]),
			copyKey(Init.gameControls.get('DOWN')[0]),
			copyKey(Init.gameControls.get('UP')[0]),
			copyKey(Init.gameControls.get('RIGHT')[0])
		];

		if (!Init.trueSettings.get('Controller Mode'))
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		
		Paths.clearUnusedMemory();

		// call the funny intro cutscene depending on the song
		if (!skipCutscenes() && !practiceMode)
			songIntroCutscene();
		else if (!practiceMode)
			startCountdown();
		else if (practiceMode)
			startSong();
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len)
		{
			if (copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
	
	var keysArray:Array<Dynamic>;

	public function onKeyPress(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if ((key >= 0)
			&& !boyfriendStrums.autoplay
      && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || Init.trueSettings.get('Controller Mode'))
			&& (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate)))
		{
			if (generatedMusic)
			{
				var previousTime:Float = Conductor.songPosition;
				Conductor.songPosition = songMusic.time;
				// improved this a little bit, maybe its a lil
				var possibleNoteList:Array<Note> = [];
				var pressedNotes:Array<Note> = [];

				boyfriendStrums.allNotes.forEachAlive(function(daNote:Note)
				{
					if ((daNote.noteData == key) && daNote.canBeHit && !daNote.isSustainNote && !daNote.tooLate && !daNote.wasGoodHit)
						possibleNoteList.push(daNote);
				});
				possibleNoteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				// if there is a list of notes that exists for that control
				if (possibleNoteList.length > 0)
				{
					var eligable = true;
					var firstNote = true;
					// loop through the possible notes
					for (coolNote in possibleNoteList)
					{
						for (noteDouble in pressedNotes)
						{
							if (Math.abs(noteDouble.strumTime - coolNote.strumTime) < 10)
								firstNote = false;
							else
								eligable = false;
						}

						if (eligable) {
							goodNoteHit(coolNote, boyfriend, boyfriendStrums, firstNote); // then hit the note
							pressedNotes.push(coolNote);
						}
						// end of this little check
					}
					//
				}
				else // else just call bad notes
					if (!Init.trueSettings.get('Ghost Tapping'))
						missNoteCheck(true, key, boyfriend, true);
				Conductor.songPosition = previousTime;
			}

			if (boyfriendStrums.receptors.members[key] != null 
			&& boyfriendStrums.receptors.members[key].animation.curAnim.name != 'confirm')
				boyfriendStrums.receptors.members[key].playAnim('pressed');
		}
	}

	public function onKeyRelease(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate)) {
			// receptor reset
			if (key >= 0 && boyfriendStrums.receptors.members[key] != null)
				boyfriendStrums.receptors.members[key].playAnim('static');
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int {
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
						return i;
				}
			}
		}
		return -1;
	}

	override public function destroy() {
		if (!Init.trueSettings.get('Controller Mode'))
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		super.destroy();
	}

	var staticDisplace:Int = 0;

	var lastSection:Int = 0;

	override public function update(elapsed:Float)
	{
		stageBuild.stageUpdateConstant(elapsed, boyfriend, gf, dadOpponent);

		fixVocals();

		super.update(elapsed);

		if (dadOpponent.animation.curAnim.curFrame == 69)
			stageBuild.sandyTail.playAnim('loopRight', true);

		if ((dadOpponent.animation.curAnim.name == 'doodle'
			|| dadOpponent.animation.curAnim.name == 'doodleFLIPOFF') && dadOpponent.animation.curAnim.finished)
			dadOpponent.playAnim('doodleLOOP', true);

		if (!practiceMode)
		{
			if ((songMusic.length - Conductor.songPosition) < 1500
				&& ((isStoryMode && !FlxG.save.data.storyComplete)
					|| (curSong.toLowerCase() == 'doodle-duel' && !FlxG.save.data.doodleComplete)
					|| (curSong.toLowerCase() == 'plan-z' && !FlxG.save.data.neptuneComplete)
					|| (curSong.toLowerCase() == 'pimpin' && !FlxG.save.data.pimpbobComplete)
					|| (curSong.toLowerCase() == 'scrapped-metal' && !FlxG.save.data.squidComplete))
				&& !earnedSpatula)
			{
				earnedSpatula = true;
				canPause = false;
				FlxG.sound.play(Paths.sound('earnedSpatula'), 0.7);
				FlxG.save.data.spat++;
				spatulaHUD.saveSpatCount(FlxG.save.data.spat);
				FlxTween.tween(spatulaHUD.spatula, {x: 0}, 0.5, {ease: FlxEase.smootherStepInOut});
			}
		}

		if (practiceMode)
		{
			songScore = 0;
			if (underwearHealth < -1)
			{
				underwearHealth = -1;
				underwearHealthHeal = 0.3;
				ClassHUD.underwearHealthGroup.members[underwearHealth + 1].alpha = underwearHealthHeal;
			}
		}
		if (underwearHealth > 5)
			underwearHealth = 5;
		
		// This tracks what point of the song you're in to lower the opponent's health properly - doubletime32
		if ((songMusic.length - Conductor.songPosition) <= eachIndex[drainHealth])
			drainHealth++;

		if (dadOpponent.animation.curAnim.name == 'transition' && dadOpponent.animation.curAnim.finished)
			dadOpponent.dance();

		if (!inCutscene) {
			///*
			if (startingSong)
			{
				if (startedCountdown)
				{
					Conductor.songPosition += elapsed * 1000;
					if (Conductor.songPosition >= 0)
						startSong();
				}
			}
			else
			{
				// Conductor.songPosition = FlxG.sound.music.time;
				Conductor.songPosition += elapsed * 1000;

				if (!paused)
				{
					songTime += FlxG.game.ticks - previousFrameTime;
					previousFrameTime = FlxG.game.ticks;

					// Interpolation type beat
					if (Conductor.lastSongPos != Conductor.songPosition)
					{
						songTime = (songTime + Conductor.songPosition) / 2;
						Conductor.lastSongPos = Conductor.songPosition;
						// Conductor.songPosition += FlxG.elapsed * 1000;
						// trace('MISSED FRAME');
					}
				}

				// Conductor.lastSongPos = FlxG.sound.music.time;
				// song shit for testing lols
			}

			// boyfriend.playAnim('singLEFT', true);
			// */

			if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				var curSection = Std.int(curStep / 16);
				if (curSection != lastSection) {
					// section reset stuff
					var lastMustHit:Bool = PlayState.SONG.notes[lastSection].mustHitSection;
					if (PlayState.SONG.notes[curSection].mustHitSection != lastMustHit) {
						camDisplaceX = 0;
						camDisplaceY = 0;
					}
					lastSection = Std.int(curStep / 16);
				}

				if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					var char = dadOpponent;
					if (curSong.toLowerCase() == 'plan-z')
						defaultCamZoom = 0.6;

					var getCenterX = char.getMidpoint().x + 100;
					var getCenterY = char.getMidpoint().y - 100;

					if (curSong.toLowerCase() == 'pimpin')
					{
						getCenterX = char.getMidpoint().x;
						getCenterY = char.getMidpoint().y - 280;
					}

					camFollow.setPosition(getCenterX + camDisplaceX + char.characterData.camOffsetX,
						getCenterY + camDisplaceY + char.characterData.camOffsetY);

					if (char.curCharacter == 'mom')
						vocals.volume = 1;
				}
				else
				{
					var char = boyfriend;
					if (curSong.toLowerCase() == 'plan-z' && !scatScene && curBeat < 336)
						defaultCamZoom = 1;

					var getCenterX = char.getMidpoint().x - 100;
					var getCenterY = char.getMidpoint().y - 100;

					if (curSong.toLowerCase() == 'plan-z')
					{
						if (curBeat < 336)
						{
							getCenterX = char.getMidpoint().x - 100;
							getCenterY = char.getMidpoint().y - 100;
						}
						else if (curBeat >= 336)
						{
							getCenterX = char.getMidpoint().x - 550;
							getCenterY = char.getMidpoint().y + 100;
						}
					}
					else if (curSong.toLowerCase() == 'pimpin')
					{
						getCenterX = dadOpponent.getMidpoint().x - 330;
						getCenterY = dadOpponent.getMidpoint().y - 280;
					}

					switch (curStage)
					{
						case 'doodleBG':
							getCenterY = char.getMidpoint().y - 100;
						case 'squid':
							getCenterY = char.getMidpoint().y - 270;
							getCenterX = char.getMidpoint().x - 160;
						case 'poseidome':
							getCenterY = char.getMidpoint().y - 245;
							getCenterX = char.getMidpoint().x - 100;
						case 'krustykrab':
							if (curBeat < 336)
								getCenterY = char.getMidpoint().y - 125;
					}

					if (curSong.toLowerCase() == 'pimpin')
					{
						char.characterData.camOffsetX = dadOpponent.characterData.camOffsetX;
						char.characterData.camOffsetY = dadOpponent.characterData.camOffsetY;
					}
						
					camFollow.setPosition(getCenterX + camDisplaceX - char.characterData.camOffsetX,
						getCenterY + camDisplaceY + char.characterData.camOffsetY);

					if ((curStep >= 1234 && curStep < 1301) && curSong.toLowerCase() == 'plan-z')
					{
						getCenterX = char.getMidpoint().x - 10;
						getCenterY = char.getMidpoint().y - 20;
						camFollow.setPosition(getCenterX, getCenterY);
					}
				}
			}

			var lerpVal = (elapsed * 2.4) * cameraSpeed;
			var lerpCamScat = (elapsed * 2.4) * 0.7;
			if (!scatScene)
				camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			else
				camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpCamScat), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpCamScat));

			var easeLerp = 0.95;
			var lerpScat = 0.99;
			// camera stuffs
			if (!scatScene)
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + forceZoom[0], FlxG.camera.zoom, easeLerp);
			else
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + forceZoom[0], FlxG.camera.zoom, lerpScat);
			for (hud in allUIs)
				hud.zoom = FlxMath.lerp(1 + forceZoom[1], hud.zoom, easeLerp);

			// not even forcezoom anymore but still
			FlxG.camera.angle = FlxMath.lerp(0 + forceZoom[2], FlxG.camera.angle, easeLerp);
			for (hud in allUIs)
				hud.angle = FlxMath.lerp(0 + forceZoom[3], hud.angle, easeLerp);

			// alpha lerps - doubletime32
			for (hud in allUIs)
				hud.alpha = FlxMath.lerp(alphaFade, hud.alpha, 0.97);

			if ((underwearHealth < -1 && startedCountdown && !practiceMode) || controls.RESET)
			{
				// startTimer.active = false;
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				resetMusic();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				// discord stuffs should go here
			}

			// spawn in the notes from the array
			if ((unspawnNotes[0] != null) && ((unspawnNotes[0].strumTime - Conductor.songPosition) < 3500))
			{
				var dunceNote:Note = unspawnNotes[0];
				// push note to its correct strumline
				strumLines.members[Math.floor((dunceNote.noteData + (dunceNote.mustPress ? 4 : 0)) / numberOfKeys)].push(dunceNote);
				unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);
			}

			noteCalls();

			if (Init.trueSettings.get('Controller Mode'))
				controllerInput();
		}

		if ((curSong.toLowerCase() != 'doodle-duel' && curSong.toLowerCase() != 'on-ice' && curSong.toLowerCase() != 'plan-z' && curSong.toLowerCase() != 'pimpin') 
			&& !sizeChange) 
		{
			if (stageBuild.gfExist)
				gf.setGraphicSize(Std.int(gf.width * 0.4));
			sizeChange = true;
		}
	}
	
  function controllerInput()
	{
		var justPressArray:Array<Bool> = [
			controls.LEFT_P,
			controls.DOWN_P,
			controls.UP_P,
			controls.RIGHT_P
		];

		var justReleaseArray:Array<Bool> = [
			controls.LEFT_R,
			controls.DOWN_R,
			controls.UP_R,
			controls.RIGHT_R
		];

		if (justPressArray.contains(true))
		{
			for (i in 0...justPressArray.length)
			{
				if (justPressArray[i])
					onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
			}
		}

		if (justReleaseArray.contains(true))
		{
			for (i in 0...justReleaseArray.length)
			{
				if (justReleaseArray[i])
					onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
			}
		}
	}

	function noteCalls()
	{
		// reset strums
		for (strumline in strumLines)
		{
			// handle strumline stuffs
			var i = 0;
			for (uiNote in strumline.receptors)
			{
				if (strumline.autoplay)
					strumCallsAuto(uiNote);
			}

			if (strumline.splashNotes != null)
				for (i in 0...strumline.splashNotes.length)
				{
					strumline.splashNotes.members[i].x = strumline.receptors.members[i].x - 48;
					strumline.splashNotes.members[i].y = strumline.receptors.members[i].y + (Note.swagWidth / 6) - 56;
				}
		}

		// if the song is generated
		if (generatedMusic && startedCountdown)
		{
			for (strumline in strumLines)
			{
				// set the notes x and y
				var downscrollMultiplier = 1;
				if (Init.trueSettings.get('Downscroll'))
					downscrollMultiplier = -1;
				
				strumline.allNotes.forEachAlive(function(daNote:Note)
				{
					var roundedSpeed = FlxMath.roundDecimal(daNote.noteSpeed, 2);
					var receptorPosY:Float = strumline.receptors.members[Math.floor(daNote.noteData)].y + Note.swagWidth / 6;
					var psuedoY:Float = (downscrollMultiplier * -((Conductor.songPosition - daNote.strumTime) * (0.45 * roundedSpeed)));
					var psuedoX = 25 + daNote.noteVisualOffset;

					daNote.y = receptorPosY
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX);
					// painful math equation
					daNote.x = strumline.receptors.members[Math.floor(daNote.noteData)].x
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY);

					// also set note rotation
					daNote.angle = -daNote.noteDirection;

					// shitty note hack I hate it so much
					var center:Float = receptorPosY + Note.swagWidth / 2;
					if (daNote.isSustainNote) {
						daNote.y -= ((daNote.height / 2) * downscrollMultiplier);
						if ((daNote.animation.curAnim.name.endsWith('holdend')) && (daNote.prevNote != null)) {
							daNote.y -= ((daNote.prevNote.height / 2) * downscrollMultiplier);
							if (Init.trueSettings.get('Downscroll')) {
								daNote.y += (daNote.height * 2);
								if (daNote.endHoldOffset == Math.NEGATIVE_INFINITY) {
									// set the end hold offset yeah I hate that I fix this like this
									daNote.endHoldOffset = (daNote.prevNote.y - (daNote.y + daNote.height));
									//trace(daNote.endHoldOffset);
								}
								else
									daNote.y += daNote.endHoldOffset;
							} else // this system is funny like that
								daNote.y += ((daNote.height / 2) * downscrollMultiplier);
						}
						
						if (Init.trueSettings.get('Downscroll'))
						{
							daNote.flipY = true;
							if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit) 
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
								&& (strumline.autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;
								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (strumline.autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
								daNote.clipRect = swagRect;
							}
						}
					}
					// hell breaks loose here, we're using nested scripts!
					mainControls(daNote, strumline.character, strumline, strumline.autoplay);

					// check where the note is and make sure it is either active or inactive
					if (daNote.y > FlxG.height) {
						daNote.active = false;
						daNote.visible = false;
					} else {
						daNote.visible = true;
						daNote.active = true;
					}

					if (!daNote.tooLate && daNote.strumTime < Conductor.songPosition - (Timings.msThreshold) && !daNote.wasGoodHit)
					{
						if ((!daNote.tooLate) && (daNote.mustPress)) {
							if (!daNote.isSustainNote)
							{
								daNote.tooLate = true;
								for (note in daNote.childrenNotes)
									note.tooLate = true;
								
								vocals.volume = 0;
								missNoteCheck((Init.trueSettings.get('Ghost Tapping')) ? true : false, daNote.noteData, boyfriend, true);
								// ambiguous name
								Timings.updateAccuracy(0);

							}
							else if (daNote.isSustainNote)
							{
								if (daNote.parentNote != null)
								{
									var parentNote = daNote.parentNote;
									if (!parentNote.tooLate)
									{
										var breakFromLate:Bool = false;
										for (note in parentNote.childrenNotes)
										{
											//trace('hold amount ${parentNote.childrenNotes.length}, note is late?' + note.tooLate + ', ' + breakFromLate);
											if (note.tooLate && !note.wasGoodHit)
												breakFromLate = true;
										}
										if (!breakFromLate)
										{
											missNoteCheck((Init.trueSettings.get('Ghost Tapping')) ? true : false, daNote.noteData, boyfriend, true);
											for (note in parentNote.childrenNotes)
												note.tooLate = true;
										}
										//
									}
								}
							}
						}
					
					}

					// if the note is off screen (above)
					if ((((!Init.trueSettings.get('Downscroll')) && (daNote.y < -daNote.height))
					|| ((Init.trueSettings.get('Downscroll')) && (daNote.y > (FlxG.height + daNote.height))))
					&& (daNote.tooLate || daNote.wasGoodHit))
						destroyNote(strumline, daNote);
						
				});


				// unoptimised asf camera control based on strums
				strumCameraRoll(strumline.receptors, (strumline == boyfriendStrums));
			}
			
		}
		
		// reset bf's animation
		var holdControls:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		if ((boyfriend != null && boyfriend.animation != null)
			&& (boyfriend.holdTimer > Conductor.stepCrochet * (4 / 1000)
			&& (!holdControls.contains(true) || boyfriendStrums.autoplay)))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
		}
	}

	function destroyNote(strumline:Strumline, daNote:Note)
	{
		daNote.active = false;
		daNote.exists = false;

		var chosenGroup = (daNote.isSustainNote ? strumline.holdsGroup : strumline.notesGroup);
		// note damage here I guess
		daNote.kill();
		if (strumline.allNotes.members.contains(daNote))
			strumline.allNotes.remove(daNote, true);
		if (chosenGroup.members.contains(daNote))
			chosenGroup.remove(daNote, true);
		daNote.destroy();
	}


	function goodNoteHit(coolNote:Note, character:Character, characterStrums:Strumline, ?canDisplayJudgement:Bool = true)
	{
		if (!coolNote.wasGoodHit) {
			coolNote.wasGoodHit = true;
			vocals.volume = 1;

			// Second opponent and first opponent animation playing - doubletime32

			// just work pls line of code - doubletime32
			if (!switchOpponent || playTogether)
				characterPlayAnimation(coolNote, character);
			if (!canDisplayJudgement && (playTogether || switchOpponent))
				characterPlayAnimation(coolNote, doodleBF);
			
			if (characterStrums.receptors.members[coolNote.noteData] != null)
				characterStrums.receptors.members[coolNote.noteData].playAnim('confirm', true);

			// special thanks to sam, they gave me the original system which kinda inspired my idea for this new one
			if (canDisplayJudgement) {
				// get the note ms timing
				var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition);

				// loop through all avaliable judgements
				var foundRating:String = 'miss';
				var lowestThreshold:Float = Math.POSITIVE_INFINITY;
				for (myRating in Timings.judgementsMap.keys())
				{
					var myThreshold:Float = Timings.judgementsMap.get(myRating)[1];
					if (noteDiff <= myThreshold && (myThreshold < lowestThreshold))
					{
						foundRating = myRating;
						lowestThreshold = myThreshold;
					}
				}

				if (!Init.trueSettings.get('Disable Flashing Lights'))
				{
					if (curSong.toLowerCase() == 'plan-z' && !coolNote.isSustainNote)
					{
						stageBuild.bgNote.animation.frameIndex = coolNote.noteData;
						stageBuild.bgNote.alpha = 1;
					}
				}

				if ((!coolNote.isSustainNote || coolNote.isSustainNote) && switchOpponent)
					characterPlayAnimation(coolNote, boyfriend);

				if (!coolNote.isSustainNote) {
					increaseCombo(foundRating, coolNote.noteData, character);
					popUpScore(foundRating, characterStrums, coolNote);
					if (coolNote.childrenNotes.length > 0)
						Timings.notesHit++;
					if (underwearHealth < 5)
						uiHUD.updateHealth(true);
				} else if (coolNote.isSustainNote) {
					// call updated accuracy stuffs
					if (coolNote.parentNote != null) {
						Timings.updateAccuracy(100, true, coolNote.parentNote.childrenNotes.length);
						if (underwearHealth < 5)
							uiHUD.updateHealth(true);
					}
				}
			}

			if (!coolNote.isSustainNote)
				destroyNote(characterStrums, coolNote);
		}
			//
	}

	function missNoteCheck(?includeAnimation:Bool = false, direction:Int = 0, character:Character, popMiss:Bool = false, lockMiss:Bool = false)
	{
		if (includeAnimation)
		{
			var stringDirection:String = UIStaticArrow.getArrowFromNumber(direction);
			var altString:String = '';

			if ((((SONG.notes[Math.floor(curStep / 16)] != null) && (SONG.notes[Math.floor(curStep / 16)].altAnim)) && (character.isAlt))
				|| sectionAlt)
			{
				if (altString != 'ALT')
					altString = 'ALT';
				else
					altString = '';
			}

			if (!Init.trueSettings.get('Disable Miss Sounds'))
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			character.playAnim('sing' + stringDirection.toUpperCase() + altString + 'miss', lockMiss);
		}
		decreaseCombo(popMiss);

		//
	}
	// Had to change this function up so the Alts work with the player too - doubletime32
	function characterPlayAnimation(coolNote:Note, character:Character)
	{
		// alright so we determine which animation needs to play
		// get alt strings and stuffs
		var stringArrow:String = '';
		var altString:String = '';

		var baseString = 'sing' + UIStaticArrow.getArrowFromNumber(coolNote.noteData).toUpperCase();

		// I tried doing xor and it didnt work lollll
		if (coolNote.noteAlt > 0)
			altString = '-alt';
		if ((((SONG.notes[Math.floor(curStep / 16)] != null) && (SONG.notes[Math.floor(curStep / 16)].altAnim))
			&& (character.isAlt)) || sectionAlt)

		{
			if (altString != '-alt')
				altString = '-alt';
			else
				altString = '';
		}

		stringArrow = baseString + altString;
		// if (coolNote.foreverMods.get('string')[0] != "")
		//	stringArrow = coolNote.noteString;

		character.playAnim(stringArrow, true);
		character.holdTimer = 0;

		if (stageBuild.sandyTail != null && stageBuild.sandyTail.visible)
			stageBuild.sandyTail.destroy();
	}

	// This function is made and used for doodlebob singing alongside doodleBF as a backup - doubletime32
	function doodlebobBackup()
	{
		if (sustainNoteLength < 8)
			dadOpponent.playAnim(directionCall);
		if (sustainNoteLength >= 8 && directionCall == 'LEFTLOOP')
			dadOpponent.playAnim('singLEFT', true);
		else if (sustainNoteLength >= 8 && directionCall == 'DOWNLOOP')
			dadOpponent.playAnim('singDOWN', true);
		else if (sustainNoteLength >= 8 && directionCall == 'UPLOOP')
			dadOpponent.playAnim('singUP', true);
	}

	private function strumCallsAuto(cStrum:UIStaticArrow, ?callType:Int = 1, ?daNote:Note):Void
	{
		switch (callType)
		{
			case 1:
				// end the animation if the calltype is 1 and it is done
				if ((cStrum.animation.finished) && (cStrum.canFinishAnimation))
					cStrum.playAnim('static');
			default:
				// check if it is the correct strum
				if (daNote.noteData == cStrum.ID)
				{
					// if (cStrum.animation.curAnim.name != 'confirm')
					cStrum.playAnim('confirm'); // play the correct strum's confirmation animation (haha rhymes)

					// stuff for sustain notes
					if ((daNote.isSustainNote) && (!daNote.animation.curAnim.name.endsWith('holdend')))
						cStrum.canFinishAnimation = false; // basically, make it so the animation can't be finished if there's a sustain note below
					else
						cStrum.canFinishAnimation = true;
				}
		}
	}

	private function mainControls(daNote:Note, char:Character, strumline:Strumline, autoplay:Bool):Void
	{
		var notesPressedAutoplay = [];

		// here I'll set up the autoplay functions
		if (autoplay)
		{
			// check if the note was a good hit
			if (daNote.strumTime <= Conductor.songPosition)
			{
				// use a switch thing cus it feels right idk lol
				// make sure the strum is played for the autoplay stuffs
				/*
					charStrum.forEach(function(cStrum:UIStaticArrow)
					{
						strumCallsAuto(cStrum, 0, daNote);
					});
				 */

				// kill the note, then remove it from the array
				var canDisplayJudgement = false;
				if (strumline.displayJudgements)
				{
					canDisplayJudgement = true;
					for (noteDouble in notesPressedAutoplay)
					{
						if (noteDouble.noteData == daNote.noteData)
						{
							// if (Math.abs(noteDouble.strumTime - daNote.strumTime) < 10)
							canDisplayJudgement = false;
							// removing the fucking check apparently fixes it
							// god damn it that stupid glitch with the double judgements is annoying
						}
						//
					}
					notesPressedAutoplay.push(daNote);
				}
				goodNoteHit(daNote, char, strumline, canDisplayJudgement);
			}
			//
		} 

		var holdControls:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		if (!autoplay) {
			// check if anything is held
			if (holdControls.contains(true))
			{
				// check notes that are alive
				strumline.allNotes.forEachAlive(function(coolNote:Note)
				{
					if ((coolNote.parentNote != null && coolNote.parentNote.wasGoodHit)
					&& coolNote.canBeHit && coolNote.mustPress
					&& !coolNote.tooLate && coolNote.isSustainNote
					&& holdControls[coolNote.noteData])
						goodNoteHit(coolNote, char, strumline);
				});
			}
		}
	}

	private function strumCameraRoll(cStrum:FlxTypedGroup<UIStaticArrow>, mustHit:Bool)
	{
		if (!Init.trueSettings.get('No Camera Note Movement'))
		{
			var camDisplaceExtend:Float = 15;
			if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if ((PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && mustHit && !sectionAlt)
					|| (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && !mustHit))
				{
					camDisplaceX = 0;
					if (cStrum.members[0].animation.curAnim.name == 'confirm')
						camDisplaceX -= camDisplaceExtend;
					if (cStrum.members[3].animation.curAnim.name == 'confirm')
						camDisplaceX += camDisplaceExtend;
					
					camDisplaceY = 0;
					if (cStrum.members[1].animation.curAnim.name == 'confirm')
						camDisplaceY += camDisplaceExtend;
					if (cStrum.members[2].animation.curAnim.name == 'confirm')
						camDisplaceY -= camDisplaceExtend;

				}
			}
		}
		//
	}

	override public function onFocus():Void
	{
		if (!paused)
			updateRPC(false);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		updateRPC(true);
		super.onFocusLost();
	}

	public static function updateRPC(pausedRPC:Bool)
	{
		#if !html5
		var displayRPC:String = (pausedRPC) ? detailsPausedText : songDetails;

		if (underwearHealth > -2)
		{
			if (Conductor.songPosition > 0 && !pausedRPC)
				Discord.changePresence(displayRPC, detailsSub, iconRPC, true, songLength - Conductor.songPosition);
			else
				Discord.changePresence(displayRPC, detailsSub, iconRPC);
		}
		#end
	}

	var animationsPlay:Array<Note> = [];

	function popUpScore(baseRating:String, strumline:Strumline, coolNote:Note)
	{
		// set up the rating
		var score:Int = 50;

		// notesplashes
		if (baseRating == "sick")
			// create the note splash if you hit a sick
			createSplash(coolNote, strumline);
		else
 			// if it isn't a sick, and you had a sick combo, then it becomes not sick :(
			if (allSicks)
				allSicks = false;

		displayRating(baseRating);
		Timings.updateAccuracy(Timings.judgementsMap.get(baseRating)[3]);
		score = Std.int(Timings.judgementsMap.get(baseRating)[2]);

		if (!practiceMode)
			songScore += score;

		popUpCombo();
	}

	public function createSplash(coolNote:Note, strumline:Strumline)
	{
		// play animation in existing notesplashes
		var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		if (strumline.splashNotes != null)
			strumline.splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom, true);
	}

	private var createdColor = FlxColor.fromRGB(204, 66, 66);

	function popUpCombo(?cache:Bool = false)
	{
		var comboString:String = Std.string(combo);
		var negative = false;
		if ((comboString.startsWith('-')) || (combo == 0))
			negative = true;
		var stringArray:Array<String> = comboString.split("");
		// deletes all combo sprites prior to initalizing new ones
		if (lastCombo != null)
		{
			while (lastCombo.length > 0)
			{
				lastCombo[0].kill();
				lastCombo.remove(lastCombo[0]);
			}
		}

		for (scoreInt in 0...stringArray.length)
		{
			// numScore.loadGraphic(Paths.image('UI/' + pixelModifier + 'num' + stringArray[scoreInt]));
			var numScore = ForeverAssets.generateCombo('combo', stringArray[scoreInt], (!negative ? allSicks : false), assetModifier, changeableSkin, 'UI',
				negative, createdColor, scoreInt);
			var offsetJudge = 0;
			if (curSong.toLowerCase() == 'plan-z')
			{
				numScore.x += 400;
				numScore.y += 30;
			}
			if (curSong.toLowerCase() == 'pimpin')
			{
				numScore.x -= 775;
			}
			else if (curSong.toLowerCase() == 'scrapped-metal')
			{
				numScore.y += 285;
			}
			else if (curSong.toLowerCase() == 'on-ice')
			{
				numScore.y -= 240;
				numScore.x -= 238;
			}

			else if (curSong.toLowerCase() == 'nuts-and-bolts')
			{
				numScore.y += 82;
				numScore.x -= 70;
			}
			if (allSicks || missOffset)
			{
				offsetJudge = 30;
				numScore.y += offsetJudge;
			}
			add(numScore);
			// hardcoded lmao
			if (!Init.trueSettings.get('Simply Judgements'))
			{
				add(numScore);
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.kill();
					},
					startDelay: Conductor.crochet * 0.002
				});
			}
				numScore.x += 100;
		}
		missOffset = false;
	}

	function decreaseCombo(?popMiss:Bool = false)
	{
		// painful if statement
		if (((combo > 5) || (combo < 0)) && (gf.animOffsets.exists('sad')))
			gf.playAnim('sad');

		if (combo > 0)
			combo = 0; // bitch lmao
		else
			combo--;

		// misses
		if (!practiceMode)
			songScore -= 10;
		misses++;
		uiHUD.updateHealth(false);

		// display negative combo
		if (popMiss)
		{
			// doesnt matter miss ratings dont have timings
			if (allSicks)
				allSicks = false;
			displayRating("miss");
		}
		popUpCombo();

		// gotta do it manually here lol
		Timings.updateFCDisplay();
	}

	function increaseCombo(?baseRating:String, ?direction = 0, ?character:Character)
	{
		// trolled this can actually decrease your combo if you get a bad/shit/miss
		if (baseRating != null)
		{
			if (Timings.judgementsMap.get(baseRating)[3] > 0)
			{
				if (combo < 0)
					combo = 0;
				combo += 1;
			}
			else
				missNoteCheck(true, direction, character, false, true);
		}
	}

	public function displayRating(daRating:String, ?cache:Bool = false)
	{
		/* so you might be asking
			"oh but if the rating isn't sick why not just reset it"
			because miss judgements can pop, and they dont mess with your sick combo
		 */
		 if (daRating == 'miss')
			missOffset = true;
		var rating = ForeverAssets.generateRating('$daRating', (daRating == 'sick' ? allSicks : false), assetModifier, changeableSkin, 'UI');
		rating.scale.x = 1.2;
		rating.scale.y = 1.2;
		add(rating);

		if (!Init.trueSettings.get('Simply Judgements'))
		{	
			add(rating);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					rating.kill();
				},
				startDelay: Conductor.crochet * 0.00125
			});
		}
		else
		{
			if (lastRating != null) {
				lastRating.kill();
			}
			add(rating);
			lastRating = rating;
			FlxTween.tween(rating, {y: rating.y + 20}, 0.2, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
			FlxTween.tween(rating, {"scale.x": 0, "scale.y": 0}, 0.1, {
				onComplete: function(tween:FlxTween)
				{
					rating.kill();
				},
				startDelay: Conductor.crochet * 0.00125
			});
		}
		// */

		if (!cache) {
			if (Init.trueSettings.get('Fixed Judgements')) {
				// bound to camera
				rating.cameras = [camHUD];
				rating.screenCenter();
			}
			
			// return the actual rating to the array of judgements
			Timings.gottenJudgements.set(daRating, Timings.gottenJudgements.get(daRating) + 1);

			// set new smallest rating
			if (Timings.smallestRating != daRating) {
				if (Timings.judgementsMap.get(Timings.smallestRating)[0] < Timings.judgementsMap.get(daRating)[0])
					Timings.smallestRating = daRating;
			}
		}
	}

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (fishAnnouncer != null && practiceMode)
			fishAnnouncer.destroy();

		if (!paused)
		{
			songMusic.play();
			songMusic.onComplete = endSong;
			vocals.play();

			resyncVocals();

			#if !html5
			// Song duration in a float, useful for the time left feature
			songLength = songMusic.length;

			// Updating Discord Rich Presence (with Time Left)
			updateRPC(false);
			#end
		}
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		songDetails = CoolUtil.dashToSpace(SONG.song) + ' - ' + CoolUtil.difficultyFromNumber(storyDifficulty);

		// String for when the game is paused
		detailsPausedText = "Paused - " + songDetails;

		// set details for song stuffs
		detailsSub = "";

		// Updating Discord Rich Presence.
		updateRPC(false);

		curSong = songData.song;
		songMusic = new FlxSound().loadEmbedded(Paths.inst(SONG.song), false, true);

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song), false, true);
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);

		// generate the chart
		unspawnNotes = ChartLoader.generateChartType(SONG, determinedChartType);
		// sometime my brain farts dont ask me why these functions were separated before

		// sort through them
		unspawnNotes.sort(sortByShit);
		// give the game the heads up to be able to start
		generatedMusic = true;

		Timings.accuracyMaxCalculation(unspawnNotes);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function resyncVocals():Void
	{
		//trace('resyncing vocal time ${vocals.time}');
		songMusic.pause();
		vocals.pause();
		Conductor.songPosition = songMusic.time;
		vocals.time = Conductor.songPosition;
		songMusic.play();
		vocals.play();
		//trace('new vocal time ${Conductor.songPosition}');
	}

	override function stepHit()
	{
		super.stepHit();
		///*
		if ((songMusic.length - Conductor.songPosition) > 100)
		{
			if (songMusic.time >= Conductor.songPosition + 20 || songMusic.time <= Conductor.songPosition - 20)
				resyncVocals();
		}
		//*/

		if ((curStep == 407 || curStep == 415) && curSong.toLowerCase() == 'doodle-duel')
			sectionAlt = !sectionAlt;

		if (curStep == 758 && curSong.toLowerCase() == 'doodle-duel')
		{
			dadOpponent.playAnim('doodleFINISH', true);
			stageBuild.smokeFade = 0;
			doodleBF.visible = true;
			ClassHUD.iconP2.animation.play('duel', true);
			doodleBF.playAnim('poppingOUT', true);
		}

		if (curStep == 704 && curSong.toLowerCase() == 'doodle-duel')
			dadOpponent.playAnim('doodle', true);

		if (curStep == 728 && curSong.toLowerCase() == 'doodle-duel')
			dadOpponent.playAnim('doodleFLIPOFF', true);

		if (curStep == 1151 && curSong.toLowerCase() == 'doodle-duel')
			dadOpponent.playAnim('meSPONGEBOB', true);

		if (curStep == 1375 && curSong.toLowerCase() == 'doodle-duel')
			playTogether = true;

		if (curStep == 1234 && curSong.toLowerCase() == 'plan-z')
		{
			boyfriend.playAnim('scat', true);
			alphaFade = 0;
			defaultCamZoom = 1.28;
		}

		if (curStep == 1269 && curSong.toLowerCase() == 'plan-z')
			boyfriend.playAnim('bop', true);

		if (curStep == 1272 && curSong.toLowerCase() == 'plan-z')
		{
			FlxG.camera.shake(0.07, 0.1);
			FlxG.camera.zoom += 0.2;
			boyfriend.playAnim('goofyGOOBER', true);
		}

		if ((curStep == 1234 || curStep == 1301) && curSong.toLowerCase() == 'plan-z')
			scatScene = !scatScene;

		if (curStep == 1290 && curSong.toLowerCase() == 'plan-z')
			alphaFade = 1;

		// Right here is how the doodlebob backup works and what it tracks - doubletime32
		if (curStep > 1310 && curStep < 1375 && curSong.toLowerCase() == 'doodle-duel')
		{
			if (curStep == 1312)
				storeStep = curStep;
			if (storeStep != curStep && sustainNoteLength < 8)
				{
					sustainNoteLength++;
					storeStep = curStep;
					doodlebobBackup();
				}
				if(curStep == 1312 || curStep == 1360)
				{
					sustainNoteLength = 0;
					directionCall = 'LEFTLOOP';
				}
				if(curStep == 1328)
				{
					sustainNoteLength = 0;
					directionCall = 'UPLOOP';
				}
				if(curStep == 1344)
				{
					sustainNoteLength = 0;
					directionCall = 'DOWNLOOP';
				}
				if(curStep == 1356)
				{
					sustainNoteLength = 0;
					directionCall = 'RIGHTLOOP';
				}
		}
	}

	private function charactersDance(curBeat:Int)
	{
		if (stageBuild.gfExist)
		{
			if ((curBeat % gfSpeed == 0)
				&& ((gf.animation.curAnim.name.startsWith("idle") 
			|| gf.animation.curAnim.name.startsWith("dance"))))
				gf.dance();
		}

		if ((boyfriend.animation.curAnim.name.startsWith("idle") 
		|| boyfriend.animation.curAnim.name.startsWith("dance")) 
			&& (curBeat % 2 == 0 || boyfriend.characterData.quickDancer))
			boyfriend.dance();

		// added this for opponent cus it wasn't here before and skater would just freeze

		if ((dadOpponent.animation.curAnim.name.startsWith("idle")
			|| dadOpponent.animation.curAnim.name.startsWith("dance"))  
				&& (curBeat % 2 == 0 || dadOpponent.characterData.quickDancer))
				dadOpponent.dance();

		if (stageBuild.doodleBFExist)
		{
			if ((doodleBF.animation.curAnim.name.startsWith("idle") 
			|| doodleBF.animation.curAnim.name.startsWith("dance"))
				&& (curBeat % 2 == 0 || doodleBF.characterData.quickDancer))
				doodleBF.dance();
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if ((curBeat == 177 || curBeat == 328 || curBeat == 289 || curBeat == 344) && curSong.toLowerCase() == 'doodle-duel')
			switchOpponent = !switchOpponent;

		if ((curBeat == 191 && curSong.toLowerCase() == 'doodle-duel') || (curBeat == 465 && curSong.toLowerCase() == 'nuts-and-bolts') 
			|| (curBeat == 325 && curSong.toLowerCase() == 'plan-z'))
			idleAlt = true;
		if (curBeat == 289 && curSong.toLowerCase() == 'doodle-duel')
			idleAlt = false;

		if (curBeat == 192 && curSong.toLowerCase() == 'doodle-duel')
			dadOpponent.dance();

		if (curBeat == 28 && curSong.toLowerCase() == 'nuts-and-bolts')
			dadOpponent.playAnim('taunt', true);

		if (curBeat == 352 && curSong.toLowerCase() == 'nuts-and-bolts')
			dadOpponent.playAnim('canOFWHOOP', true);

		if (curBeat == 464 && curSong.toLowerCase() == 'nuts-and-bolts')
			dadOpponent.playAnim('transition', true);

		if (curBeat == 325 && curSong.toLowerCase() == 'plan-z')
		{
			if (!Init.trueSettings.get('Disable Flashing Lights'))
				FlxG.camera.flash(FlxColor.WHITE, 2);
			else
				FlxG.camera.flash(FlxColor.BLACK, 2);
			ggSponge = true;
			dadOpponent.color = FlxColor.fromHSL(0, 0, 0.6);
			gf.color = FlxColor.fromHSL(0, 0, 0.6);
			stageBuild.krabs.color = FlxColor.fromHSL(0, 0, 0.6);
			stageBuild.krustyKrabDancersBG.forEach(function(dancer:FlxSprite)
			{
				dancer.color = FlxColor.fromHSL(0, 0, 0.6);
			});
			stageBuild.krustyKrabDancersFG.forEach(function(dancer:FlxSprite)
			{
				dancer.color = FlxColor.fromHSL(0, 0, 0.6);
			});
		}

		if (curBeat == 329 && curSong.toLowerCase() == 'plan-z')
			FlxTween.tween(boyfriend, {y: -180}, 4, {ease: FlxEase.sineInOut});

		if (curBeat >= 336 && curSong.toLowerCase() == 'plan-z')
			defaultCamZoom = 0.6;

		if (curBeat == 220 && curSong.toLowerCase() == 'scrapped-metal')
			dadOpponent.playAnim('barnacleHEAD', true);

		if (curBeat == 14 && curSong.toLowerCase() == 'pimpin')
			dadOpponent.playAnim('money', true);

		if ((FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) && (!Init.trueSettings.get('Reduced Movements')) && !scatScene)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.05;
			for (hud in strumHUD)
				hud.zoom += 0.05;
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
			}
		}

		//
		charactersDance(curBeat);

		// stage stuffs
		stageBuild.stageUpdate(curBeat, boyfriend, gf, dadOpponent);
	}

	//
	//
	/// substate stuffs
	//
	//

	public static function resetMusic()
	{
		// simply stated, resets the playstate's music for other states and substates
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			// trace('null song');
			if (songMusic != null)
			{
				//	trace('nulled song');
				songMusic.pause();
				vocals.pause();
				//	trace('nulled song finished');
			}

			// trace('ui shit break');
			if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = false;
		}

		// trace('open substate');
		super.openSubState(SubState);
		// trace('open substate end ');
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (songMusic != null && !startingSong)
				resyncVocals();

			if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = true;
			paused = false;

			///*
			updateRPC(false);
			// */
		}

		super.closeSubState();
	}

	function fixVocals()
	{
		if ((dadOpponent.animation.curAnim.name == 'meSPONGEBOB'
			|| dadOpponent.animation.curAnim.name == 'canOFWHOOP'
			|| dadOpponent.animation.curAnim.name == 'barnacleHEAD'
			|| dadOpponent.animation.curAnim.name == 'doodle'
			|| boyfriend.animation.curAnim.name == 'scat') && vocals.volume == 0)
			vocals.volume = 1;
	}

	/*
		Extra functions and stuffs
	 */
	/// song end function at the end of the playstate lmao ironic I guess
	private var endSongEvent:Bool = false;

	function endSong():Void
	{
	  #if android
	  androidControls.visible = false;
	  #end

		canPause = false;
		songMusic.volume = 0;
		vocals.volume = 0;
		if (!practiceMode)
		{
			if (curSong.toLowerCase() == 'doodle-duel' && !FlxG.save.data.doodleComplete)
				FlxG.save.data.doodleComplete = true;
			if (curSong.toLowerCase() == 'plan-z' && !FlxG.save.data.neptuneComplete)
				FlxG.save.data.neptuneComplete = true;
			if (curSong.toLowerCase() == 'pimpin' && !FlxG.save.data.pimpbobComplete)
				FlxG.save.data.pimpbobComplete = true;
			if (curSong.toLowerCase() == 'scrapped-metal' && !FlxG.save.data.squidComplete)
				FlxG.save.data.squidComplete = true;
			if (curSong.toLowerCase() == 'on-ice' && !FlxG.save.data.drinkComplete)
				FlxG.save.data.drinkComplete = true;
			
			if (SONG.validScore)
				Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			if (!isStoryMode)
			{
				if (misses == 0 && storyDifficulty == 2)
					checkAchievement();
				else
				{
					ForeverTools.resetMenuMusic();
					Main.switchState(this, new FreeplayState());
				}
			}
			else
			{
				// set the campaign's score higher
				campaignScore += songScore;
				// remove a song from the story playlist
				storyPlaylist.remove(storyPlaylist[0]);
				// check if there aren't any songs left
				if ((storyPlaylist.length <= 0) && (!endSongEvent))
				{
					// save the week's score if the score is valid
					if (SONG.validScore)
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					// flush the save
					FlxG.save.flush();
					// set up transitions
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					FlxG.save.data.storyComplete = true;

					if (misses == 0 && storyDifficulty == 2)
						checkAchievement();
					else
					{
						// play menu music
						ForeverTools.resetMenuMusic();

						// change to the menu state
						Main.switchState(this, new TitleState());
					}
				}
				else
					callDefaultSongEnd();
			}
		}
		else
		{
			paused = true;
			openSubState(new PracticeResultSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
	}

	private function checkAchievement()
	{
		if ((!FlxG.save.data.achievement1 && curSong.toLowerCase() == 'on-ice')
			|| (!FlxG.save.data.achievement2 && curSong.toLowerCase() == 'nuts-and-bolts')
			|| (!FlxG.save.data.achievement3 && curSong.toLowerCase() == 'doodle-duel')
			|| (!FlxG.save.data.achievement4 && curSong.toLowerCase() == 'plan-z')
			|| (!FlxG.save.data.achievement5 && curSong.toLowerCase() == 'pimpin')
			|| (!FlxG.save.data.achievement6 && curSong.toLowerCase() == 'scrapped-metal'))
		{
			paused = true;
			openSubState(new AchievementGetSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
		else
		{
			ForeverTools.resetMenuMusic();
			if (!isStoryMode)
				Main.switchState(this, new FreeplayState());
			else
				Main.switchState(this, new TitleState());
		}
	}

	private function callDefaultSongEnd()
	{
		var difficulty:String = '-' + CoolUtil.difficultyFromNumber(storyDifficulty).toLowerCase();
		difficulty = difficulty.replace('-normal', '');

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
		ForeverTools.killMusic([songMusic, vocals]);

		// deliberately did not use the main.switchstate as to not unload the assets
		FlxG.switchState(new PlayState());
	}

	public function songIntroCutscene()
	{
		switch (curSong.toLowerCase())
		{
			default:
				startCountdown();
		}
		//
	}

	public static function skipCutscenes():Bool {
		// pretty messy but an if statement is messier
		if (Init.trueSettings.get('Skip Text') != null
		&& Std.isOfType(Init.trueSettings.get('Skip Text'), String)) {
			switch (cast(Init.trueSettings.get('Skip Text'), String))
			{
				case 'never':
					return false;
				case 'freeplay only':
					if (!isStoryMode)
						return true;
					else
						return false;
				default:
					return true;
			}
		}
		return false;
	}

	public static var swagCounter:Int = 0;

	private function startCountdown():Void
	{
	  #if android
	  androidControls.visible = true;
	  #end

		inCutscene = false;
		Conductor.songPosition = -(Conductor.crochet * 5);
		swagCounter = 0;

		camHUD.visible = true;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			startedCountdown = true;

			charactersDance(curBeat);

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', [
				ForeverTools.returnSkinAsset('ready', assetModifier, changeableSkin, 'UI'),
				ForeverTools.returnSkinAsset('set', assetModifier, changeableSkin, 'UI'),
				ForeverTools.returnSkinAsset('go', assetModifier, changeableSkin, 'UI')
			]);

			var introAlts:Array<String> = introAssets.get('default');
			for (value in introAssets.keys())
			{
				if (value == PlayState.curStage)
					introAlts = introAssets.get(value);
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3-' + assetModifier), 0.6);
					fishAnnouncer.animation.play('speak', true);
					Conductor.songPosition = -(Conductor.crochet * 4);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (assetModifier == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * PlayState.daPixelZoom));

					ready.screenCenter();
					ready.y -= 110;
					ready.antialiasing = true;
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2-' + assetModifier), 0.6);
					fishAnnouncer.animation.play('speak', true);

					Conductor.songPosition = -(Conductor.crochet * 3);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (assetModifier == 'pixel')
						set.setGraphicSize(Std.int(set.width * PlayState.daPixelZoom));

					set.screenCenter();
					set.y -= 110;
					set.antialiasing = true;
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1-' + assetModifier), 0.6);
					fishAnnouncer.animation.play('speak', true);

					Conductor.songPosition = -(Conductor.crochet * 2);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (assetModifier == 'pixel')
						go.setGraphicSize(Std.int(go.width * PlayState.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					go.y -= 120;
					go.antialiasing = true;
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
							FlxTween.tween(fishAnnouncer, {x: fishAnnouncer.x + 300, y: fishAnnouncer.y + 30}, 0.6, {ease:FlxEase.sineInOut, onComplete: function(tween:FlxTween)
							{
								fishAnnouncer.destroy();
							}});
						}
					});
					FlxG.sound.play(Paths.sound('introGo-' + assetModifier), 0.6);
					fishAnnouncer.animation.play('go', true);

					Conductor.songPosition = -(Conductor.crochet * 1);
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}
}
