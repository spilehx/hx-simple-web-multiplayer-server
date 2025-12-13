package spilehx.p2pserver.server.restservicemanager;

import weblink.Request;
import spilehx.core.http.RestDataObject;
import weblink.Weblink;
import spilehx.core.http.Route;

class MainRoute extends Route {
	private static var JS_CONTENT:String = spilehx.macrotools.Macros.fileAsString("./dist/main.js");

	private var pageContent:String;

	public function new(server:Weblink) {
		pageContent = getContent();
		super("/", new RestDataObject(), Route.GET_METHOD, server);
	}

	override function onRequest(request:Request) {
		this.response.send(pageContent);
	}

	private function getContent():String {
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
