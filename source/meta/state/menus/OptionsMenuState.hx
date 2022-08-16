package meta.state.menus;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.menu.Checkmark;
import gameObjects.userInterface.menu.Selector;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;
import meta.data.dependency.FNFSprite;
import meta.subState.OptionsSubstate;

/**
	Options menu rewrite because I'm unhappy with how it was done previously
**/
class OptionsMenuState extends MusicBeatState
{
	private var categoryMap:Map<String, Dynamic>;
	private var activeSubgroup:FlxTypedGroup<FlxText>;
	private var attachments:FlxTypedGroup<FlxBasic>;

	var curSelection = 0;
	var curSelectedScript:Void->Void;
	var curCategory:String;
	var bubbles:FlxTypedGroup<FlxEmitter>;

	var lockedMovement:Bool = false;

	override public function create():Void
	{
		super.create();

		// define the categories
		/* 
			To explain how these will work, each main category is just any group of options, the options in the category are defined
			by the first array. The second array value defines what that option does.
			These arrays are within other arrays for information storing purposes, don't worry about that too much.
			If you plug in a value, the script will run when the option is hovered over.
		 */

		// NOTE : Make sure to check Init.hx if you are trying to add options.

		categoryMap = [
			'main' => [
				[
					['Gameplay', callNewGroup],
					['Accessibility', callNewGroup],
					['Controls', openControlmenu],
          #if android ['android controls', openAndroidControlmenu],#end
					['Exit', exitMenu]
				]
			],
			'Gameplay' => [
				[
					['Game Settings', null],
					['', null],
					['Downscroll', getFromOption],
					['Centered Notefield', getFromOption],
					['Timer Bar', getFromOption],
					['Disable Antialiasing', getFromOption],
					['Disable Miss Sounds', getFromOption],
					['Disable Death Lines', getFromOption],
					['FPS Counter', getFromOption],
					['Memory Counter', getFromOption],
					//['Debug Info', getFromOption],
				]
			],
			'Accessibility' => [
				[
					['Accessibility Settings', null],
					['', null],
					['Filter', getFromOption],
					["Stage Opacity", getFromOption],
					['Reduced Movements', getFromOption],
					['No Camera Note Movement', getFromOption],
					['Disable Flashing Lights', getFromOption]
				]
			]
		];

		for (category in categoryMap.keys())
		{
			categoryMap.get(category)[1] = returnSubgroup(category);
			categoryMap.get(category)[2] = returnExtrasMap(categoryMap.get(category)[1]);
		}

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

		infoText = new FlxText(5, FlxG.height - 29, 0, "", 32);
		infoText.setFormat(Paths.font("sponge.otf"), 18, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.textField.background = true;
		infoText.textField.backgroundColor = FlxColor.BLACK;
		infoText.antialiasing = true;
		add(infoText);

		loadSubgroup('main');

		#if android
		addVirtualPad(LEFT_FULL, A_B);
		#end
	}

	private var currentAttachmentMap:Map<FlxText, Dynamic>;

	function loadSubgroup(subgroupName:String)
	{
		// unlock the movement
		lockedMovement = false;

		// lol we wanna kill infotext so it goes over checkmarks later
		if (infoText != null)
			remove(infoText);

		// kill previous subgroup attachments
		if (attachments != null)
			remove(attachments);

		// kill previous subgroup if it exists
		if (activeSubgroup != null)
			remove(activeSubgroup);

		// load subgroup lmfao
		activeSubgroup = categoryMap.get(subgroupName)[1];
		add(activeSubgroup);

		// set the category
		curCategory = subgroupName;

		// add all group attachments afterwards
		currentAttachmentMap = categoryMap.get(subgroupName)[2];
		attachments = new FlxTypedGroup<FlxBasic>();
		for (setting in activeSubgroup)
			if (currentAttachmentMap.get(setting) != null)
				attachments.add(currentAttachmentMap.get(setting));
		add(attachments);

		// re-add
		add(infoText);
		regenInfoText();

		// reset the selection
		curSelection = 0;
		selectOption(curSelection);
	}

	function selectOption(newSelection:Int, playSound:Bool = true)
	{
		if ((newSelection != curSelection) && (playSound))
			FlxG.sound.play(Paths.sound('scrollMenu'));

		// direction increment finder
		var directionIncrement = ((newSelection < curSelection) ? -1 : 1);

		// updates to that new selection
		curSelection = newSelection;

		// wrap the current selection
		if (curSelection < 0)
			curSelection = activeSubgroup.length - 1;
		else if (curSelection >= activeSubgroup.length)
			curSelection = 0;

		// set the correct group stuffs lol
		for (i in 0...activeSubgroup.length)
		{
			activeSubgroup.members[i].alpha = 0.6;
			if (currentAttachmentMap != null)
				setAttachmentAlpha(currentAttachmentMap.get(activeSubgroup.members[i]), 0.6);

			// check for null members and hardcode the dividers
			if (categoryMap.get(curCategory)[0][i][1] == null) {
				activeSubgroup.members[i].alpha = 1;
			}
		}

		activeSubgroup.members[curSelection].alpha = 1;
		if (currentAttachmentMap != null)
			setAttachmentAlpha(currentAttachmentMap.get(activeSubgroup.members[curSelection]), 1);

		// what's the script of the current selection?
		for (i in 0...categoryMap.get(curCategory)[0].length)
			if (categoryMap.get(curCategory)[0][i][0] == activeSubgroup.members[curSelection].text)
				curSelectedScript = categoryMap.get(curCategory)[0][i][1];
		// wow thats a dumb check lmao

		// skip line if the selected script is null (indicates line break)
		if (curSelectedScript == null)
			selectOption(curSelection + directionIncrement, false);
	}

	function setAttachmentAlpha(attachment:FlxSprite, newAlpha:Float)
	{
		// oddly enough, you can't set alphas of objects that arent directly and inherently defined as a value.
		// ya flixel is weird lmao
		if (attachment != null)
			attachment.alpha = newAlpha;
		// therefore, I made a script to circumvent this by defining the attachment with the `attachment` variable!
		// pretty neat, huh?
	}

	var infoText:FlxText;
	var finalText:String;
	var textValue:String = '';
	var infoTimer:FlxTimer;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// just uses my outdated code for the main menu state where I wanted to implement
		// hold scrolling but I couldnt because I'm dumb and lazy
		if (!lockedMovement)
		{
			// check for the current selection
			if (curSelectedScript != null)
				curSelectedScript();

			updateSelections();
		}

		if (Init.gameSettings.get(activeSubgroup.members[curSelection].text) != null)
		{
			// lol had to set this or else itd tell me expected }
			var currentSetting = Init.gameSettings.get(activeSubgroup.members[curSelection].text);
			var textValue = currentSetting[2];
			if (textValue == null)
				textValue = "";

			if (finalText != textValue)
			{
				// trace('call??');
				// trace(textValue);
				regenInfoText();

				var textSplit = [];
				finalText = textValue;
				textSplit = finalText.split("");

				var loopTimes = 0;
				infoTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
				{
					//
					infoText.text += textSplit[loopTimes];
					infoText.screenCenter(X);

					loopTimes++;
				}, textSplit.length);
			}
		}

