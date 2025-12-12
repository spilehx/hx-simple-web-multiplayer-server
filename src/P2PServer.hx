package;

class P2PServer {
	#if (js)
	static function main() {
		// Creates JS to be included in server build
		// will be cleaned up post server binary build
		// see build.hxml for details
		new spilehx.p2pserver.view.WebWrapper();
	}
	#else
	static function main() {
		USER_MESSAGE("Starting P2PServerController", true);
		var controller:spilehx.p2pserver.P2PServerController = new spilehx.p2pserver.P2PServerController();
		controller.init();
	}
	#end
}
