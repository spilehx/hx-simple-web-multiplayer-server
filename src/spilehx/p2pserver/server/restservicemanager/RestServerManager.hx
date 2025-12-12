package spilehx.p2pserver.server.restservicemanager;

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
	}

	override public function kill() {
		LOG_ERROR("Killing RestServerManager");
		HTTPServer.instance.stopServer();
		serviceExit();
	}
}
