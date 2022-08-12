package gameObjects;

/**
	The character class initialises any and all characters that exist within gameplay. For now, the character class will
	stay the same as it was in the original source of the game. I'll most likely make some changes afterwards though!
**/
import flixel.FlxG;
import flixel.addons.util.FlxSimplex;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import gameObjects.userInterface.HealthIcon;
import meta.*;
import meta.data.*;
import meta.data.dependency.FNFSprite;
import meta.state.PlayState;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef CharacterData = {
	var offsetX:Float;
	var offsetY:Float;
	var camOffsetX:Float;
	var camOffsetY:Float;
	var quickDancer:Bool;
}

class Character extends FNFSprite
{
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var isAlt:Bool = false;

	public var holdTimer:Float = 0;

	public var characterData:CharacterData;
	public var adjustPos:Bool = true;

	public function new(?isPlayer:Bool = false)
	{
		super(x, y);
		this.isPlayer = isPlayer;
	}

	public function setCharacter(x:Float, y:Float, character:String):Character
	{
		curCharacter = character;
		var tex:FlxAtlasFrames;
		antialiasing = true;

		characterData = {
			offsetY: 0,
			offsetX: 0, 
			camOffsetY: 0,
			camOffsetX: 0,
			quickDancer: false
		};

		switch (curCharacter)
		{
			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/MermaidGF');
				frames = tex;
				animation.addByIndices('danceLeft', 'MermaidGF', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'MermaidGF', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				playAnim('danceRight');

			case 'strip-pat':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/PatLegs');
				frames = tex;
				animation.addByIndices('danceLeft', 'PatLegs Idle', [28, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'PatLegs Idle', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27], "", 24, false);

				setGraphicSize(Std.int(width * 0.63));

				playAnim('danceRight');

			case 'gf-boat':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/GfBoat');
				frames = tex;
				animation.addByIndices('danceLeft', 'GF_BOAT', [16, 0, 1, 2, 3, 4, 5, 6], "", 12, false);
				animation.addByIndices('danceRight', 'GF_BOAT', [7, 8, 9, 10, 11, 12, 13, 14, 15], "", 12, false);

				playAnim('danceRight');

			case 'bf':
				frames = Paths.getSparrowAtlas('characters/BOYFRIEND');

				animation.addByPrefix('idle', 'fish bf idle', 12, false);
				animation.addByPrefix('singUP', 'fish bf up0', 12, false);
				animation.addByPrefix('singLEFT', 'fish bf left0', 12, false);
				animation.addByPrefix('singRIGHT', 'fish bf right0', 12, false);
				animation.addByPrefix('singDOWN', 'fish bf down0', 12, false);
				animation.addByPrefix('singUPmiss', 'fish bf up miss', 12, false);
				animation.addByPrefix('singLEFTmiss', 'fish bf left miss', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'fish bf right miss', 12, false);
				animation.addByPrefix('singDOWNmiss', 'fish bf down miss', 12, false);
				animation.addByPrefix('singUP-alt', 'fish bf scratch0', 12, false);
				animation.addByPrefix('singRIGHT-alt', 'fish bf scratch0', 12, false);
				animation.addByPrefix('singDOWN-alt', 'fish bf hey0', 12, false);
				animation.addByPrefix('singLEFT-alt', 'fish bf hey0', 12, false);		

				playAnim('idle');

				flipX = true;

				characterData.offsetY = 70;

			case 'bf-small':
				frames = Paths.getSparrowAtlas('characters/BOYFRIEND-SMALL');

				animation.addByPrefix('idle', 'fish bf small idle', 12, false);
				animation.addByPrefix('singUP', 'fish bf small up0', 12, false);
				animation.addByPrefix('singLEFT', 'fish bf small left0', 12, false);
				animation.addByPrefix('singRIGHT', 'fish bf small right0', 12, false);
				animation.addByPrefix('singDOWN', 'fish bf small down0', 12, false);
				animation.addByPrefix('singUPmiss', 'fish bf small up miss', 12, false);
				animation.addByPrefix('singLEFTmiss', 'fish bf small left miss', 12, false);
				animation.addByPrefix('singRIGHTmiss', 'fish bf small right miss', 12, false);
				animation.addByPrefix('singDOWNmiss', 'fish bf small down miss', 12, false);
				animation.addByPrefix('singUP-alt', 'fish bf small scratch0', 12, false);
				animation.addByPrefix('singRIGHT-alt', 'fish bf small scratch0', 12, false);
				animation.addByPrefix('singDOWN-alt', 'fish bf small hey0', 12, false);
				animation.addByPrefix('singLEFT-alt', 'fish bf small hey0', 12, false);

				playAnim('idle');

				flipX = true;

				characterData.offsetY = 70;

			case 'sandy':
				frames = Paths.getSparrowAtlas('characters/robosandy');
				animation.addByPrefix('idle', 'robosandy idle', 12, false);
				animation.addByPrefix('singUP', 'robosandy up', 12, false);
				animation.addByPrefix('singLEFT', 'robosandy left', 12, false);
				animation.addByPrefix('singRIGHT', 'robosandy right', 12, false);
				animation.addByPrefix('singDOWN', 'robosandy down', 12, false);
				animation.addByPrefix('taunt', 'robosandy taunt', 24, false);
				animation.addByPrefix('canOFWHOOP', 'robosandy whoop', 22, false);
				animation.addByPrefix('transition', 'robosandy transition', 24, false);
				animation.addByPrefix('idle-alt', 'robosandy angry idle', 12, false);
				animation.addByPrefix('singUP-alt', 'robosandy angry up', 12, false);
				animation.addByPrefix('singLEFT-alt', 'robosandy angry left', 12, false);
				animation.addByPrefix('singRIGHT-alt', 'robosandy angry right', 12, false);
				animation.addByPrefix('singDOWN-alt', 'robosandy angry down', 12, false);

				playAnim('idle');

				setGraphicSize(Std.int(width * 1.05));
				updateHitbox();
				isAlt = true;

				characterData.camOffsetY = 35;
				characterData.camOffsetX = -58;

			case 'squid':
				frames = Paths.getSparrowAtlas('characters/Robosquid');
				animation.addByPrefix('idle', 'Robosquid idle', 12, false);
				animation.addByPrefix('singUP', 'Robosquid up', 12, false);
				animation.addByPrefix('singLEFT', 'Robosquid left', 12, false);
				animation.addByPrefix('singRIGHT', 'Robosquid right', 12, false);
				animation.addByPrefix('singDOWN', 'Robosquid down', 12, false);
				animation.addByPrefix('barnacleHEAD', 'Robosquid taunt', 12, false);

				playAnim('idle');

				setGraphicSize(Std.int(width * 2.3));
				updateHitbox();

				characterData.camOffsetY = -200;
				characterData.camOffsetX = -310;

			case 'doodlebob':
				frames = Paths.getSparrowAtlas('characters/doodlebob');
				animation.addByPrefix('idle', 'doodlebob idle', 24, false);
				animation.addByPrefix('singUP', 'doodlebob up', 24, false);
				animation.addByPrefix('singLEFT', 'doodlebob left', 24, false);
				animation.addByPrefix('singRIGHT', 'doodlebob right', 24, false);
				animation.addByPrefix('singDOWN', 'doodlebob down', 24, false);
				animation.addByPrefix('UPLOOP', 'doodlebob loopUp', 24, true);
				animation.addByPrefix('LEFTLOOP', 'doodlebob loopLeft', 24, true);
				animation.addByPrefix('RIGHTLOOP', 'doodlebob loopRight', 24, true);
				animation.addByPrefix('DOWNLOOP', 'doodlebob loopDown', 24, true);
				animation.addByPrefix('meSPONGEBOB', 'doodlebob you', 12, false);
				animation.addByPrefix('idle-alt', 'doodlebob cheer', 24, false);
				animation.addByPrefix('doodle', 'doodlebob doodling', 12, false);
				animation.addByPrefix('doodleLOOP', 'doodlebob loopDoodle', 12, true);
				animation.addByPrefix('doodleFLIPOFF', 'doodlebob flipOff', 12, false);
				animation.addByPrefix('doodleFINISH', 'doodlebob finishedDoodle', 12, false);

				playAnim('idle');

				setGraphicSize(Std.int(width * 1.5));
				updateHitbox();

				characterData.camOffsetY = -85;
				characterData.camOffsetX = -360;

			case 'doodlebf':
				frames = Paths.getSparrowAtlas('characters/DoodleBF');
				animation.addByPrefix('idle', 'DoodleBF idle', 24, false);
				animation.addByPrefix('singUP', 'DoodleBF up', 24, false);
				animation.addByPrefix('singLEFT', 'DoodleBF left', 24, false);
				animation.addByPrefix('singRIGHT', 'DoodleBF right', 24, false);
				animation.addByPrefix('singDOWN', 'DoodleBF down', 24, false);
				animation.addByPrefix('poppingOUT', 'DoodleBF pop', 24, false);

				playAnim('idle');

				setGraphicSize(Std.int(width * 1.2));
				updateHitbox();

			case 'fsh':
				frames = Paths.getSparrowAtlas('characters/fsh');
				animation.addByPrefix('idle', 'fsh idle', 24);
				animation.addByPrefix('singUP', 'fsh up', 24);
				animation.addByPrefix('singRIGHT', 'fsh right', 24);
				animation.addByPrefix('singDOWN', 'fsh down', 24);
				animation.addByPrefix('singLEFT', 'fsh left', 24);

				//animation.play('idle');
				setGraphicSize(Std.int(width * 0.95));

				characterData.camOffsetY = 30;
				characterData.camOffsetX = 80;

			case 'sping':
				frames = Paths.getSparrowAtlas('characters/sping');
				animation.addByPrefix('idle', 'sping idle', 24, false);
				animation.addByPrefix('singUP', 'sping up0', 24, false);
				animation.addByPrefix('singLEFT', 'sping left0', 24, false);
				animation.addByPrefix('singRIGHT', 'sping right0', 24, false);
				animation.addByPrefix('singDOWN', 'sping down0', 24, false);

				setGraphicSize(Std.int(width * 0.82));

				characterData.camOffsetY = 35;
				characterData.camOffsetX = -55;

				playAnim('idle');

				flipX = true;

			case 'spongebob':
				frames = Paths.getSparrowAtlas('characters/spongebob');
				animation.addByPrefix('idle', 'spongebob idle', 24, false);
				animation.addByPrefix('singUP', 'spongebob up0', 24, false);
				animation.addByPrefix('singLEFT', 'spongebob left0', 24, false);
				animation.addByPrefix('singRIGHT', 'spongebob right0', 24, false);
				animation.addByPrefix('singDOWN', 'spongebob down0', 24, false);
				animation.addByPrefix('singUPmiss', 'spongebob miss up', 2, false);
				animation.addByPrefix('singLEFTmiss', 'spongebob miss left', 2, false);
				animation.addByPrefix('singRIGHTmiss', 'spongebob miss right', 2, false);
				animation.addByPrefix('singDOWNmiss', 'spongebob miss down', 2, false);
				animation.addByPrefix('scat', 'spongebob scatting', 10, true);
				animation.addByPrefix('bop', 'spongebob turn', 10, false);
				animation.addByPrefix('goofyGOOBER', 'spongebob goober', 10, false);
				animation.addByPrefix('idle-alt', 'spongebob airIdle', 12, false);
				animation.addByPrefix('singUP-alt', 'spongebob airUp', 24, false);
				animation.addByPrefix('singLEFT-alt', 'spongebob airLeft', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'spongebob airRight', 24, false);
				animation.addByPrefix('singDOWN-alt', 'spongebob airDown', 24, false);
				animation.addByPrefix('singUPALTmiss', 'spongebob miss airUp', 2, false);
				animation.addByPrefix('singLEFTALTmiss', 'spongebob miss airLeft', 2, false);
				animation.addByPrefix('singRIGHTALTmiss', 'spongebob miss airRight', 2, false);
				animation.addByPrefix('singDOWNALTmiss', 'spongebob miss airDown', 2, false);

				characterData.camOffsetY = -10;
				characterData.camOffsetX = 20;

				playAnim('idle');
				isAlt = true;

				flipX = true;
			
			case 'neptune':
				frames = Paths.getSparrowAtlas('characters/neptune');
				animation.addByPrefix('idle', 'neptune idle', 12, false);
				animation.addByPrefix('singUP', 'neptune up', 12, false);
				animation.addByPrefix('singLEFT', 'neptune left', 12, false);
				animation.addByPrefix('singRIGHT', 'neptune right', 12, false);
				animation.addByPrefix('singDOWN', 'neptune down', 12, false);

				playAnim('idle');

				setGraphicSize(Std.int(width * 1.4));

				characterData.camOffsetY = -85;
				characterData.camOffsetX = -165;

				updateHitbox();

			case 'pimpbob':
				frames = Paths.getSparrowAtlas('characters/pimpbob');
				animation.addByPrefix('idle', 'GANG_IDLE', 12, false);
				animation.addByPrefix('singUP', 'GANG_NOTE_UP', 24, false);
				animation.addByPrefix('singLEFT', 'GANG_NOTE_LEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'GANG_NOTE_RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'GANG_NOTE_DOWN', 24, false);
				animation.addByPrefix('singUP-alt', 'GANG_NOTE_UP', 24, false);
				animation.addByPrefix('singLEFT-alt', 'GANG_NOTE_LEFT', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'GANG_NOTE_RIGHT', 24, false);
				animation.addByPrefix('singDOWN-alt', 'GANG_NOTE_CORAL', 24, false);
				animation.addByPrefix('money', 'GANG_NOTE_THUMB', 12, false);

				playAnim('idle');
				isAlt = true;

				setGraphicSize(Std.int(width * 1.2));

				characterData.camOffsetY = -60;
				characterData.camOffsetX = -165;

				updateHitbox();

			default:
				// set up animations if they aren't already

				// fyi if you're reading this this isn't meant to be well made, it's kind of an afterthought I wanted to mess with and
				// I'm probably not gonna clean it up and make it an actual feature of the engine I just wanted to play other people's mods but not add their files to
				// the engine because that'd be stealing assets
				var fileNew = curCharacter + 'Anims';
				if (OpenFlAssets.exists(Paths.offsetTxt(fileNew)))
				{
					var characterAnims:Array<String> = CoolUtil.coolTextFile(Paths.offsetTxt(fileNew));
					var characterName:String = characterAnims[0].trim();
					frames = Paths.getSparrowAtlas('characters/$characterName');
					for (i in 1...characterAnims.length)
					{
						var getterArray:Array<Array<String>> = CoolUtil.getAnimsFromTxt(Paths.offsetTxt(fileNew));
						animation.addByPrefix(getterArray[i][0], getterArray[i][1].trim(), 24, false);
					}
				}
				else 
					return setCharacter(x, y, 'bf');
		}

		dance();

		if (isPlayer) // fuck you ninjamuffin lmao
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf') && !curCharacter.startsWith('spongebob') && !curCharacter.startsWith('sping'))
				flipLeftRight();
			//
		}
		else if (curCharacter.startsWith('bf') || curCharacter.startsWith('spongebob') || curCharacter.startsWith('sping'))
			flipLeftRight();

		if (adjustPos) {
			x += characterData.offsetX;
			//trace('character ${curCharacter} scale ${scale.y}');
			y += (characterData.offsetY - (frameHeight * scale.y));
		}

		this.x = x;
		this.y = y;
		
		return this;
	}

