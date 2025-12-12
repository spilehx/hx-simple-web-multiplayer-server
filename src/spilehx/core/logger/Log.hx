package spilehx.core.logger;

import haxe.PosInfos;

class Log {
	private static inline var MSG_ERROR = "ERROR";
	private static inline var MSG_DEBUG = "DEBUG";
	private static inline var MSG_INFO = "INFO";
	private static inline var MSG_SOFT = "WARN";

	private static inline var FG_RED:Int = 31;
	private static inline var FG_GREEN:Int = 32;
	private static inline var FG_BLUE:Int = 34;
	private static inline var FG_DEBUG:Int = 93;

	public static function log(debugprefix:String, msg:String, toFile:Bool = false) {
		out(debugprefix, msg, MSG_DEBUG, toFile);
	}

	public static function info(debugprefix:String, msg:String, toFile:Bool = false) {
		out(debugprefix, msg, MSG_INFO, toFile);
	}

	public static function warn(debugprefix:String, msg:String, toFile:Bool = false) {
		out(debugprefix, msg, MSG_SOFT, toFile);
	}

	public static function error(debugprefix:String, msg:String, toFile:Bool = false) {
		out(debugprefix, msg, MSG_ERROR, toFile);
	}

	public static function userMessage(msg:String) {
		var out:String = "\033[1;" + FG_GREEN + "m" + msg + " \033[0m";
		platfromSpecificLogCommand(out);
		LogStream.instance.add(msg);
	}

	public static function userMessageWarn(msg:String) {
		var out:String = "\033[1;" + FG_BLUE + "m" + msg + " \033[0m";
		platfromSpecificLogCommand(out);
		LogStream.instance.add(msg);
	}

	public static function logObject(prefix:String, obj:Dynamic) {
		log(prefix, "----------- LOGGING OBJECT -----------");
		var fields = Reflect.fields(obj);

		for (field in fields) {
			var value = Reflect.getProperty(obj, field);

			if (value != null) {
				log("", "Field-->" + field + "  Value--->" + Std.string(value), false);
			} else {
				log("", "Field-->" + field + "  IS NULL", false);
			}
		}
	}

	private static function out(debugprefix:String, msg:String, type:String = "", toFile:Bool = false) {
		var out:String = "";

		if (type == MSG_INFO) {
			out = "\033[1;" + FG_GREEN + "mINFO: \033[0m";
		} else if (type == MSG_SOFT) {
			out = "\033[1;" + FG_BLUE + "mWARNING: \033[0m";
		} else if (type == MSG_ERROR) {
			out = "\033[1;" + FG_RED + "mERROR: \033[0m";
		} else if (type == MSG_DEBUG) {
			out = "\033[1;" + FG_DEBUG + "mDEBUG: \033[0m";
		}

		out = out + debugprefix + msg;

		if (toFile) {
			appendTextToLogFile(msg, type);
		}

		#if (!js)
		if (type == MSG_ERROR) {
			stdErrOut(msg);
		}
		#end

		platfromSpecificLogCommand(out);
		LogStream.instance.add(type + ": " + msg);
	}

	private static function stdErrOut(msg:String) {
		#if (!js)
		Sys.stderr().writeString(msg + "\n");
		#end
	}

	#if (!js)
	public static function sendRemoteLog(msg:String) {
		var fullPath = Sys.programPath();
		var appName = fullPath.split("/").pop().split("\\").pop(); // Extract the file name from the path

		var url = GlobalLoggingSettings.settings.remoteLogUrl + "/?source=" + appName + "&log=\"" + msg + "\"";

		try {
			var http = new haxe.Http(url);
			http.onData = function(data:String) {}

			http.onError = function(error:String) {}

			http.request();
		} catch (e) {
			// dont need to catch an error - this is remote logging
		}
	}
	#end

	private static function appendTextToLogFile(msg:String, type:String = "") {
		var out:String = "";
		if (type == MSG_INFO) {
			out = "INFO : " + msg;
		} else if (type == MSG_SOFT) {
			out = "WARNING : " + msg;
		} else if (type == MSG_ERROR) {
			out = "ERROR : " + msg;
		} else {
			out = msg;
		}

		#if (!js)
		var dateStampString:String = DateTools.format(Date.now(), "%Y-%m-%d_%H:%M:%S");
		var logLine:String = "[" + dateStampString + "] " + GlobalLoggingSettings.settings.logFileLinePrefix + ": " + out;

		appendTextToFile(logLine, GlobalLoggingSettings.settings.logFilePath);
		#end
	}

	public static function debugPrefix(pos:PosInfos):String {
		var prefix:String = pos.fileName + ":" + pos.lineNumber + ": ";
		return prefix;
	}

	private static function platfromSpecificLogCommand(msg:String) {
		if (allowLogs()) {
			#if (js)
			Reflect.callMethod(js.Browser.console, js.Browser.console.log, [msg]);
			#elseif (neko)
			Sys.println(msg);
			#else
			Sys.println(msg);
			#end
		}
	}

	private static function allowLogs():Bool {
		#if (js)
		// return true; //DO NOT COMMIT
		return (js.Browser.window.document.URL.indexOf("http://localhost") > -1);
		#else
		return true;
		#end
	}

	#if (!js)
	public static function appendTextToFile(content:String, outputFilePath:String, ?maxLength:Int = 500) {
		var LINE_DELIM:String = "\n";
		var contentArr:Array<String> = new Array<String>();

		// setup folder
		if (sys.FileSystem.exists(GlobalLoggingSettings.settings.logFileSubFolder) == false) {
			sys.FileSystem.createDirectory(GlobalLoggingSettings.settings.logFileSubFolder);
		}

		// get current content
		if (sys.FileSystem.exists(outputFilePath)) {
			contentArr = sys.io.File.getContent(outputFilePath).split(LINE_DELIM);
		}

		// add new content
		contentArr.push(content);

		// limit length
		while (contentArr.length > GlobalLoggingSettings.settings.maxLogFileLength) {
			contentArr.shift();
		}

		writeLogFile(contentArr.join(LINE_DELIM));

		// var file = sys.io.File.write(outputFilePath, false);
		// file.writeString(contentArr.join(LINE_DELIM));
		// file.close();
	}

	public static function clearLogFile() {
		writeLogFile("");
	}

	private static function writeLogFile(content:String) {
		try {
			if (sys.FileSystem.exists(GlobalLoggingSettings.settings.logFileSubFolder) == true) {
				// get current content
				if (sys.FileSystem.exists(GlobalLoggingSettings.settings.logFilePath)) {
					var file = sys.io.File.write(GlobalLoggingSettings.settings.logFilePath, false);
					file.writeString(content);
					file.close();
				}
			}
		} catch (e) {}
	}
	#end
}
