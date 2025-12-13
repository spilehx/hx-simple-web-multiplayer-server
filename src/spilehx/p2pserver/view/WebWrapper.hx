package spilehx.p2pserver.view;

import spilehx.p2pserver.framemessaging.HostMessaging;
import js.html.IFrameElement;
import haxe.Timer;
import js.html.DivElement;
import js.Browser;

class WebWrapper {
	public static final instance:WebWrapper = new WebWrapper();

	private var contentFrame:DivElement;
	private var contentIframe:IFrameElement;
	private var frameURL:String;
	private var pageReady:Bool = false;
	private var frameMessaging:HostMessaging;

	private function new() {}

	public function init() {
		Browser.window.onload = onPageLoaded;
	}

	private function onPageLoaded(e) {
		pageReady = true;
		LOG_INFO("WebWrapper Page fully loaded");
		setup();
	}

	private function setup() {
		contentFrame = addContentFrame();
	}

	private function addContentFrame():DivElement {
		var document = Browser.document;
		document.documentElement.style.height = "100%";
		document.body.style.margin = "0";
		document.body.style.height = "100%";
		document.body.style.display = "flex";

		var div:DivElement = document.createDivElement();
		div.style.width = "100%";
		div.style.height = "100%";

		// Center content inside the div
		div.style.display = "flex";
		div.style.alignItems = "center";
		div.style.justifyContent = "center";
		div.style.backgroundColor = "#222";

		document.body.appendChild(div);
		return div;
	}

	private function startWS() {
		var wsProtoCall:String = "ws";

		if (js.Browser.window.location.protocol.indexOf("https") > -1) {
			wsProtoCall = "wss";
		}

		var rootUrl:String = wsProtoCall + '://' + js.Browser.window.location.hostname;
		ViewWebSocketManager.instance.port = 5000;
		ViewWebSocketManager.instance.url = rootUrl;
		ViewWebSocketManager.instance.onSocketEvent = onSocketEvent;
		ViewWebSocketManager.instance.connect();
	}

	private function onSocketEvent(type:String, data:Dynamic) {
		if (frameMessaging != null) {
			frameMessaging.sendData({
				type: type,
				data: data
			});
		}
	}

	public function addFrame(url:String) {
		frameURL = url;

		if (pageReady != true) {
			// do a loop to wait for the page to be ready
			var loopDelay:Timer = new Timer(700);
			loopDelay.run = function() {
				loopDelay.stop();
				loopDelay = null;
				addFrame(frameURL);
			}
		} else {
			setupIframe();
		}
	}

	private function setupIframe() {
		LOG_INFO("Loading frame: " + frameURL);
		var iframe:IFrameElement = Browser.document.createIFrameElement();
		iframe.onload = onIframeLoaded;
		iframe.src = frameURL + "?parentOrigin=" + js.Browser.window.location.origin;
		iframe.width = "100%";
		iframe.height = "100%";
		iframe.style.border = "0";
		contentFrame.appendChild(iframe);
		contentIframe = iframe;
	}

	private function onIframeLoaded(e) {
		setupIframeComms(contentIframe, frameURL);
	}

	private function setupIframeComms(iframe:IFrameElement, targetOrigin:String) {
		frameMessaging = new HostMessaging(iframe, targetOrigin);

		frameMessaging.onMessage = onIFrameMessageData;
		frameMessaging.onReady = function() {
			startWS();
		}
	}

	private function onIFrameMessageData(data:Dynamic) {
		ViewWebSocketManager.instance.send(data);
	}
}
