package meta.state.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;

using StringTools;

class CreditState extends MusicBeatState
{
    var bg:FlxSprite;
	var grpFrames:FlxTypedGroup<FlxSprite>;

	var mouseOverlap:Bool = false;
	var frameSelected:Bool = false;
	var finishedTween:Bool = false;
	var onTween:Bool = false;
	
	var nextRow:Int = 0;
	var spot:Int = 0;
	var curSelected:Int = 0;
	var black:FlxSprite;
	var selectedFrame:FlxSprite;
	var descriptionBG:FlxSprite;

	var employeeName:Array<String> = ['AshyTown', 'Barnacle', 'The Egg Overlord', 'Mari_Chan', 'PumpkinCity', 'Numberless', 'Vivian Katsura', 'GoggledAnimations', 
	'Random Angel', 'COOLTE3YET', 'NOMIE', 'doubletime32', 'Decoy', 'Vibe', 'TheGrams31', 'TheGonzfam', 'Lettush', 'Frog', 'Shroom', 'Juliaa', 'sirj455', 'TylerTheGamer', 
	'JigglyGD', 'Cybbr', 'Ovron'];
	var workedDescription:Array<String> = ['-Director And Artist\n-Krusty Krab Background Dancers\n-Main Menu And Pimpbob Background\n-Designed Robosandy Sprites\n-Designed RoboSquidward Sprites\n-Designed GF Sprites\n-Designed The Main Menu Buttons\n-Designed Robosandy Achievement\nIcon\n-Made The Main Discord RPC Icon\n-Designed Health System And Icons\nFor Robosandy, Neptune, Doodlebob\n', 
		'-Artist\n-Doodlebob Sprites\n-Spongebob Sprites For Plan Z\n-Designed Background For Plan Z\n-BG And Sprites For On Ice\n-Made The EOTM Wall And Frames\n-Made Achievement Background\n-Designed The Bamboo Frame\n-Designed The Golden Spatula\n-Designed The Bubble Arrows\n-Made The Health Icons For\nSping, Spongebob, Fsh\n', 
		'-Artist\n-Designed The Neptune Sprites\n',
		'-Artist\n-Designed Robosandy\'s Background\n', 
		'-Artist\n-Designed BF Sprites\n-Designed DoodleBF Sprites\n-Designed Options Background\n-Designed Stripper Patrick\n-Designed Freeplay Menu\n-Designed Achievement Icons\n-Made Health Icons for\nPimpbob, Robosquid, DoodleBF\n-Animated Neptune Sprites\n', 
		'-Artist\n-Made Promotional And Roster Art\n-Made Discord RPC Icons For Songs\n-Designed The Logo\n', 
		'-Artist\n-Designed Main Menu Spongebob\n-Designed Pimpbob Sprites\n-Animated GF In Pimpin\n', 
		'-Artist\n-Extended The Robosquid BG\n', 
		'-Artist\n-Made The Pimpin GF Sprites\n', 
		'-Artist\n-Designed Doodlebob\'s Background\n', 
		'-Artist\n-Made The Robosquid BG\n', 
		'-Lead Coder And Voice Actor\n-Coded 95% Of FFBB\n-Optimized Every Sprite In The Files\nTo Run On Low End Devices\n-Charted The Other Difficulties\n-Designed Shiny Object Sprite\n-Designed Splash In Pause Menu\n-Designed Bubbles For Particles And\nOptions\n-Voice Acted Plankton\n', 
		'-Coder And Charter\n-Ported On Ice To Forever Engine\n-Setup The Discord RPC\n-Charted Plan Z\n-Removed Unnecessary Files\n-Uploaded Source Code', 
		'-Coder\n-Removed Unnecessary Files\n-Changed Some Initial Stage Setup\n-Added Funny Things To The Files\n', 
		'-Musician\n-Composed Nuts And Bolts\n-Composed Pimpin\n', 
		'-Musician And Voice Actor\n-Composed Plan Z\n-Voice Acted Fish Announcer\n', 
		'-Musician\n-Composed The Main Menu Music\n-Composed The Pause Menu Music\n-Composed The Game Over Music\n', 
		'-Musician\n-Composed Doodle Duel\n', 
		'-Musician\n-Composed Scrapped Metal\n-Composed On Ice\n', 
		'-Charter\n-Charted Nuts And Bolts\n-Charted Scrapped Metal\n', 
		'-Charter\n-Charted Doodle Duel\n-Charted On Ice\n-Charted Pimpin\n', 
		'-Voice Actor\n-Voice Acted Robosquid\n-Voice Acted Pimpbob\n', 
		'-Voice Actor\n-Voice Acted Neptune\n', 
		'-Voice Actor\n-Voice Acted Plan Z Spongebob\n', 
		'-Voice Actor\n-Voice Acted French Narrator\n'];
	var employee:FlxText;
	var description:FlxText;

