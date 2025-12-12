package spilehx.core.ws;

import haxe.Json;
import hx.ws.WebSocket;

class WSClient extends WebSocket {
	public function new(url:String, immediateOpen = true) {
		super(url, immediateOpen);
	}

	override public function send(data:Dynamic) {
		super.send(Json.stringify(data));
	}
}
