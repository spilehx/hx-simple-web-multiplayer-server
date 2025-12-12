package spilehx.core;

class SysUtils {
	public static function isRunningAsSudo():Bool {
		try {
			// On Unix-like systems, UID 0 means root
			var process = new sys.io.Process("id", ["-u"]);
			var output = StringTools.trim(process.stdout.readAll().toString()); //
			process.close();
			return output == "0";
		} catch (e:Dynamic) {
			// If anything fails, assume not sudo
			return false;
		}
	}
}
