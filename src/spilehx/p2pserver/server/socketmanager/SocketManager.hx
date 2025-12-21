package spilehx.p2pserver.server.socketmanager;

import haxe.Timer;
import haxe.Json;
import spilehx.p2pserver.dataobjects.UserDataObject;
import spilehx.p2pserver.dataobjects.GlobalData;
import spilehx.core.ws.WSServer;
import spilehx.core.threadservices.ThreadedServiceManager.ThreadedService;

class SocketManager extends ThreadedService {
	private static final MESSAGE_HEARTBEAT_INTERVAL:Int = 10;
	private var socketManagerDataHelper:SocketManagerDataHelper;
	private var messageHeartbeat:Timer;

	public function new() {
		super();
		socketManagerDataHelper = new SocketManagerDataHelper();
	}

	override public function start() {
		super.start();
		startUserWSServer();
		startMessageHeartbeat();
	}

	override public function kill() {
		WSServer.instance.stop();
		stopMessageHeartbeat();
	}

	private function startMessageHeartbeat() {
		messageHeartbeat = new Timer(MESSAGE_HEARTBEAT_INTERVAL);
		messageHeartbeat.run = onMessageHeartbeat;
	}

	private function stopMessageHeartbeat() {
		messageHeartbeat.stop();
		messageHeartbeat = null;
	}

	private function onMessageHeartbeat() {
		socketManagerDataHelper.onMessageHeartbeat();
	}

	private function startUserWSServer() {
		socketManagerDataHelper.updateAllConnections = WSServer.instance.updateAllConnections;
		socketManagerDataHelper.sendToUUID = WSServer.instance.sendToUUID;

		WSServer.instance.onConnectionOpened = onConnectionOpened;
		WSServer.instance.onConnectionClosed = onConnectionClosed;
		WSServer.instance.onConnectionError = onConnectionError;
		WSServer.instance.onMessage = onMessage;
		WSServer.instance.start();
	}

	private function onConnectionOpened(wsUUID:String) {
		LOG_INFO("WS Connection opened: " + wsUUID);
		onUserConnected(wsUUID);
	}

	private function onConnectionClosed(wsUUID:String) {
		LOG_INFO("WS Connection closed: " + wsUUID);
		onUserDisconnected(wsUUID);
	}

	private function onConnectionError(wsUUID:String) {
		LOG_ERROR("WS Connection error: " + wsUUID);
		onUserDisconnected(wsUUID);
	}

	private function onMessage(wsUUID:String, dataJson:String) {
		var data:Dynamic = Json.parse(dataJson);
		socketManagerDataHelper.onMessage(wsUUID, data);
	}

	private function onUserDisconnected(wsUUID:String) {
		LOG_INFO("onUserDisconnected " + wsUUID);
		socketManagerDataHelper.unregisterUser(wsUUID);
	}

	private function onUserConnected(wsUUID:String) {
		LOG_INFO("onUserConnected " + wsUUID);
		socketManagerDataHelper.registerUser(wsUUID);
	}
}
