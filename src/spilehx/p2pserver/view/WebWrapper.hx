package spilehx.p2pserver.view;

import js.Browser;

class WebWrapper {
	public function new() {
		Browser.window.onload = onPageLoaded;
	}

	private function onPageLoaded(e) {
		LOG_INFO("WebWrapper Page fully loaded");
		setup();
		startWS();
	}

	private function setup() {
		// addTestBtn();
	}

	private function startWS() {
		var wsProtoCall:String = "ws";

		if (js.Browser.window.location.protocol.indexOf("https") > -1) {
			wsProtoCall = "wss";
		}

		var rootUrl:String = wsProtoCall + '://' + js.Browser.window.location.hostname;
		ViewWebSocketManager.instance.port = 5000;
		ViewWebSocketManager.instance.url = rootUrl;
		ViewWebSocketManager.instance.connect();
	}

	// private function addTestBtn() {
	// 	var button = Browser.document.createButtonElement();
	// 	button.textContent = "Connect";
	// 	button.onclick = onTestBtnClick;
	// 	Browser.document.body.appendChild(button);
	// }

	// private function onTestBtnClick(e) {
	// 	LOG("Test click");

	
	// }
}
