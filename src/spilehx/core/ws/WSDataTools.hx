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

	// TODO: is this named correctly?
	public static function populateObjectFromDataString(obj:Dynamic):String {
		var topLevelClassName:String = getTopLevelClassName(obj);
		var dataObj = {
			classname: topLevelClassName,
			data: obj
		}

		return Json.stringify(dataObj);
	}

	public static function getTopLevelClassName(obj:Dynamic):String {
		if (obj == null) {
			// this is a work around to ignore native types in model, we only use this to parse custom objects anyway
			return "";
		}
		var fullClassNameSplit:Array<String> = Type.getClassName(Type.getClass(obj)).split(".");
		var topLevelClassName:String = fullClassNameSplit[fullClassNameSplit.length - 1];

		return topLevelClassName;
	}

	public static function setDataFromJson(obj:Dynamic, jsonString:String):Dynamic {
		var data:Dynamic = Json.parse(jsonString);
		var fields = Reflect.fields(data);
		for (field in fields) {
			if (Reflect.hasField(obj, field)) {
				Reflect.setField(obj, field, Reflect.getProperty(data, field));
			}
		}

		return obj;
	}

	public static function isDecimalTimeStampResponse(jsonString:String):Bool {
		var data:Dynamic = Json.parse(jsonString);

		return (data.t != null);
	}
}
