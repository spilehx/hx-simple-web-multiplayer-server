package spilehx.core.logger;

class GlobalLoggingSettings {
	// a little singletone to hold settings
	public static final settings:GlobalLoggingSettings = new GlobalLoggingSettings();

	@:isVar public var toFile(get, set):Bool;
	@:isVar public var logFilePath(get, null):String;
	@:isVar public var logFileLinePrefix(get, set):String;
	@:isVar public var maxLogFileLength(get, set):Int;
	@:isVar public var logFileSubFolder(get, set):String;
	@:isVar public var logFileName(get, set):String;
	@:isVar public var remoteLogUrl(get, set):String;
	@:isVar public var verbose(get, set):Bool;

	private function new() {
		this.logFileSubFolder = "./logs";
		this.logFileName = "logs.log";

		this.remoteLogUrl = "";

		this.logFileLinePrefix = "";
		this.maxLogFileLength = 100;
		this.toFile = false;
	}

	function get_remoteLogUrl():String {
		return remoteLogUrl;
	}

	function set_remoteLogUrl(remoteLogUrl):String {
		return this.remoteLogUrl = remoteLogUrl;
	}

	#if (!js)
	public function clearLogFile() {
		Log.clearLogFile();
	}
	#end

	function get_toFile():Bool {
		#if (js)
		// no file output in browser
		return false;
		#end

		return toFile;
	}

	function set_toFile(toFile):Bool {
		return this.toFile = toFile;
	}

	function get_logFilePath():String {
		this.logFilePath = this.logFileSubFolder + "/" + this.logFileName;
		return logFilePath;
	}

	function get_logFileLinePrefix():String {
		return logFileLinePrefix;
	}

	function set_logFileLinePrefix(logFileLinePrefix):String {
		return this.logFileLinePrefix = logFileLinePrefix;
	}

	function get_maxLogFileLength():Int {
		return maxLogFileLength;
	}

	function set_maxLogFileLength(maxLogFileLength):Int {
		return this.maxLogFileLength = maxLogFileLength;
	}

	function get_logFileSubFolder():String {
		return logFileSubFolder;
	}

	function set_logFileSubFolder(logFileSubFolder):String {
		return this.logFileSubFolder = logFileSubFolder;
	}

	function get_logFileName():String {
		return logFileName;
	}

	function set_logFileName(logFileName):String {
		return this.logFileName = logFileName;
	}

	function get_verbose():Bool {
		return verbose;
	}

	function set_verbose(verbose):Bool {
		return this.verbose = verbose;
	}
}
