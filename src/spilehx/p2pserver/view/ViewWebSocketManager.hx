package spilehx.p2pserver.view;

import haxe.Json;
import spilehx.p2pserver.dataobjects.GlobalData;
import haxe.Timer;
import spilehx.core.ws.WSClient;

class ViewWebSocketManager {
	private static final RECONNECT_DELAY:Int = 1000;

	public static final SOCKET_EVENT_OPEN:String = "SOCKET_OPEN";
	public static final SOCKET_EVENT_CLOSE:String = "SOCKET_CLOSE";
	public static final SOCKET_EVENT_ERROR:String = "SOCKET_ERROR";
	public static final SOCKET_EVENT_MESSAGE:String = "SOCKET_MESSAGE";

	@:isVar public var url(null, default):String;
	@:isVar public var port(null, default):Int;
	@:isVar public var path(null, default):String;
	@:isVar public var onSocketEvent(default, default):String->Dynamic->Void;

	@:isVar public var autoReconnect(default, default):Bool;

	private var fullPath:String;
	private var ws:WSClient;
	private var connected:Bool;
	private var userID:String;
	private var globalData:GlobalData;

	public static final instance:ViewWebSocketManager = new ViewWebSocketManager();

	private function new() {
		autoReconnect = true;
		connected = false;
		userID = UserIdHelper.getUUID();
		globalData = new GlobalData();
	}

	public function connect() {
		if (ws == null) {
			setupWS();
		}

		ws.open();
	}

	private function setupWS() {
		fullPath = url + ":" + port + path;
		ws = new WSClient(fullPath, false);
		ws.onopen = onOpen;
		ws.onclose = onClose;
		ws.onerror = onError;
		ws.onmessage = onMessage;
	}

	private function onOpen() {
		LOG("WS Connected");
		connected = true;
		dispatchSocketEvent(SOCKET_EVENT_OPEN, {});
		send(); // send empty object just to register the connected user fully
	}

	private function onClose() {
		if (connected != false) {
			LOG_WARN("WS connection lost");
			// only dispatch on first close event
			dispatchSocketEvent(SOCKET_EVENT_CLOSE, {});
		}

		connected = false;

		ws.close();
		ws = null;

		if (autoReconnect == true) {
			attemptReconnect();
		}
	}

	private function onError() {
		if (connected) {
			dispatchSocketEvent(SOCKET_EVENT_ERROR, {});
			LOG_ERROR("WS Error");
		}
	}

	private function onMessage(message:Dynamic) {
		// LOG_INFO("WS new Message");
		updateGlobalData(message.content);
		dispatchSocketEvent(SOCKET_EVENT_MESSAGE, globalData);
	}

	private function updateGlobalData(content:String) {
		var newContentObj:Dynamic = Json.parse(content);
		var newContentObjData:Dynamic = newContentObj.data;

		var fields = Reflect.fields(globalData);
		for (field in fields) {
			if (Reflect.hasField(newContentObjData, field)) {
				var newValue:Dynamic = Reflect.getProperty(newContentObjData, field);
				Reflect.setField(globalData, field, newValue);
			}
		}
	}

	private function attemptReconnect() {
		LOG_INFO("Attempting WS Reconnection");
		var delay:Timer = new Timer(RECONNECT_DELAY);
		delay.run = function() {
			delay.stop();
			delay = null;
			connect();
		}
	}

	public function send(data:Dynamic = null) {
		if (connected == true) {
			var payload:Dynamic = {};
			payload.userID = userID;

			if (data != null) {
				payload.data = data;
			}
			ws.send(payload);
		}
	}

	private function dispatchSocketEvent(type:String, data:Dynamic) {
		if (onSocketEvent != null) {
			onSocketEvent(type, data);
		}
	}
}
