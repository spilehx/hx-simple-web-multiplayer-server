package spilehx.core.ws;

import haxe.Json;

class WSDataTools {
	public static function objectDataString(obj:Dynamic):String {
		var fullClassNameSplit:Array<String> = Type.getClassName(Type.getClass(obj)).split(".");
		var topLevelClassName:String = fullClassNameSplit[fullClassNameSplit.length - 1];

		var dataObj = {
			classname: topLevelClassName,
			data: obj
		}

		return Json.stringify(dataObj);
	}
}
