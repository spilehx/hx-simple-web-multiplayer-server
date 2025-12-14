package spilehx.p2pserver.server.restservicemanager.routes;

import weblink.Request;
import spilehx.core.http.RestDataObject;
import weblink.Weblink;
import spilehx.core.http.Route;

class ConnectionErrorPageRoute extends Route {
	private static final NO_CONNECT_IMG:String = "data:image/gif;base64,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";
	private static final BG_COLOUR:String = "#303030";
	private static final FONT_COLOUR:String = "#959595";
	private static final CONNECTING_MSG:String = "Connecting";
	private static final FONT_SIZE:String = "1.4rem";
	private static final PAGE_OPACITY:String = "0.8";

	private var pageContent:String;

	public function new(server:Weblink) {
		pageContent = getContent();
		super("/connectionerror", new RestDataObject(), Route.GET_METHOD, server);
	}

	override function onRequest(request:Request) {
		this.response.send(pageContent);
	}

	private function getContent():String {
		return '
			<!doctype html>
			<html style=" opacity: '+PAGE_OPACITY+';">
			<head>
			</head>
			<body style="font-family:\'Courier New\', monospace;margin:0;display:flex;align-items:center;justify-content:center;min-height:100vh;background-color:'+BG_COLOUR+';">
				<div style="text-align:center;">
					<p style="font-size:'+FONT_SIZE+';color:'+FONT_COLOUR+';">'+CONNECTING_MSG+'</p>
					<img src="'+ NO_CONNECT_IMG+ '" alt="connecting img" />
				</div>
			</body>
			</html>
		';
	}
}
