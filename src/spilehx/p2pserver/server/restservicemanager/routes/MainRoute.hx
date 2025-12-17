package spilehx.p2pserver.server.restservicemanager.routes;

import spilehx.core.ws.WSServer;
import spilehx.p2pserver.server.settingsmanager.SettingsManager;
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

		private function isRunningInDocker():Bool {
		// for detecting if a HL app is running in docker
		// often used as a 'trick' to decide if the app is deployed (ie live)
		var pathToDockerEnv:String = "/.dockerenv";
		var isRunningInDocker:Bool = sys.FileSystem.exists(pathToDockerEnv);
		return isRunningInDocker;
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
					window.CONTENT_URL = '"+SettingsManager.instance.settings.frameUrl+"';
					window.VERBOSE_LOGGING = '"+SettingsManager.instance.settings.verboseLogging+"';
					window.IS_DOCKER = '"+isRunningInDocker()+"';
					"+JS_CONTENT+"
				</script>
			</head>
			<body>
			</body>
		</html>
		";
	}
}
