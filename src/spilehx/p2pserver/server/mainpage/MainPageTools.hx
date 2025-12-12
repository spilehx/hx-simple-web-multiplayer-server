package spilehx.p2pserver.server.mainpage;

class MainPageTools {
	// private static var ADMIN_PAGE_SCRIPT_TAG:String = "$ADMIN_PAGE_SCRIPT_TAG";
	// private static var ADMIN_PAGE_HTML_CONTENT:String = spilehx.macrotools.Macros.fileAsString("./assets/index.html");
	// private static var ADMIN_PAGE_JS_CONTENT:String = spilehx.macrotools.Macros.fileAsString("./assets/main.js");

	private static var JS_CONTENT:String = spilehx.macrotools.Macros.fileAsString("./dist/main.js");

	// public static function getAdminPageContent():String {
	// 	var adminPageContentent:String = "";
	// 	if (ADMIN_PAGE_HTML_CONTENT == "" || ADMIN_PAGE_JS_CONTENT == "") {
	// 		return "ERROR: Sorry, Admin page content not incuded at build time";
	// 	}

	// 	adminPageContentent = ADMIN_PAGE_HTML_CONTENT.split(ADMIN_PAGE_SCRIPT_TAG).join(ADMIN_PAGE_JS_CONTENT);

	// 	return adminPageContentent;
	// }

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

		// return " 
		// <!DOCTYPE html>
		//  	<script>
		// 		" + JS_CONTENT + "
		// 	</script> 
		// </html> 
		// ";
	}
}
