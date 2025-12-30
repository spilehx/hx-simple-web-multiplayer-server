package spilehx.p2pserver;

// This is a helper script provided as a haxelib
// No other files in this project are provided in the haxelib
import js.html.URLSearchParams;
import haxe.Constraints.Function;
import js.html.ScriptElement;
import js.Browser;

class MultiplayerMessaging {
	public static final SOCKET_EVENT_OPEN:String = "SOCKET_OPEN";
	public static final SOCKET_EVENT_CLOSE:String = "SOCKET_CLOSE";
	public static final SOCKET_EVENT_ERROR:String = "SOCKET_ERROR";
	public static final SOCKET_EVENT_REGISTERED:String = "SOCKET_REGISTER";
	public static final SOCKET_EVENT_KEEPALIVE:String = "SOCKET_KEEPALIVE";
	public static final SOCKET_EVENT_MESSAGE:String = "SOCKET_MESSAGE";

	public static final SOCKET_MESSAGE_GLOBAL:String = "GlobalMessage";
	public static final SOCKET_MESSAGE_REGISTER_USER:String = "RegisterUserMessage";

	private var frameCodeLoaded:Bool = false;
	private var pageLoaded:Bool = false;
	private var onReady:Function;

	public var onMessage:Message->Void;

	private var messageBridge:Dynamic;
	private var scriptEl:ScriptElement;

	@:isVar public var users(default, null):Array<User>;
	@:isVar public var currentUserID(default, null):String;

	// private for singleton use only
	public static final instance:MultiplayerMessaging = new MultiplayerMessaging();

	private function new() {
		users = new Array<User>();
	}

	public function init(onReadyCallBack:Function = null) {
		if (onReadyCallBack != null) {
			this.onReady = onReadyCallBack;
		}
		addFrameCode();
	}

	private function addFrameCode() {
		scriptEl = Browser.document.createScriptElement();
		scriptEl.src = getUrlParameter("parentOrigin") + "/framecode.js";
		scriptEl.onload = onFrameCodeLoaded;
		scriptEl.onerror = onFrameCodeLoadError;
		Browser.document.head.appendChild(scriptEl);
		Browser.window.onload = onPageLoaded;
	}

	private function getUrlParameter(paramName:String):Null<String> {
		var urlSearchParams:URLSearchParams = new URLSearchParams(Browser.location.search);
		if (urlSearchParams.has(paramName) == true) {
			return urlSearchParams.get(paramName);
		};

		return "";
	}

	private function onFrameCodeLoadError(e) {
		trace("Failed to load framecode.js at: " + scriptEl.src);
	}

	private function onFrameCodeLoaded(e) {
		trace("framecode.js loaded");
		frameCodeLoaded = true;
		checkReadyStateAndProceed();
	}

	private function onPageLoaded(_) {
		pageLoaded = true;
		checkReadyStateAndProceed();
	}

	private function checkReadyStateAndProceed() {
		if (frameCodeLoaded == true && pageLoaded == true) {
			start();
		}
	}

	public function start() {
		var windowObject:Dynamic = Browser.window;
		if (windowObject.frameMessaging != null) {
			messageBridge = windowObject.frameMessaging;
			messageBridge.onHostMessage = onHostMessage;
			messageBridge.init();

			if (onReady != null) {
				onReady();
			}
		} else {
			trace("Frame Messaging not active");
		}
	}

	private function onHostMessage(rawMessage:Dynamic) {
		var type = rawMessage.type;
		if (type == SOCKET_EVENT_MESSAGE) {
			var message:Message = cast rawMessage.data;

			if (message.messageType == SOCKET_MESSAGE_GLOBAL) {
				var message:Message = cast rawMessage.data;
				storeUsers(message);
			}

			if (onMessage != null) {
				onMessage(message);
			}
		} else if (type == SOCKET_EVENT_REGISTERED) {
			if (rawMessage.data.messageType == SOCKET_MESSAGE_REGISTER_USER) {
				currentUserID = rawMessage.data.userID;
			}
		}
	}

	private function storeUsers(message:Message) {
		users = message.data.users;
	}

	public function send(data:Dynamic) {
		if (messageBridge == null) {
			trace("Cant send, frame Messaging not active");
			return;
		}
		messageBridge.sendGlobalMessage(data);
	}


	public function sendDMMessage(userID:String, data:Dynamic) {
		if (messageBridge == null) {
			trace("Cant send, frame Messaging not active");
			return;
		}
		messageBridge.sendDMMessage(data, userID);
	}
}

typedef Message = {
	var messageType:String;
	var ts:Float; // timestamp in milliseconds
	var data:MessageData;
}

typedef MessageData = {
	var users:Array<User>;
	var connectedUsers:Int;
}

typedef User = {
	globalData:Dynamic,
	userID:String,
	wsUUID:String
}
