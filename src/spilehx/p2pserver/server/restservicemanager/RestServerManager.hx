package spilehx.p2pserver.server.restservicemanager;

import spilehx.core.http.HTTPServer;
import spilehx.core.threadservices.ThreadedServiceManager.ThreadedService;


class RestServerManager extends ThreadedService {

	public function new() {
		super();
	}

	override public function start() {
		super.start();
		// LOG("Starting "+Type.getClassName(Type.getClass(this)).split(".").pop());
		addRoutes();
		HTTPServer.instance.startServer(1337);
	}

	private function addRoutes(){
		HTTPServer.instance.addRoute(MainRoute);

			// Admin Routes
			// HTTPServer.instance.addRoute(ServerStatusRoute);
			// HTTPServer.instance.addRoute(ServerAdminRoute);
			// HTTPServer.instance.addRoute(JoinMatchRoute);
			// HTTPServer.instance.addRoute(RegisterUserRoute);
			// HTTPServer.instance.addRoute(GetAvatarRoute);
			// HTTPServer.instance.addRoute(SubmitBetRoute);
			// HTTPServer.instance.addRoute(LobbyResultsRoute);

			// HTTPServer.instance.addRoute(MatchScoreRoute);

			// // // //External use routes
			// HTTPServer.instance.addRoute(ActiveMatchOverviewRoute);

			// // //Debug routes
			// HTTPServer.instance.addRoute(UnderMaintenanceRoute);

			// HTTPServer.instance.addRoute(OddsDebugRoute);
			
			// //// DEBUG - DO NOT COMMIT!
			// HTTPServer.instance.addRoute(DebugRoute);
	}

	override public function kill() {
		LOG("Killing RestServerManager");
		HTTPServer.instance.stopServer();
		serviceExit();
	}
}
