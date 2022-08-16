package meta.state.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.effects.particles.FlxEmitter;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;

using StringTools;

class AchievementsState extends MusicBeatState
{
    public var text:Array<String> = ['My Drink', 'Losing Your Head', 'Destroyer Of Evil', 'All Hail Plankton', 'Cha Ching', 'Mediocre', 
                                     'Get Bitches'];
	public var grpAchieveText:FlxTypedGroup<FlxText>;
	var achievementUnlock:Array<Dynamic> = [
		FlxG.save.data.achievement1,							
		FlxG.save.data.achievement2,
		FlxG.save.data.achievement3,
		FlxG.save.data.achievement4,
		FlxG.save.data.achievement5,
		FlxG.save.data.achievement6,
		FlxG.save.data.achievement7,
	];
	
	var descriptionArray:Array<String> = [
		'Get 0 misses on on-ice on the hardest difficulty',
		'Get 0 misses on nuts-and-bolts on the hardest difficulty',
		'Get 0 misses on doodle-duel on the hardest difficulty',
		'Get 0 misses on plan-z on the hardest difficulty',
		'Get 0 misses on pimpin on the hardest difficulty',
		'Get 0 misses on scrapped-metal on the hardest difficulty',
		'Go out and get some bitches (0% Of Players Unlocked This)'];

	var goldenSpatulaCount:Array<Int> = [1, 0, 1, 2, 3, 4, 5];

	var squeakSound:Int = 1;
	var curSelected:Int = 0;
	var description:FlxText;
	var bubbles:FlxTypedGroup<FlxEmitter>;

    override function create()
    {
        super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/base/achievements/IMG_6825'));
		bg.screenCenter();
		bg.setGraphicSize(Std.int(bg.width * 1.05));
		bg.color = FlxColor.fromHSL(0, 0, 0.5);
		add(bg);

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

        grpAchieveText = new FlxTypedGroup<FlxText>();
        add(grpAchieveText);
        for (i in 0...text.length)
        {
			var achieve:FlxText = new FlxText(550, 80 + (i * 80), text[i]);
			achieve.setFormat(Paths.font("sponge.otf"), 30, FlxColor.YELLOW, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if (goldenSpatulaCount[i] > FlxG.save.data.spat)
				achieve.text = '???';
			achieve.antialiasing = true;
			achieve.ID = i;
			grpAchieveText.add(achieve);
        }

		for (i in 2...9)
		{
			var icon:FlxSprite = new FlxSprite(grpAchieveText.members[0].x - 150, (grpAchieveText.members[0].y - 220) + (i * 80));
			icon.loadGraphic(Paths.image('menus/base/achievements/achievementGrid'), true, 160, 160);
			icon.animation.add('icon', [0, 1, i], 0, false);
			icon.animation.play('icon');
			icon.setGraphicSize(Std.int(icon.width * 0.45));
			if (goldenSpatulaCount[i-2] <= FlxG.save.data.spat)
			{
				if (achievementUnlock[i-2])
					icon.animation.frameIndex = i;
				else
					icon.animation.frameIndex = 1;
			}
			icon.antialiasing = true;
			add(icon);
		}

		description = new FlxText(0, 670);
		description.setFormat(Paths.font("sponge.otf"), 25, FlxColor.YELLOW, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		description.antialiasing = true;
		add(description);

		changeSelection();

		#if android
		addVirtualPad(UP_DOWN, B);
		#end
  }

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		description.text = descriptionArray[curSelected];
		description.screenCenter(X);

		if (goldenSpatulaCount[curSelected] <= FlxG.save.data.spat)
			description.visible = true;
		else
			description.visible = false;

		if (squeakSound > 2)
			squeakSound = 1;

		if (controls.UI_DOWN_P)
		{
			FlxG.sound.play(Paths.sound('squeak' + squeakSound), 0.7);
			squeakSound++;
			changeSelection(1);
		}
		if (controls.UI_UP_P)
		{
			FlxG.sound.play(Paths.sound('squeak' + squeakSound), 0.7);
			squeakSound++;
			changeSelection(-1);
		}


        if (controls.BACK)
			Main.switchState(this, new TitleState());
    }

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = text.length - 1;
		if (curSelected >= text.length)
			curSelected = 0;

		grpAchieveText.forEach(function(txt:FlxText)
		{
			if (curSelected == txt.ID)
				txt.alpha = 1;
			else
				txt.alpha = 0.5;
		});
	}
}