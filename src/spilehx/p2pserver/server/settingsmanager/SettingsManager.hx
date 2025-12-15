package spilehx.p2pserver.server.settingsmanager;

class SettingsManager {
	private var applicationArguments:Array<CommandArg> = new Array<CommandArg>();

	@:isVar public var settings(get, set):SettingsData;

	public static final instance:SettingsManager = new SettingsManager();

	private function new() {
		applicationArguments.push(new CommandArg("url", "frameUrl", "Sets the URL of the content iFrame to load - if blank debug content shown"));
		applicationArguments.push(new CommandArg("v", "verboseLogging", "default true - Shows verbose logging"));
		this.settings = new SettingsData();
	}

	public function init() {};

    public function parseApplicationArguments() {
		var args:Array<String> = Sys.args();
		var argPairs:Array<Array<String>> = new Array<Array<String>>();

		if (args.length == 0) {
			return;
		}

		if (args.indexOf("--help") > -1) {
			printArgHelpAndExit();
		}

		// by definition there must be an even number of args
		if (args.length % 2 != 0) {
			printArgHelpAndExit("Bad Arguments");
		}

		while (args.length > 0) {
			var argKey:String = args.shift();
			var argValue:String = args.shift();
			argPairs.push([argKey, argValue]);
		}

		// validate args
		for (argPair in argPairs) {
			var submittedKey:String = argPair[0];
			var submittedValue:String = argPair[1];
			var foundApplicationArgument:CommandArg = Lambda.find(applicationArguments, arg -> arg.keyValue == submittedKey);

			if (foundApplicationArgument == null) {
				printArgHelpAndExit("Bad Arguments " + submittedKey + " not found");
				return;
			} else {
				if (Reflect.hasField(this.settings, foundApplicationArgument.targetProperty) == true) {
					Reflect.setField(this.settings, foundApplicationArgument.targetProperty, submittedValue);
				} else {
					printArgHelpAndExit("Bad Arguments " + submittedKey + " not implemented - My fault! submit an bug please!");
					return;
				}
			}
		}
	}

	public function printArgHelpAndExit(errorMessage:String = "") {
		var INDENT:String = "  \t";
		var TAB:String = "\t";
		var FG_RED:Int = 31;
		var FG_GREEN:Int = 32;

		var l:Array<String> = new Array<String>();

		var toRed:String->String = function(input:String):String {
			return "\033[1;" + FG_RED + "m" + input + " \033[0m";
		}
		var toGreen:String->String = function(input:String):String {
			return "\033[1;" + FG_GREEN + "m" + input + " \033[0m";
		}

		if (errorMessage.length > 0) {
			l.push(toRed("ERROR: " + errorMessage));
			l.push("");
		}

		l.push(toGreen("Simple web mulitplayer server"));
		l.push(toGreen("========================================"));

		l.push("");
		l.push("Usage:");
		l.push(INDENT + "hl P2PServer.hl [options]");

		l.push("");
		l.push("Description:");
		l.push(INDENT + "A server that serves up a simple harness that allows deployment of web clients");
		l.push(INDENT + "that can connect via websockets.");
		l.push(INDENT + "See repo README.MD for details");

		l.push("");
		l.push("Options:");
		l.push(INDENT + "--help" + TAB + "Display this help message and exit.");
		for (arg in applicationArguments) {
			l.push(INDENT + arg.keyValue + TAB + arg.description);
		}

		l.push("");
		l.push("Examples:");
		l.push(INDENT + "# Set URL of client page");
		l.push(INDENT + "hl P2PServer.hl -url https://mysite.com/client.html");
		l.push("");
		l.push(INDENT + "# Display help message");
		l.push(INDENT + "hl P2PServer.hl --help");
		l.push("");

		while (l.length > 0) {
			Sys.println(l.shift());
		}

		Sys.exit(1);
	}

	function get_settings():SettingsData {
		return settings;
	}

	function set_settings(settings):SettingsData {
		this.settings = settings;
		return this.settings;
	}
}

