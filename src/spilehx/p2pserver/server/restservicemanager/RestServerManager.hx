package spilehx.p2pserver.server.restservicemanager;

import spilehx.p2pserver.server.restservicemanager.routes.FrameCodeRoute;
import spilehx.p2pserver.server.restservicemanager.routes.MainRoute;
import spilehx.p2pserver.server.restservicemanager.routes.ConnectionErrorPageRoute;
import spilehx.p2pserver.server.restservicemanager.routes.DebugContentRoute;
import spilehx.core.http.HTTPServer;
import spilehx.core.threadservices.ThreadedServiceManager.ThreadedService;

class RestServerManager extends ThreadedService {
	public function new() {
		super();
	}

	override public function start() {
		super.start();
		addRoutes();
		HTTPServer.instance.startServer(1337);
	}

	private function addRoutes() {
		HTTPServer.instance.addRoute(MainRoute);
		HTTPServer.instance.addRoute(FrameCodeRoute);
		HTTPServer.instance.addRoute(ConnectionErrorPageRoute);
		HTTPServer.instance.addRoute(DebugContentRoute);
	}

	override public function kill() {
		LOG_ERROR("Killing RestServerManager");
		HTTPServer.instance.stopServer();
		serviceExit();
	}
}