	function flipLeftRight():Void
	{
		// get the old right sprite
		var oldRight = animation.getByName('singRIGHT').frames;

		// set the right to the left
		animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;

		// set the left to the old right
		animation.getByName('singLEFT').frames = oldRight;

		// insert ninjamuffin screaming I think idk I'm lazy as hell

		if (animation.getByName('singRIGHTmiss') != null)
		{
			var oldMiss = animation.getByName('singRIGHTmiss').frames;
			animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
			animation.getByName('singLEFTmiss').frames = oldMiss;
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			/*if (curCharacter == 'fsh')
			{
				if (animation.getByName('singLEFT') != null
					|| animation.getByName('singUP') != null
					|| animation.getByName('singRIGHT') != null
					|| animation.getByName('singDOWN') != null)
				{
					holdTimer += elapsed;
				}
			}*/
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		var curCharSimplified:String = simplifyCharacter();
		switch (curCharSimplified)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
				if ((animation.curAnim.name.startsWith('sad')) && (animation.curAnim.finished))
					playAnim('danceLeft');
		}

		// Post idle animation (think Week 4 and how the player and mom's hair continues to sway after their idle animations are done!)
		if (animation.curAnim.finished && animation.curAnim.name == 'idle')
		{
				// We look for an animation called 'idlePost' to switch to
			if (animation.getByName('idlePost') != null)
					// (( WE DON'T USE 'PLAYANIM' BECAUSE WE WANT TO FEED OFF OF THE IDLE OFFSETS! ))
				animation.play('idlePost', true, false, 0);
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?forced:Bool = false)
	{
		if (!debugMode)
		{
			var curCharSimplified:String = simplifyCharacter();
			switch (curCharSimplified)
			{
				case 'gf':
					if ((!animation.curAnim.name.startsWith('hair')) && (!animation.curAnim.name.startsWith('sad')))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight', forced);
						else
							playAnim('danceLeft', forced);
					}
				case 'doodlebob' | 'sandy' | 'spongebob':
					if (PlayState.idleAlt)
						playAnim('idle-alt', forced);
					else
						playAnim('idle', forced);
				default:
					// Left/right dancing, think Skid & Pump
					if (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null) {
						danced = !danced;
						if (danced)
							playAnim('danceRight', forced);
						else
							playAnim('danceLeft', forced);
					}
					else
						playAnim('idle', forced);
			}
		}
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(AnimName) != null)
			super.playAnim(AnimName, Force, Reversed, Frame);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	public function simplifyCharacter():String
	{
		var base = curCharacter;

		if (base.contains('-'))
			base = base.substring(0, base.indexOf('-'));
		return base;
	}
}
