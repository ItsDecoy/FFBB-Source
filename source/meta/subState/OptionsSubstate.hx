package meta.subState;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatSubState;

using StringTools;

class OptionsSubstate extends MusicBeatSubState
{
	private var curSelection = 0;
	private var submenuGroup:FlxTypedGroup<FlxBasic>;
	private var submenuoffsetGroup:FlxTypedGroup<FlxBasic>;
	private var submenuOffsetValue:FlxText;

	private var bubbles:FlxTypedGroup<FlxEmitter>;

	private var offsetTemp:Float;

	// the controls class thingy
	override public function create():Void
	{
		// call the options menu
		var bg = new FlxSprite(-85);
		bg.loadGraphic(Paths.image('menus/base/options/Pipes'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
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

		super.create();

		keyOptions = generateOptions();
		updateSelection();

		submenuGroup = new FlxTypedGroup<FlxBasic>();
		submenuoffsetGroup = new FlxTypedGroup<FlxBasic>();

		submenu = new FlxSprite(0, 0).makeGraphic(FlxG.width - 200, FlxG.height - 200, FlxColor.fromRGB(13, 14, 36));
		submenu.screenCenter();

		// submenu group
		var submenuText = new FlxText(0, 0, "Press any key to rebind");
		submenuText.setFormat(Paths.font("sponge.otf"), 60, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		submenuText.screenCenter();
		submenuText.updateHitbox();
		submenuText.y -= 80;
		submenuText.antialiasing = true;
		submenuGroup.add(submenuText);

		var submenuText2 = new FlxText(0, 0, "Escape to Cancel");
		submenuText2.setFormat(Paths.font("sponge.otf"), 60, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		submenuText2.screenCenter();
		submenuText2.y += 55;
		submenuText2.antialiasing = true;
		submenuGroup.add(submenuText2);

		// submenuoffset group
		// this code by codist
		var submenuOffsetText = new FlxText(0, 0, 0, "Left or Right to edit.");
		submenuOffsetText.setFormat(Paths.font("sponge.otf"), 60, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		submenuOffsetText.screenCenter();
		submenuOffsetText.y -= 160;
		submenuOffsetText.antialiasing = true;
		submenuoffsetGroup.add(submenuOffsetText);

		var submenuOffsetText2 = new FlxText(0, 0, 0, "Negative is Late");
		submenuOffsetText2.setFormat(Paths.font("sponge.otf"), 60, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		submenuOffsetText2.screenCenter();
		submenuOffsetText2.y -= 80;
		submenuOffsetText2.antialiasing = true;
		submenuoffsetGroup.add(submenuOffsetText2);

		var submenuOffsetText3 = new FlxText(0, 0, 0, "Escape to Cancel");
		submenuOffsetText3.setFormat(Paths.font("sponge.otf"), 60, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		submenuOffsetText3.screenCenter();
		submenuOffsetText3.y += 102;
		submenuOffsetText3.antialiasing = true;
		submenuoffsetGroup.add(submenuOffsetText3);

		var submenuOffsetText4 = new FlxText(0, 0, 0, "Enter to Save");
		submenuOffsetText4.setFormat(Paths.font("sponge.otf"), 60, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		submenuOffsetText4.screenCenter();
		submenuOffsetText4.y += 180;
		submenuOffsetText4.antialiasing = true;
		submenuoffsetGroup.add(submenuOffsetText4);

		submenuOffsetValue = new FlxText(0, 0, 0, "< 0ms >", 50, false);
		submenuOffsetValue.setFormat(Paths.font("sponge.otf"), 50, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		submenuOffsetValue.screenCenter();
		submenuOffsetValue.y += 15;
		submenuOffsetValue.antialiasing = true;
		submenuoffsetGroup.add(submenuOffsetValue);

		// alright back to my code :ebic:

		add(submenu);
		add(submenuGroup);
		add(submenuoffsetGroup);
		submenu.visible = false;
		submenuGroup.visible = false;
		submenuoffsetGroup.visible = false;

		#if android
		addVirtualPad(LEFT_FULL, A_B);
		addPadCamera();
		#end
	}

	private var keyOptions:FlxTypedGroup<FlxText>;
	private var otherKeys:FlxTypedGroup<FlxText>;

	private function generateOptions()
	{
		keyOptions = new FlxTypedGroup<FlxText>();

		var arrayTemp:Array<String> = [];
		// re-sort everything according to the list numbers
		for (controlString in Init.gameControls.keys()) {
			arrayTemp[Init.gameControls.get(controlString)[1]] = controlString;
		}
		arrayTemp.push("EDIT OFFSET"); // append edit offset to the end of the array

		for (i in 0...arrayTemp.length)
		{
			if (arrayTemp[i] == null)
				arrayTemp[i] = '';
			// generate key options lol
			var optionsText:FlxText = new FlxText(200, 70, 0, arrayTemp[i].replace("_"," "));
			optionsText.setFormat(Paths.font("sponge.otf"), 50, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionsText.y += (65 * i);
			optionsText.alpha = 0.4;
			keyOptions.add(optionsText);
		}

		// stupid shubs you always forget this
		add(keyOptions);

		generateExtra(arrayTemp);

		return keyOptions;
	}

	private function generateExtra(arrayTemp:Array<String>)
	{
		otherKeys = new FlxTypedGroup<FlxText>();
		for (i in 0...arrayTemp.length)
		{
			for (j in 0...2)
			{
				var keyString = "";

				if (Init.gameControls.exists(arrayTemp[i]))
					keyString = getStringKey(Init.gameControls.get(arrayTemp[i])[0][j]);

				var secondaryText:FlxText = new FlxText(600, 70, 0, keyString);
				secondaryText.setFormat(Paths.font("sponge.otf"), 50, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				secondaryText.y += (65 * i);
				secondaryText.x += (380 * j);
				secondaryText.alpha = 0.4;
				otherKeys.add(secondaryText);
			}
		}
		add(otherKeys);
	}

	private function getStringKey(arrayThingy:Dynamic):String
	{
		var keyString:String = 'none';
		if (arrayThingy != null)
		{
			var keyDisplay:FlxKey = arrayThingy;
			keyString = keyDisplay.toString();
		}

		keyString = keyString.replace(" ", "");

		return keyString;
	}

	private function updateSelection(equal:Int = 0)
	{
		if (equal != curSelection) 
			FlxG.sound.play(Paths.sound('scrollMenu'));
		var prevSelection:Int = curSelection;
		curSelection = equal;
		// wrap the current selection
		if (curSelection < 0)
			curSelection = keyOptions.length - 1;
		else if (curSelection >= keyOptions.length)
			curSelection = 0;

		//
		for (i in 0...keyOptions.length)
		{
			keyOptions.members[i].alpha = 0.6;
			//keyOptions.members[i].targetY = (i - curSelection) / 2;
		}
		keyOptions.members[curSelection].alpha = 1;

		///*
		for (i in 0...otherKeys.length)
		{
			otherKeys.members[i].alpha = 0.6;
			//otherKeys.members[i].targetY = (((Math.floor(i / 2)) - curSelection) / 2) - 0.25;
		}
		otherKeys.members[(curSelection * 2) + curHorizontalSelection].alpha = 1;
		// */
		if (keyOptions.members[curSelection].text == '' && curSelection != prevSelection)
			updateSelection(curSelection + (curSelection - prevSelection));
	}

	private var curHorizontalSelection = 0;

	private function updateHorizontalSelection()
	{
		var left = controls.LEFT_P;
		var right = controls.RIGHT_P;
		var horizontalControl:Array<Bool> = [left, false, right];

		if (horizontalControl.contains(true))
		{
			for (i in 0...horizontalControl.length)
			{
				if (horizontalControl[i] == true)
				{
					curHorizontalSelection += (i - 1);

					if (curHorizontalSelection < 0)
						curHorizontalSelection = 1;
					else if (curHorizontalSelection > 1)
						curHorizontalSelection = 0;

					// update stuffs
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}

			updateSelection(curSelection);
			//
		}
	}

	private var submenuOpen:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!submenuOpen)
		{
			var up = controls.UP;
			var down = controls.DOWN;
			var up_p = controls.UP_P;
			var down_p = controls.DOWN_P;
			var controlArray:Array<Bool> = [up, down, up_p, down_p];

			if (controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					// here we check which keys are pressed
					if (controlArray[i] == true)
					{
						// if single press
						if (i > 1)
						{
							// up is 2 and down is 3
							// paaaaaiiiiiiinnnnn
							if (i == 2)
								updateSelection(curSelection - 1);
							else if (i == 3)
								updateSelection(curSelection + 1);
						}
					}
					//
				}
			}

			//
			updateHorizontalSelection();

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				submenuOpen = true;

				FlxFlicker.flicker(otherKeys.members[(curSelection * 2) + curHorizontalSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
				{
					if (submenuOpen)
						openSubmenu();
				});
			}
			else if (controls.BACK)
			{
				#if android
				flixel.addons.transition.FlxTransitionableState.skipNextTransOut = true;
				FlxG.resetState();
				#else
				close();
				#end
			}
		}
		else
			subMenuControl();
	}

	override public function close()
	{
		//
		Init.saveControls(); // for controls
		Init.saveSettings(); // for offset
		super.close();
	}
	
	private var submenu:FlxSprite;

	private function openSubmenu()
	{
		offsetTemp = Init.trueSettings['Offset'];

		submenu.visible = true;
		if (curSelection != keyOptions.length - 1)
			submenuGroup.visible = true;
		else
			submenuoffsetGroup.visible = true;
	}

	private function closeSubmenu()
	{
		submenuOpen = false;

		submenu.visible = false;

		submenuGroup.visible = false;
		submenuoffsetGroup.visible = false;
	}

	private function subMenuControl()
	{
		// I dont really like hardcoded shit so I'm probably gonna change this lmao
		if (curSelection != keyOptions.length - 1)
		{
			// be able to close the submenu
			if (FlxG.keys.justPressed.ESCAPE)
				closeSubmenu();
			else if (FlxG.keys.justPressed.ANY)
			{
				// loop through existing keys and see if there are any alike
				var checkKey = FlxG.keys.getIsDown()[0].ID;

				// check if any keys use the same key lol
				/*
				for (i in 0...otherKeys.members.length)	{
					if (otherKeys.members[i].text == checkKey.toString())
					{
						// switch them I guess???
						var oldKey = Init.gameControls.get(keyOptions.members[curSelection].text)[0][curHorizontalSelection];
						Init.gameControls.get(keyOptions.members[otherKeys.members[i].controlGroupID].text)[0][otherKeys.members[i].extensionJ] = oldKey;
						otherKeys.members[i].text = getStringKey(oldKey);
					}
				}
				*/

				// now check if its the key we want to change
				Init.gameControls.get(keyOptions.members[curSelection].text)[0][curHorizontalSelection] = checkKey;
				otherKeys.members[(curSelection * 2) + curHorizontalSelection].text = getStringKey(checkKey);

				// refresh keys
				controls.setKeyboardScheme(None, false);

				// update all keys on screen to have the right values
				// inefficient so I rewrote it lolllll
				/*for (i in 0...otherKeys.members.length)
					{
						var stringKey = getStringKey(Init.gameControls.get(keyOptions.members[otherKeys.members[i].controlGroupID].text)[0][otherKeys.members[i].extensionJ]);
						trace('running $i times, options menu');
				}*/

				// close the submenu
				closeSubmenu();
			}
			//
		}
		else
		{
			if (FlxG.keys.justPressed.ENTER)
			{
				Init.trueSettings['Offset'] = offsetTemp;
				closeSubmenu();
			}
			else if (FlxG.keys.justPressed.ESCAPE)
				closeSubmenu();

			var move = 0;
			if (FlxG.keys.pressed.LEFT)
				move = -1;
			else if (FlxG.keys.pressed.RIGHT)
				move = 1;

			offsetTemp += move * 0.1;

			submenuOffsetValue.text = "< " + Std.string(Math.floor(offsetTemp * 10) / 10) + " >";
			submenuOffsetValue.screenCenter(X);
		}
	}
}
