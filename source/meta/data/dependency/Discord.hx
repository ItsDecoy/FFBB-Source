package meta.data.dependency;

#if !html5
import discord_rpc.DiscordRpc;
#end
import lime.app.Application;

/**
	Discord Rich Presence, both heavily based on Izzy Engine and the base game's, as well as with a lot of help 
	from the creator of izzy engine because I'm dummy and dont know how to program discord
**/
class Discord
{
	#if !html5
	// set up the rich presence initially
	public static function initializeRPC()
	{
		DiscordRpc.start({
			clientID: "962858524826800158",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});

		// THANK YOU GEDE
		Application.current.window.onClose.add(shutdownRPC);
	}

	// from the base game
	static function onReady()
	{
		DiscordRpc.presence({
			details: "",
			state: null,
			largeImageKey: 'freaky',
			largeImageText: "FNF in: Funkin for Bikini Bottom!"
		});
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	//

	/* This function contains a new installation at the end called 'icon' which will track the discord image being used for the certain states you're in the game.
		Due to 'largeImageKey' reading a String for a picture, the 'icon' variable that's a String is used for 'largeImageKey' to track for each song and state.
	    Me and Decoy spent a little while figuring this out and he's mainly responsible for the idea. We did get inspiration from Afton, so credits to them. - doubletime32 */
	public static function changePresence(details:String = '', state:Null<String> = '', ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float, ?icon: String)
	{
		var startTimestamp:Float = (hasStartTimestamp) ? Date.now().getTime() : 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: icon,
			largeImageText: "FNF in: Funkin for Bikini Bottom!",
			smallImageKey: smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});

		// trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}

	public static function shutdownRPC()
	{
		// borrowed from izzy engine -- somewhat, at least
		DiscordRpc.shutdown();
	}
	#end
}
