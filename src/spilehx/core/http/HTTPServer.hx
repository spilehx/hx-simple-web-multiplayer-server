package spilehx.core.http;

import weblink.Weblink;

class HTTPServer {
	private var server:Weblink;
	private var routeClasses:Array<Class<Route>>;
	public var routes:Array<Route>;
	private var port:Int;

	public static final instance:HTTPServer = new HTTPServer();

	// private for singleton use only
	private function new() {
		routeClasses = new Array<Class<Route>>();
		routes = new Array<Route>();
		server = new Weblink();
	}

	public function startServer(?port:Int = 1337) {
		this.port = port;
		instantiateRoutes();
		server.listen(port, false);
	}

	public function stopServer() {
		server.close();
	}

	public function addRoute(routeClass:Class<Route>) {
		routeClasses.push(routeClass);
	}

	private function instantiateRoutes() {
		for (routeClass in routeClasses) {
			var route:Route = Type.createInstance(routeClass, [server]);
			routes.push(route);
		}
	}
}
