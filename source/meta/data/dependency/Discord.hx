package meta.data.dependency;

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
		// THANK YOU GEDE
		Application.current.window.onClose.add(shutdownRPC);
	}

	// from the base game
	static function onReady()
	{
		/*DiscordRpc.presence({
			details: "",
			state: null,
			largeImageKey: 'iconog',
			largeImageText: "Forever Engine"
		});*/
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

	public static function changePresence(details:String = '', state:Null<String> = '', ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		var startTimestamp:Float = (hasStartTimestamp) ? Date.now().getTime() : 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		// trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}

	public static function shutdownRPC()
	{
		// borrowed from izzy engine -- somewhat, at least
	}
	#end
}
