package spilehx.core.cliarg;

class CLIArgHelper {
	@:isVar public var applicationArguments(get, set):Array<CommandArg>;

	private var commandHelpContent:CLICommandHelpContent;

	public function new(commandHelpContent:CLICommandHelpContent) {
		this.commandHelpContent = commandHelpContent;
		this.applicationArguments = new Array<CommandArg>();
	}

	public function registerApplicationArgument(keyValue:String, targetProperty:String, description:String) {
		applicationArguments.push(new CommandArg(keyValue, targetProperty, description));
	}

	public function parseApplicationArguments(targetObject:Dynamic) {
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
				if (Reflect.hasField(targetObject, foundApplicationArgument.targetProperty) == true) {
					Reflect.setField(targetObject, foundApplicationArgument.targetProperty, submittedValue);
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

		l.push(toGreen(commandHelpContent.applicationName));
		l.push(toGreen("========================================"));

		l.push("");
		l.push("Usage:");
		l.push(INDENT + commandHelpContent.baseLaunchCommand + " [options]");

		if (commandHelpContent.description.length > 0) {
			l.push("");
			l.push("Description:");
			for (descLine in commandHelpContent.description) {
				l.push(INDENT + descLine);
			}
		}

		l.push("");
		l.push("Options:");
		l.push(INDENT + "--help" + TAB + "Display this help message and exit.");
		for (arg in applicationArguments) {
			l.push(INDENT + arg.keyValue + TAB + arg.description);
		}

		l.push("");
		l.push("Examples:");
		l.push("");
		l.push(INDENT + "# Display help message");
		l.push(INDENT + "hl P2PServer.hl --help");
		l.push("");

		if (commandHelpContent.examples.length > 0) {
			for (exampLine in commandHelpContent.examples) {
				l.push(INDENT + exampLine);
			}
		}

		while (l.length > 0) {
			Sys.println(l.shift());
		}

		Sys.exit(1);
	}

	function get_applicationArguments():Array<CommandArg> {
		return applicationArguments;
	}

	function set_applicationArguments(applicationArguments):Array<CommandArg> {
		return this.applicationArguments = applicationArguments;
	}
}

class CommandArg {
	@:isVar public var keyValue(default, null):String;
	@:isVar public var targetProperty(default, null):String;
	@:isVar public var description(default, null):String;

	public function new(keyValue:String, targetProperty:String, description:String) {
		this.keyValue = "-" + keyValue;
		this.targetProperty = targetProperty;
		this.description = description;
	}
}

class CLICommandHelpContent {
	@:isVar public var applicationName(default, null):String;
	@:isVar public var baseLaunchCommand(default, null):String;
	@:isVar public var description(default, default):Array<String>;
	@:isVar public var examples(default, default):Array<String>;

	public function new(applicationName:String, baseLaunchCommand:String) {
		this.applicationName = applicationName;
		this.baseLaunchCommand = baseLaunchCommand;
		this.description = new Array<String>();
		this.examples = new Array<String>();
	}
}
