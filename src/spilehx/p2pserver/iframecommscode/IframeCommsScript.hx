package spilehx.p2pserver.iframecommscode;

import spilehx.p2pserver.framemessaging.IframeMessaging;
import js.html.URLSearchParams;
import js.Browser;

class IframeCommsScript {
	// public static final instance:IframeCommsScript = new IframeCommsScript();
	private var parentOrigin:String;
	private var frameMessaging:IframeMessaging;

	@:isVar public var onHostMessage(default, default):Dynamic->Void;

	// @:isVar public var sendMessage(default, default):String->Void;

	public function new() {}

	public function init() {
		LOG_INFO("Loaded IFrame comms code");
		parentOrigin = getUrlParameter("parentOrigin");
		setupMessaging();
	}

	private function setupMessaging() {
		frameMessaging = new IframeMessaging(parentOrigin);

		frameMessaging.onMessage = function(data:Dynamic) {
			if (onHostMessage != null) {
				onHostMessage(data);
			}
		};

		frameMessaging.sendReadyMessage();
	}

	public function sendFrameMessage(data:Dynamic) {
		frameMessaging.sendData(data);
	}

	private function getUrlParameter(paramName:String):Null<String> {
		var urlSearchParams:URLSearchParams = new URLSearchParams(Browser.location.search);
		if (urlSearchParams.has(paramName) == true) {
			return urlSearchParams.get(paramName);
		};

		return "";
	}
}