		// move the attachments if there are any
		for (setting in currentAttachmentMap.keys())
		{
			if ((setting != null) && (currentAttachmentMap.get(setting) != null))
			{
				var thisAttachment = currentAttachmentMap.get(setting);
				thisAttachment.x = setting.x - 100;
				thisAttachment.y = setting.y - 50;
			}
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (curCategory != 'main')
				loadSubgroup('main');
			else
				Main.switchState(this, new TitleState());
		}
	}

	private function regenInfoText()
	{
		if (infoTimer != null)
			infoTimer.cancel();
		if (infoText != null)
			infoText.text = "";
	}

	function updateSelections()
	{
		var up = controls.UP;
		var down = controls.DOWN;
		var up_p = controls.UI_UP_P;
		var down_p = controls.UI_DOWN_P;
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
							selectOption(curSelection - 1);
						else if (i == 3)
							selectOption(curSelection + 1);
					}
				}
				//
			}
		}
	}

	private function returnSubgroup(groupName:String):FlxTypedGroup<FlxText>
	{
		//
		var newGroup:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

		for (i in 0...categoryMap.get(groupName)[0].length)
		{
			if (Init.gameSettings.get(categoryMap.get(groupName)[0][i][0]) == null
				|| Init.gameSettings.get(categoryMap.get(groupName)[0][i][0])[3] != Init.FORCED)
			{
				var thisOption:FlxText = new FlxText(450, 145, 0, categoryMap.get(groupName)[0][i][0], 50);
				if (groupName == 'main')
				{
					thisOption.setFormat(Paths.font("sponge.otf"), 70, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					thisOption.screenCenter(X);
				}
				else
				{
					thisOption.setFormat(Paths.font("sponge.otf"), 40, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					thisOption.y = 0;
					if ((categoryMap.get(groupName)[0][i][1]) == null)
					{
						thisOption.setFormat(Paths.font("sponge.otf"), 70, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						thisOption.screenCenter(X);
						thisOption.y += 30;
					}
				}
				// hardcoded main so it doesnt have scroll
				if (groupName == 'main')
					thisOption.y += (110 * i);
				else if (groupName == 'Gameplay')
					thisOption.y += (70 * i);
				else if (groupName == 'Accessibility')
					thisOption.y += (95 * i);
				thisOption.alpha = 0.6;
				thisOption.antialiasing = true;
				newGroup.add(thisOption);
			}
		}

		return newGroup;
	}

	private function returnExtrasMap(alphabetGroup:FlxTypedGroup<FlxText>):Map<FlxText, Dynamic>
	{
		var extrasMap:Map<FlxText, Dynamic> = new Map<FlxText, Dynamic>();
		for (letter in alphabetGroup)
		{
			if (Init.gameSettings.get(letter.text) != null)
			{
				switch (Init.gameSettings.get(letter.text)[1])
				{
					case Init.SettingTypes.Checkmark:
						// checkmark
						var checkmark = ForeverAssets.generateCheckmark(10, letter.y, 'bubblesCheckbox', 'base', 'default', 'UI');
						checkmark.playAnim(Std.string(Init.trueSettings.get(letter.text)) + ' finished');

						extrasMap.set(letter, checkmark);
					case Init.SettingTypes.Selector:
						// selector
						var selector:Selector = new Selector(10, letter.y, letter.text, Init.gameSettings.get(letter.text)[4],
							(letter.text == 'Stage Opacity') ? true : false);

						extrasMap.set(letter, selector);
					default:
						// dont do ANYTHING
				}
				//
			}
		}

		return extrasMap;
	}

	/*
		This is the base option return
	 */
	public function getFromOption()
	{
		if (Init.gameSettings.get(activeSubgroup.members[curSelection].text) != null)
		{
			switch (Init.gameSettings.get(activeSubgroup.members[curSelection].text)[1])
			{
				case Init.SettingTypes.Checkmark:
					// checkmark basics lol
					if (controls.ACCEPT)
					{
						FlxG.sound.play(Paths.sound('confirmMenu'));
						lockedMovement = true;
						FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
						{
							// LMAO THIS IS HUGE
							Init.trueSettings.set(activeSubgroup.members[curSelection].text,
								!Init.trueSettings.get(activeSubgroup.members[curSelection].text));
							updateCheckmark(currentAttachmentMap.get(activeSubgroup.members[curSelection]),
								Init.trueSettings.get(activeSubgroup.members[curSelection].text));

							// save the setting
							Init.saveSettings();
							lockedMovement = false;
						});
					}
				case Init.SettingTypes.Selector:
					#if !html5
					var selector:Selector = currentAttachmentMap.get(activeSubgroup.members[curSelection]);

					if (!controls.LEFT)
						selector.selectorPlay('left');
					if (!controls.RIGHT)
						selector.selectorPlay('right');

					if (controls.UI_RIGHT_P)
						updateSelector(selector, 1);
					else if (controls.UI_LEFT_P)
						updateSelector(selector, -1);
					#end
				default:
					// none
			}
		}
	}

	function updateCheckmark(checkmark:FNFSprite, animation:Bool) {
		if (checkmark != null)
			checkmark.playAnim(Std.string(animation));
	}

	function updateSelector(selector:Selector, updateBy:Int)
	{
		var bgdark = selector.darkBG;
		if (bgdark)
		{
			// lazily hardcoded darkness cap
			var originaldark = Init.trueSettings.get(activeSubgroup.members[curSelection].text);
			var increase = 5 * updateBy;
			if (originaldark + increase < 0)
				increase = 0;
			// high darkness cap
			if (originaldark + increase > 100)
				increase = 0;

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('scrollMenu'));

			originaldark += increase;
			selector.chosenOptionString = Std.string(originaldark);
			selector.optionChosen.text = Std.string(originaldark);
			Init.trueSettings.set(activeSubgroup.members[curSelection].text, originaldark);
			Init.saveSettings();
		}
		else
		{ 
			// get the current option as a number
			var storedNumber:Int = 0;
			var newSelection:Int = storedNumber;
			if (selector.options != null) {
				for (curOption in 0...selector.options.length)
				{
					if (selector.options[curOption] == selector.optionChosen.text)
						storedNumber = curOption;
				}
				
				newSelection = storedNumber + updateBy;
				if (newSelection < 0)
					newSelection = selector.options.length - 1;
				else if (newSelection >= selector.options.length)
					newSelection = 0;
			}

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('scrollMenu'));

			selector.chosenOptionString = selector.options[newSelection];
			selector.optionChosen.text = selector.chosenOptionString;

			Init.trueSettings.set(activeSubgroup.members[curSelection].text, selector.chosenOptionString);
			Init.saveSettings();
		}
	}

	public function callNewGroup()
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				loadSubgroup(activeSubgroup.members[curSelection].text);
			});
		}
	}

	#if android
	public function openAndroidControlmenu()
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				#if android
				removeVirtualPad();
				#end
				openSubState(new android.AndroidControlsSubState());
				lockedMovement = false;
			});
		}
	}
	#end

	public function openControlmenu()
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				openSubState(new OptionsSubstate());
				lockedMovement = false;
			});
		}
	}

	public function exitMenu()
	{
		//
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				Main.switchState(this, new TitleState());
				lockedMovement = false;
			});
		}
		//
	}
}
