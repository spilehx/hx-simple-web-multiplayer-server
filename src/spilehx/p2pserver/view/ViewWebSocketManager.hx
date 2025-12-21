package spilehx.p2pserver.view;

import spilehx.p2pserver.dataobjects.socketmessage.KeepAliveMessage;
import spilehx.p2pserver.dataobjects.socketmessage.SocketMessage;
import spilehx.p2pserver.dataobjects.socketmessage.RegisterUserMessage;
import haxe.Json;
import spilehx.p2pserver.dataobjects.GlobalData;
import haxe.Timer;
import spilehx.core.ws.WSClient;
import spilehx.p2pserver.server.socketmanager.SocketManagerDataHelper;

class ViewWebSocketManager {
	private static final RECONNECT_DELAY:Int = 1000;

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
		dispatchSocketEvent(SocketManagerDataHelper.SOCKET_EVENT_OPEN, {});
		sendRegisterUserMessage();
	}

	private function onClose() {
		if (connected != false) {
			LOG_WARN("WS connection lost");
			// only dispatch on first close event
			dispatchSocketEvent(SocketManagerDataHelper.SOCKET_EVENT_CLOSE, {});
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
			dispatchSocketEvent(SocketManagerDataHelper.SOCKET_EVENT_ERROR, {});
			LOG_ERROR("WS Error");
		}
	}

	private function onMessage(message:Dynamic) {
		LOG_INFO("WS new Message");
		var newContentObj:Dynamic = Json.parse(message.content).data;
		if (newContentObj.messageType == new RegisterUserMessage().messageType) {
			onRecieveRegisterUserMessage(newContentObj);
		} else if (newContentObj.messageType == new KeepAliveMessage().messageType) {
			onRecieveKeepAliveMessage(newContentObj);
		}
	}

	// private function updateGlobalData(content:String) {
	// 	var newContentObj:Dynamic = Json.parse(content);
	// 	var newContentObjData:Dynamic = newContentObj.data;
	// 	var fields = Reflect.fields(globalData);
	// 	for (field in fields) {
	// 		if (Reflect.hasField(newContentObjData, field)) {
	// 			var newValue:Dynamic = Reflect.getProperty(newContentObjData, field);
	// 			Reflect.setField(globalData, field, newValue);
	// 		}
	// 	}
	// }

	private function attemptReconnect() {
		LOG_INFO("Attempting WS Reconnection");
		var delay:Timer = new Timer(RECONNECT_DELAY);
		delay.run = function() {
			delay.stop();
			delay = null;
			connect();
		}
	}

	private function sendRegisterUserMessage() {
		var registerUserMessage:RegisterUserMessage = new RegisterUserMessage();
		registerUserMessage.userID = userID;
		send(registerUserMessage); // send object to register the connected user id etc
	}

	private function onRecieveRegisterUserMessage(data:Dynamic) {
		var registerUserMessage:RegisterUserMessage = new RegisterUserMessage();
		SocketManagerDataHelper.populateFromDynamic(registerUserMessage, data);
		dispatchSocketEvent(SocketManagerDataHelper.SOCKET_EVENT_REGISTERED, registerUserMessage);
	}

	private function onRecieveKeepAliveMessage(data:Dynamic) {
		var keepAliveMessage:KeepAliveMessage = new KeepAliveMessage();
		SocketManagerDataHelper.populateFromDynamic(keepAliveMessage, data);
		dispatchSocketEvent(SocketManagerDataHelper.SOCKET_EVENT_KEEPALIVE, keepAliveMessage);
	}

	public function send(payload:SocketMessage) {
		if (connected == true) {
			payload.ts = Date.now().getTime();
			ws.send(payload);
		}
	}

	private function dispatchSocketEvent(type:String, data:Dynamic) {
		if (onSocketEvent != null) {
			onSocketEvent(type, data);
		}
	}
}
