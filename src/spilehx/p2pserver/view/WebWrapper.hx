package spilehx.p2pserver.view;

import js.html.URL;
import spilehx.core.logger.GlobalLoggingSettings;
import js.Syntax;
import spilehx.p2pserver.framemessaging.HostMessaging;
import js.html.IFrameElement;
import haxe.Timer;
import js.html.DivElement;
import js.Browser;

class WebWrapper {
	public static final instance:WebWrapper = new WebWrapper();

	private var contentContainer:DivElement;
	private var contentIframe:IFrameElement;
	private var connectionErrorIframe:IFrameElement;
	private var frameURL:String;
	private var pageReady:Bool = false;
	private var usingDebugContent:Bool = false;
	private var frameMessaging:HostMessaging;
	private var windowObject:Dynamic = Browser.window;

	private function new() {}

	public function init() {
		GlobalLoggingSettings.settings.verbose = (windowObject.VERBOSE_LOGGING == "true");
		setFrameURL(getFrameUrl());
		Browser.window.onload = onPageLoaded;
	}

	private function getFrameUrl():String {
		// windowObject.CONTENT_URL is url of frame provided by server via cli args
		if (windowObject.CONTENT_URL.length > 0) {
			if (isValidUrl(windowObject.CONTENT_URL)) {
				return windowObject.CONTENT_URL;
			} else {
				LOG_ERROR("Invalid URL submitted: " + windowObject.CONTENT_URL);
			}
		}

		LOG_INFO("Loading debug content");
		usingDebugContent = true;

		return Browser.window.location.origin + "/debugclient.html";
	}

	private function isValidUrl(value:String):Bool {
		if (value == null || value == "")
			return false;

		return try {
			Syntax.code("new URL({0})", value);
			true;
		} catch (e:Dynamic) {
			false;
		}
	}

	private function onPageLoaded(e) {
		pageReady = true;
		LOG_INFO("WebWrapper Page fully loaded");
		setup();
	}

	private function setup() {
		setupPage();
		contentContainer = addContentContainer();
	}

	private function setupPage() {
		Browser.document.documentElement.style.height = "100%";
		Browser.document.body.style.margin = "0";
		Browser.document.body.style.height = "100%";
		Browser.document.body.style.display = "flex";
	}

	private function addContentContainer():DivElement {
		var div:DivElement = Browser.document.createDivElement();

		div.style.width = "100%";
		div.style.height = "100%";
		div.style.position = "relative";
		div.style.overflow = "hidden";

		Browser.document.body.appendChild(div);
		return div;
	}

	private function setupContentIframe():IFrameElement {
		LOG_INFO("Loading frame: " + frameURL);
		var iframe = setupLayeredIframe(1);
		iframe.onload = onIframeLoaded;
		
		if(usingDebugContent == true){
			iframe.src = frameURL;
		} else{
			iframe.src = frameURL+ "?parentOrigin=" + Browser.window.location.origin;
		}
		return iframe;
	}

	private function setupConnectionErrorIframe():IFrameElement {
		var iframe = setupLayeredIframe(2);
		iframe.src = Browser.window.location.origin + "/connectionerror";
		return iframe;
	}

	private function setConnectionErrorIframeVisible(visible:Bool):Void {
		var currentlyVisible:Bool = (connectionErrorIframe.style.opacity != "0");
		if (currentlyVisible != visible) {
			connectionErrorIframe.style.opacity = visible ? "1" : "0";
			connectionErrorIframe.style.pointerEvents = visible ? "auto" : "none";
		}
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
		setConnectionErrorIframeVisible((type == ViewWebSocketManager.SOCKET_EVENT_CLOSE));
		sendFrameMessage(type, data);
	}

	private function sendFrameMessage(type:String, data:Dynamic) {
		if (frameMessaging != null) { // if we have a valid connection to the content iframe
			frameMessaging.sendData({
				type: type,
				data: data
			});
		}
	}

	private function setFrameURL(url:String) {
		// we will loop the flow on this function if page is not yet ready
		frameURL = url;

		if (pageReady != true) {
			// do a loop to wait for the page to be ready
			var loopDelay:Timer = new Timer(700);
			loopDelay.run = function() {
				loopDelay.stop();
				loopDelay = null;
				setFrameURL(frameURL);
			}
		} else {
			// page ready, proceed
			contentIframe = setupContentIframe();
			connectionErrorIframe = setupConnectionErrorIframe();
			setConnectionErrorIframeVisible(true);
		}
	}

	private function onIframeLoaded(e) {
		setupIframeComms(contentIframe, new URL(contentIframe.src).origin);
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

	private function setupLayeredIframe(zIndex:Int):IFrameElement {
		var iframe:IFrameElement = Browser.document.createIFrameElement();

		iframe.style.position = "absolute";
		iframe.style.top = "0";
		iframe.style.left = "0";
		iframe.style.right = "0";
		iframe.style.bottom = "0";
		iframe.style.width = "100%";
		iframe.style.height = "100%";
		iframe.style.zIndex = Std.string(zIndex);

		iframe.style.border = "0";
		iframe.setAttribute("frameborder", "0");
		iframe.setAttribute("scrolling", "no");
		iframe.style.overflow = "hidden";
		iframe.style.display = "block";

		contentContainer.appendChild(iframe);
		return iframe;
	}
}
