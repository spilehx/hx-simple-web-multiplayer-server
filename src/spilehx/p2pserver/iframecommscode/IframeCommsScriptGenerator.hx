package spilehx.p2pserver.iframecommscode;

import spilehx.p2pserver.framemessaging.IframeMessaging;
import js.html.URLSearchParams;
import js.Browser;

class IframeCommsScriptGenerator {
	public static final instance:IframeCommsScriptGenerator = new IframeCommsScriptGenerator();

	private var parentOrigin:String;

	private var messaging:IframeMessaging;

	private function new() {}

	public function init() {
		Browser.window.onload = onPageLoaded;
	}

	private function onPageLoaded(e) {
		LOG_INFO("Loaded IFrame comms code");
		parentOrigin = getUrlParameter("parentOrigin");
		setupMessaging();
	}

	private function setupMessaging() {
		messaging = new IframeMessaging(parentOrigin);
	}

	private function getUrlParameter(paramName:String):Null<String> {
		var urlSearchParams:URLSearchParams = new URLSearchParams(Browser.location.search);
		if (urlSearchParams.has(paramName) == true) {
			return urlSearchParams.get(paramName);
		};

		return "";
	}
}
