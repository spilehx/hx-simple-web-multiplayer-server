package spilehx.p2pserver.server.restservicemanager;


import spilehx.p2pserver.server.mainpage.MainPageTools;
import weblink.Request;
import spilehx.core.http.RestDataObject;
import weblink.Weblink;
import spilehx.core.http.Route;

class MainRoute extends Route {
	private var pageContent:String;
	public function new(server:Weblink) {
		pageContent = MainPageTools.getContent();
		super("/", new RestDataObject(), Route.GET_METHOD, server);
	}

	override function onRequest(request:Request) {
		this.response.send(pageContent);
	}
}




