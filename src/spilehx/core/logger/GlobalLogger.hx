package spilehx.core.logger;

// import haxe.Http;
import haxe.PosInfos;
import haxe.Constraints.Function;

class GlobalLogger {
	public static function LOG(msg:String, ?pos:PosInfos) {
		if (GlobalLoggingSettings.settings.verbose == false) {
			return;
		}
		Log.log(debugPrefix(pos), msg, GlobalLoggingSettings.settings.toFile);
	}

	public static function USER_MESSAGE(msg:String, ?forceMsg:Bool = false) {
		if (GlobalLoggingSettings.settings.verbose == false && forceMsg == false) {
			return;
		}
		Log.userMessage(msg);
	}

	public static function USER_MESSAGE_WARN(msg:String, ?forceMsg:Bool = false) {
		if (GlobalLoggingSettings.settings.verbose == false && forceMsg == false) {
			return;
		}
		Log.userMessageWarn(msg);
	}

	public static function LOG_INFO(msg:String, ?pos:PosInfos) {
		Log.info(debugPrefix(pos), msg, GlobalLoggingSettings.settings.toFile);
	}

	public static function LOG_ERROR(msg:String, ?pos:PosInfos) {
		Log.error(debugPrefix(pos), msg, GlobalLoggingSettings.settings.toFile);
	}

	public static function LOG_WARN(msg:String, ?pos:PosInfos) {
		Log.warn(debugPrefix(pos), msg, GlobalLoggingSettings.settings.toFile);
	}

	public static function LOG_OBJECT(obj:Dynamic, ?pos:PosInfos) {
		Log.logObject(debugPrefix(pos), obj);
	}

	public static function RAW_LOG(msg) {
		Log.log("", msg, GlobalLoggingSettings.settings.toFile);
	}

	private static var debugPrefix:Function = Log.debugPrefix;
}
