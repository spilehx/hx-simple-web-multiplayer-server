package;

import haxe.macro.Compiler;

class P2PServer {
	#if (js && frameCode)
	// Creates JS to be included in server build
	// will be cleaned up post server binary build
	// see build.hxml for details
	// we create the main js and code to be included in the frame for comms
	static function main() {
		var window:Dynamic = js.Browser.window;
		if (window.frameMessaging == null) {
			window.frameMessaging = {};
		}
		window.frameMessaging = new spilehx.p2pserver.iframecommscode.IframeCommsScript();
	}
	#elseif (js && !frameCode)
	static function main() {
		spilehx.p2pserver.view.WebWrapper.instance.addFrame("http://localhost:8080");
		spilehx.p2pserver.view.WebWrapper.instance.init();
		
	}
	#else
	static function main() {
		USER_MESSAGE("Starting P2PServerController", true);
		var controller:spilehx.p2pserver.P2PServerController = new spilehx.p2pserver.P2PServerController();
		controller.init();
	}
	#end
}
