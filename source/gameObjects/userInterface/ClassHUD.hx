package gameObjects.userInterface;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import meta.CoolUtil;
import meta.InfoHud;
import meta.data.Conductor;
import meta.data.Timings;
import meta.state.PlayState;

using StringTools;

class ClassHUD extends FlxTypedGroup<FlxBasic>
{
	// set up variables and stuff here
	var infoBar:FlxText; // small side bar like kade engine that tells you engine info
	var scoreBar:FlxText;

	var scoreLast:Float = -1;
	var scoreDisplay:String;

	private var timeBarBG:FlxSprite;
	private var timeBar:FlxBar;

	public static var healthBFBB:FlxSprite;
	public static var underwearHealthGroup:FlxTypedGroup<FlxSprite>;
	public static var practiceText:FlxText;

	private var SONG = PlayState.SONG;
	public var iconP1:HealthIcon;
	public static var iconP2:HealthIcon;
	private var stupidHealth:Float = 0;

	public var timeCheck:Float = 0;
	public var timeText:FlxText;
	public var timeEnabled:Bool = false;

	private var timingsMap:Map<String, FlxText> = [];

	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();

		// fnf mods
		var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop';

		var timeY = 16.00;
		var icon1Y = FlxG.height * 0.760;
		var icon2Y = FlxG.height * 0.720;
		if (Init.trueSettings.get('Downscroll'))
		{
			timeY = FlxG.height * 0.965;
			icon1Y = 20;
			icon2Y = 2;
		}

		timeCheck = 100 / PlayState.songMusic.length;
		if (Init.trueSettings.get('Timer Bar'))
			timeEnabled = true;

