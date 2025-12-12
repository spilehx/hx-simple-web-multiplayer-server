package spilehx.p2pserver.view;

import js.Cookie;

class UserIdHelper {
	private static final COOKIE_KEY = "UUID";

	public static function getUUID():String {
		if (hasStoredValue() == true) {
			return getStoredValue();
		} else {
			var uuid:String = generateUUID();
			save(uuid);
			return uuid;
		}
	}

	private static function generateUUID():String {
		var time = Date.now().getTime();
		var rand = Std.int(Math.random() * 0xFFFFFF);
		return time + "-" + StringTools.hex(rand, 6);
	}

	private static function save(value:String, ?expireInDays:Int = 30):Void {
		var expireInSeconds:Int = Math.round(expireInDays * 86400);
		Cookie.set(COOKIE_KEY, value, expireInSeconds);
	}

	private static function hasStoredValue():Bool {
		return Cookie.exists(COOKIE_KEY);
	}

	private static function getStoredValue():String {
		return Cookie.get(COOKIE_KEY);
	}
}
