package spilehx.p2pserver.iframecommscode;

import spilehx.core.logger.GlobalLoggingSettings;
import spilehx.p2pserver.framemessaging.IframeMessaging;
import js.html.URLSearchParams;
import js.Browser;

class IframeCommsScript {
	private var parentOrigin:String;
	private var frameMessaging:IframeMessaging;
	private var windowObject:Dynamic = Browser.window;

	@:isVar public var onHostMessage(default, default):Dynamic->Void;

	public function new() {}

	public function init(parentOrigin:String = null) {
		GlobalLoggingSettings.settings.verbose = (windowObject.VERBOSE_LOGGING != "false");
		LOG_INFO("Loaded IFrame comms code");
		if (parentOrigin != null) {
			this.parentOrigin = parentOrigin;
		} else {
			this.parentOrigin = getUrlParameter("parentOrigin");
		}

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
