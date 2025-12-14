package spilehx.p2pserver.server.restservicemanager.routes;

import weblink.Request;
import spilehx.core.http.RestDataObject;
import weblink.Weblink;
import spilehx.core.http.Route;

class FrameCodeRoute extends Route {
	private static var JS_CONTENT:String = spilehx.macrotools.Macros.fileAsString("./dist/frame.js");

	public function new(server:Weblink) {
		super("/framecode.js", new RestDataObject(), Route.GET_METHOD, server);
	}

	override function onRequest(request:Request) {
		this.response.send(JS_CONTENT);
	}

}