		if (Init.trueSettings.get('Timer Bar'))
		{
			timeBarBG = new FlxSprite(0,
				timeY).loadGraphic(Paths.image(ForeverTools.returnSkinAsset('timerBar', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
			timeBarBG.screenCenter(X);
			timeBarBG.scrollFactor.set();
			timeBarBG.visible = timeEnabled;
			add(timeBarBG);

			timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8));
			timeBar.scrollFactor.set();
			timeBar.createFilledBar(FlxColor.BLACK, FlxColor.YELLOW);
			timeBar.numDivisions = 10000;
			timeBar.visible = timeEnabled;
			add(timeBar);

			timeText = new FlxText(0, timeY + 16);
			timeText.setFormat(Paths.font("sponge.ttf"), 32, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			timeText.screenCenter(X);
			timeText.x -= 27;
			if (Init.trueSettings.get('Downscroll'))
				timeText.y = timeY - 38;
			timeText.scrollFactor.set();
			timeText.visible = timeEnabled;
			add(timeText);
		}

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.x = FlxG.width * 0.735;
		iconP1.y = icon1Y;
		iconP1.setGraphicSize(Std.int(iconP1.width * 0.725));
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.x = FlxG.width * 0.008;
		iconP2.y = icon2Y;
		iconP2.setGraphicSize(Std.int(iconP2.width * 0.855));
		add(iconP2);

		// This process I coded makes the healthbar animation for the opponent without the need of an XML - doubletime32
		healthBFBB = new FlxSprite(iconP2.x + 193.94, iconP2.y + 119.8);
		healthBFBB.loadGraphic(Paths.image('UI/default/base/HP'), true, 174, 51);
		healthBFBB.setGraphicSize(Std.int(healthBFBB.width * 0.84));
		add(healthBFBB);

		// This process I've created makes a group of underwear sprites as health so we don't need 6 different pictures of the sprite
		// in the files to save space - doubletime32
		underwearHealthGroup = new FlxTypedGroup<FlxSprite>();
		add(underwearHealthGroup);
		for (i in 0...6)
		{
			var underwearTrack:FlxSprite = new FlxSprite((iconP1.x + 92.94) - (i * 57), iconP1.y + 80.8);
			underwearTrack.loadGraphic(Paths.image('UI/default/base/Underwear'), true, 81, 81);
			underwearTrack.setGraphicSize(Std.int(underwearTrack.width * 0.75));
			underwearTrack.antialiasing = true;
			underwearTrack.ID = i;
			underwearHealthGroup.add(underwearTrack);
		}

		// This right here tracks each of those individual sprites and makes them move up and down at a random value and time
		// to give it the proper bubble movement just like in the game ;) - doubletime32
		underwearHealthGroup.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {y: FlxG.random.float(iconP1.y + 82.7, iconP1.y + 78.12)}, FlxG.random.float(0.9, 1.5), {ease: FlxEase.sineInOut, type: PINGPONG});
		});

		practiceText = new FlxText(0, 150);
		practiceText.text = 'Practice Mode';
		practiceText.setFormat(Paths.font("sponge.otf"), 32, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		practiceText.screenCenter(X);
		practiceText.visible = false;
		FlxTween.tween(practiceText, {alpha: 0}, 1, {type: PINGPONG});
		add(practiceText);

		scoreBar = new FlxText(FlxG.width / 2, ((Init.trueSettings.get('Downscroll')) ? 50 : (FlxG.height * 0.835)), 0, scoreDisplay, 20);
		scoreBar.setFormat(Paths.font("sponge.otf"), 16, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		updateScoreText();
		scoreBar.scrollFactor.set();
		scoreBar.antialiasing = true;
		scoreBar.visible = true;
		add(scoreBar);

		// counter
		if (Init.trueSettings.get('Counter') != 'None') {
			var judgementNameArray:Array<String> = [];
			for (i in Timings.judgementsMap.keys())
				judgementNameArray.insert(Timings.judgementsMap.get(i)[0], i);
			judgementNameArray.sort(sortByShit);
			for (i in 0...judgementNameArray.length) {
				var textAsset:FlxText = new FlxText(5 + (!left ? (FlxG.width - 10) : 0),
					(FlxG.height / 2)
					- (counterTextSize * (judgementNameArray.length / 2))
					+ (i * counterTextSize), 0,
					'', counterTextSize);
				if (!left)
					textAsset.x -= textAsset.text.length * counterTextSize;
				textAsset.setFormat(Paths.font("vcr.ttf"), counterTextSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				textAsset.scrollFactor.set();
				timingsMap.set(judgementNameArray[i], textAsset);
				add(textAsset);
			}
		}
		updateScoreText();
	}

	var counterTextSize:Int = 18;

	function sortByShit(Obj1:String, Obj2:String):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Timings.judgementsMap.get(Obj1)[0], Timings.judgementsMap.get(Obj2)[0]);

	var left = (Init.trueSettings.get('Counter') == 'Left');

	override public function update(elapsed:Float)
	{
		if (Init.trueSettings.get('Timer Bar'))
		{
			timeBar.percent = Conductor.songPosition * timeCheck;
			timeText.text = FlxStringUtil.formatTime(Std.int((PlayState.songMusic.length - Conductor.songPosition) / 1000), false);
		}

		// Opponent health drain - doubletime32
		healthBFBB.animation.frameIndex = PlayState.drainHealth;

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (PlayState.practiceMode)
		{
			practiceText.visible = true;
			PlayState.songScore = 0;
		}
		else
			practiceText.visible = false;

		if (PlayState.underwearHealth <= 1)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBFBB.animation.frameIndex >= 6)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;
	}

	private final divider:String = ' - ';

	public function updateScoreText()
	{
		var importSongScore = PlayState.songScore;
		var importPlayStateCombo = PlayState.combo;
		var importMisses = PlayState.misses;
		scoreBar.text = 'Shinies: $importSongScore';
		// testing purposes
		var displayAccuracy:Bool = Init.trueSettings.get('Display Accuracy');
		if (displayAccuracy)
		{
			scoreBar.text += divider + 'Accuracy: ' + Std.string(Math.floor(Timings.getAccuracy() * 100) / 100) + '%' + Timings.comboDisplay;
			scoreBar.text += divider + 'Combo Breaks: ' + Std.string(PlayState.misses);
			scoreBar.text += divider + 'Rank: ' + Std.string(Timings.returnScoreRating().toUpperCase());
		}

		scoreBar.x = ((FlxG.width / 2) - (scoreBar.width / 2));

		// update counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			for (i in timingsMap.keys()) {
				timingsMap[i].text = '${(i.charAt(0).toUpperCase() + i.substring(1, i.length))}: ${Timings.gottenJudgements.get(i)}';
				timingsMap[i].x = (5 + (!left ? (FlxG.width - 10) : 0) - (!left ? (6 * counterTextSize) : 0));
			}
		}

		// update playstate
		PlayState.detailsSub = scoreBar.text;
		PlayState.updateRPC(false);
	}

	// Player health system - doubletime32
	public function updateHealth(inputHealthTrack:Bool)
	{
		if (!inputHealthTrack)
		{
			PlayState.underwearHealth--;
			PlayState.underwearHealthHeal = 0.3;
			if (PlayState.underwearHealth >= -1)
			{
				underwearHealthGroup.members[PlayState.underwearHealth + 1].alpha = PlayState.underwearHealthHeal;
				if (PlayState.underwearHealth < 4)
					underwearHealthGroup.members[PlayState.underwearHealth + 2].alpha = PlayState.underwearHealthHeal;
			}
		}
		else if (inputHealthTrack)
		{
			if (PlayState.underwearHealth >= -1)
			{
				PlayState.underwearHealthHeal = PlayState.underwearHealthHeal + 0.1;
				underwearHealthGroup.members[PlayState.underwearHealth + 1].alpha = PlayState.underwearHealthHeal;
				if (PlayState.underwearHealthHeal >= 1)
				{
					PlayState.underwearHealth++;
					PlayState.underwearHealthHeal = 0.3;
				}

			}
		}
	}
}
