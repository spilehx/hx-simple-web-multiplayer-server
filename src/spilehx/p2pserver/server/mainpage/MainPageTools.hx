package spilehx.p2pserver.server.mainpage;

class MainPageTools {
	private static var JS_CONTENT:String = spilehx.macrotools.Macros.fileAsString("./dist/main.js");

	public static function getContent():String {
		return "
		<!DOCTYPE html>
		<html>
		<head>
		 	<script>
				"+JS_CONTENT+"
			</script>
		</head>
		<body>
		</body>
		</html>
		";
	}
}
