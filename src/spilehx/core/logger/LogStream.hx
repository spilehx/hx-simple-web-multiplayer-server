package spilehx.core.logger;

class LogStream {
	@:isVar public var logs(get, null):Array<String>;
	@:isVar public var logString(get, null):String;
	@:isVar public var maxLogLines(get, set):Int;

	public static final instance:LogStream = new LogStream();

	private function new() {
		logs = new Array<String>();
		maxLogLines = 10;
	}

	public function add(logMessage:String) {
		while (logs.length > maxLogLines) {
			logs.shift();
		}

		logs.push(logMessage);
	}

	function get_logString():String {
		logString = logs.join("\n");
		return logString;
	}

	function get_logs():Array<String> {
		return logs;
	}

	function get_maxLogLines():Int {
		return maxLogLines;
	}

	function set_maxLogLines(maxLogLines):Int {
		return this.maxLogLines = maxLogLines;
	}
}
