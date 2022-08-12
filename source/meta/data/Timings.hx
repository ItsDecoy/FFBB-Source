package meta.data;

import gameObjects.userInterface.notes.*;
import meta.state.PlayState;

/**
	Here's a class that calculates timings and judgements for the songs and such
**/
class Timings
{
	//
	public static var accuracy:Float;
	public static var trueAccuracy:Float;
	public static var judgementRates:Array<Float>;

	// from left to right
	// max milliseconds, score from it and percentage
	public static var judgementsMap:Map<String, Array<Dynamic>> = [
		"sick" => [0, 55, 350, 100, ' [SFC]'],
		"good" => [1, 80, 150, 75, ' [GFC]'],
		"bad" => [2, 100, 0, 25, ' [FC]'],
		"shit" => [3, 120, -50, -150],
		"miss" => [4, 140, -100, -175],
	];

	public static var msThreshold:Float = 0;
	public static var ratingFinal:String = "f";
	public static var notesHit:Int = 0;
	public static var segmentsHit:Int = 0;
	public static var comboDisplay:String = '';

	public static var gottenJudgements:Map<String, Int> = [];
	public static var smallestRating:String;

	public static function callAccuracy()
	{
		// reset the accuracy to 0%
		accuracy = 0.001;
		trueAccuracy = 0;
		judgementRates = new Array<Float>();

		// reset ms threshold
		var biggestThreshold:Float = 0;
		for (i in judgementsMap.keys())
			if (judgementsMap.get(i)[1] > biggestThreshold)
				biggestThreshold = judgementsMap.get(i)[1];
		msThreshold = biggestThreshold;

		// set the gotten judgement amounts
		for (judgement in judgementsMap.keys())
			gottenJudgements.set(judgement, 0);
		smallestRating = 'sick';

		notesHit = 0;
		segmentsHit = 0;

		ratingFinal = "f";

		comboDisplay = '';
	}

	/*
		You can create custom judgements here! just assign values to it as explained below.
		Null means that it is the highest judgement, meaning it doesn't get a check and is set automatically
	 */
	public static function accuracyMaxCalculation(realNotes:Array<Note>)
	{
		// first we split the notes and get a total note number
		var totalNotes:Int = 0;
		for (i in 0...realNotes.length)
		{
			if (realNotes[i].mustPress)
				totalNotes++;
		}
	}

	public static function updateAccuracy(judgement:Int, ?isSustain:Bool = false, ?segmentCount:Int = 1)
	{
		if (!isSustain) {
			notesHit++;
			accuracy += (Math.max(0, judgement));
		} else {
			accuracy += (Math.max(0, judgement) / segmentCount);
		}
		trueAccuracy = (accuracy / notesHit);
		/* Fixed a little engine bug with the ranking system. When you hit a single note on 100% accuracy it properly displays the rank S+. But after a long hold note,
		   when it's 100% accuracy it doesn't update properly to show the S+ rank so that has been fixed. I even had to fix more bugs with the other ranks. For example,
		   if you're at 95% accuracy and you don't hit a sick one time to get a 94% accuracy, it doesn't change the rank properly from a S to an A until another non-sick after.
		   This happens with any rank so all these statements below fixes these issues as well as having to delete the old system of getting the rankings (yeah had to go this
			way but it was the only way I saw it working. Still love your work Yoshubs :) ) - doubletime32 */
		if (trueAccuracy >= 100)
			ratingFinal = "S+";
		else if (trueAccuracy >= 95)
			ratingFinal = "S";
		else if (trueAccuracy >= 90)
			ratingFinal = "A";
		else if (trueAccuracy >= 85)
			ratingFinal = "B";
		else if (trueAccuracy >= 80)
			ratingFinal = "C";
		else if (trueAccuracy >= 75)
			ratingFinal = "D";
		else if (trueAccuracy >= 70)
			ratingFinal = "E";
		else if (trueAccuracy < 70)
			ratingFinal = "F";

		updateFCDisplay();
	}

	public static function updateFCDisplay()
	{
		// update combo display
		comboDisplay = '';
		if (judgementsMap.get(smallestRating)[4] != null)
			comboDisplay = judgementsMap.get(smallestRating)[4];

		// this updates the most so uh
		PlayState.uiHUD.updateScoreText();
	}

	public static function getAccuracy()
	{
		return trueAccuracy;
	}

	public static function returnScoreRating()
	{
		return ratingFinal;
	}
}
