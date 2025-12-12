package spilehx.macrotools;

import sys.FileSystem;
import sys.io.File;

class Macros {
	public static macro function fileAsString(path:String):ExprOf<String> {
		var content:String = "";

		if (sys.FileSystem.exists(path) == true) {
			content = sys.io.File.getContent(path);
		}

		return macro $v{content};
	}


#if (neko || eval || display)
	public static function macroClassfileAsString(path:String):String {
		var content:String = "";

		if (sys.FileSystem.exists(path) == true) {
			content = sys.io.File.getContent(path);
		}

		return content;
	}

	public static function getEnvVar(varName:String):Dynamic {
		/* 
			used to get env values from the build.hxml, example:
				-D foo=bar
				var fooValue = getEnvVar("foo");
		 */

		var envVar = haxe.macro.Context.definedValue(varName);
		if (envVar == null) {
			haxe.macro.Context.error("Environment variable " + varName + " not set in .hxml file", haxe.macro.Context.currentPos());
		}
		return envVar;
	}

	public static function ensureFolder(folder:String):Void {
		if (!FileSystem.exists(folder)) {
			try {
				FileSystem.createDirectory(folder);
			} catch (e:Dynamic) {
				haxe.macro.Context.error("Failed to create directory 'dist': " + Std.string(e), haxe.macro.Context.currentPos());
			}
		}
	}

	public static function writeFile(content:String, path:String) {
		try {
			File.saveContent(path, content);
		} catch (e:Dynamic) {
			haxe.macro.Context.error("Failed to write file: " + Std.string(e), haxe.macro.Context.currentPos());
		}
	}
	 #end
}