    override function create()
    {
        super.create();

		bg = new FlxSprite().loadGraphic(Paths.image('menus/base/credits/employeeOfTheMonth'));
		bg.antialiasing = true;
		add(bg);

		grpFrames = new FlxTypedGroup<FlxSprite>();
		add(grpFrames);
		for (i in 0...employeeName.length)
		{
			if (i % 8 == 0)
			{
				nextRow += 143;
				spot = 0;
			}
			var frame:FlxSprite = new FlxSprite(50 + (spot * 150), 5 + nextRow);
			frame.loadGraphic(Paths.image('menus/base/credits/CreditRoster'), true, 522, 636);
			frame.setGraphicSize(Std.int(frame.width * 0.21));
			frame.animation.frameIndex = i;
			frame.antialiasing = true;
			frame.ID = i;
			frame.updateHitbox();
			grpFrames.add(frame);
			spot++;
		}

		var describe:FlxText = new FlxText(195, 590, "Use The Mouse To Navigate And Click On A Frame To\nView The Employee. Press Your Back Button To Exit Out The Employee\n(Only V1 Credits Are Listed)\n");
		describe.setFormat(Paths.font("sponge.otf"), 24, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		describe.antialiasing = true;
		add(describe);

		black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		black.screenCenter();
		black.alpha = 0;
		add(black);

		selectedFrame = new FlxSprite();
		selectedFrame.loadGraphic(Paths.image('menus/base/credits/CreditRoster'), true, 522, 636);
		selectedFrame.antialiasing = true;
		selectedFrame.screenCenter();
		selectedFrame.x -= 335;
		selectedFrame.alpha = 0;
		add(selectedFrame);

		employee = new FlxText(0, 55);
		employee.setFormat(Paths.font("sponge.otf"), 55, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		employee.antialiasing = true;
		employee.alpha = 0;
		add(employee);

		descriptionBG = new FlxSprite(FlxG.width * 0.5, 800);
		descriptionBG.loadGraphic(Paths.image('menus/base/credits/workedOn'));
		descriptionBG.antialiasing = true;
		descriptionBG.alpha = 0;
		add(descriptionBG);

		description = new FlxText();
		description.setFormat(Paths.font("sponge.otf"), 18, FlxColor.YELLOW, LEFT);
		description.antialiasing = true;
		description.alpha = 0;
		add(description);

		#if android
		addVirtualPad(NONE, B);
		#end

		FlxG.mouse.visible = true;
		FlxG.mouse.enabled = true;
		FlxG.mouse.useSystemCursor = true;
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		employee.text = employeeName[curSelected];
		description.text = workedDescription[curSelected];
		employee.x = descriptionBG.getMidpoint().x - (employee.width - (employee.width / 2));
		description.x = descriptionBG.getMidpoint().x - 218;
		description.y = descriptionBG.getMidpoint().y - 160;
		description.alpha = descriptionBG.alpha;

		selectedFrame.animation.frameIndex = curSelected;

		if (controls.BACK)
			if (finishedTween && !onTween)
				selectFrame();
			else if (!finishedTween && !onTween)
				Main.switchState(this, new TitleState());

		grpFrames.forEach(function(spr:FlxSprite)
		{
			if (!mouseOverlap)
				spr.setGraphicSize(Std.int(spr.width * 1));
			
			if (!frameSelected && !mouseOverlap && FlxG.mouse.overlaps(spr))
			{
				mouseOverlap = true;
				curSelected = spr.ID;
				changeScale();
			}
			if (!frameSelected && !finishedTween && FlxG.mouse.overlaps(spr) && FlxG.mouse.justPressed)
				selectFrame();
			if (!FlxG.mouse.overlaps(spr) && !frameSelected && !finishedTween && mouseOverlap && curSelected == spr.ID)
				mouseOverlap = false;
		});
	}

	function changeScale()
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		grpFrames.forEach(function(spr:FlxSprite)
		{
			if (curSelected == spr.ID)
				FlxTween.tween(grpFrames.members[curSelected].scale, {x: 0.23, y: 0.23}, 0.1, {ease: FlxEase.sineOut, onComplete:function(tween:FlxTween)
				{
					if (curSelected != spr.ID)
						spr.setGraphicSize(Std.int(spr.width * 1));
				}});
			else
				spr.setGraphicSize(Std.int(spr.width * 1));
		});
	}

	function selectFrame()
	{
		onTween = true;
		if (!frameSelected)
		{
			frameSelected = true;
			FlxTween.tween(black, {alpha: 0.7}, 0.2);
			FlxTween.tween(employee, {alpha: 1}, 0.2);
			FlxTween.tween(descriptionBG, {alpha: 1}, 0.2);
			FlxTween.tween(descriptionBG, {y:170}, 0.2, {ease: FlxEase.sineOut});
			FlxTween.tween(selectedFrame, {alpha: 1}, 0.2, {onComplete: function(tween:FlxTween)
			{
				finishedTween = true;
				onTween = false;
			}});
		}
		else
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			frameSelected = false;
			FlxTween.tween(black, {alpha: 0}, 0.2);
			FlxTween.tween(employee, {alpha: 0}, 0.2);
			FlxTween.tween(descriptionBG, {alpha: 0}, 0.2);
			FlxTween.tween(descriptionBG, {y: 800}, 0.2, {ease: FlxEase.sineIn});
			FlxTween.tween(selectedFrame, {alpha: 0}, 0.2, {onComplete: function(tween:FlxTween)
			{
				finishedTween = false;
				onTween = false;
			}});
		}
	}
}