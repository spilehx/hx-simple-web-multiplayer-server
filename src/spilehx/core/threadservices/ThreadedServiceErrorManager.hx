package spilehx.core.threadservices;

/**
 * Simple utility class to centralise loggind and actions around errors
 */
class ThreadedServiceErrorManager {
	private static var VERBOSE:Bool = true;

	public static function onGameServerConnectionError(connectionAttempts:Int, errorMessage:String) {
		LOG_ERROR("Game Server Connection failed "+connectionAttempts+" times");
		LOG_INFO(errorMessage);
	}

	public static function onTooManyGameServerConnectionErrors(connectionAttempts:Int) {
		LOG_ERROR("Game Server Connection Failed "+connectionAttempts+" Times");
		onFatalError();
	}

	public static function onThreadError(threadedServiceClassName:String, totalAppThreadErrors:Int, errorMessage:String) {
		LOG_ERROR("Thread Error:" + threadedServiceClassName + " App errors so far:" + totalAppThreadErrors);
		LOG_INFO(errorMessage);
	}

	public static function onTooManyThreadErrors() {
		LOG_ERROR("Tread Error max limit reached");
		onFatalError();
	}

	public static function onFatalError() {
		LOG_ERROR("Fatal Error Exiting");
		Sys.exit(1);
	}

	// Called if the dev should have implemnted somthing important!
	public static function notImplementedError(functionName:String, msg:String) {
		LOG_ERROR("Implmentation Error" + "\n" + functionName + "\n" + msg);
		Sys.exit(1);
	}
}
