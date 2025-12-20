package spilehx.p2pserver.server.socketupdatemanager;

import haxe.Json;
import spilehx.p2pserver.dataobjects.UserDataObject;
import spilehx.p2pserver.dataobjects.GlobalData;
import spilehx.core.ws.WSServer;
import spilehx.core.threadservices.ThreadedServiceManager.ThreadedService;

class SocketUpdateManager extends ThreadedService {
	private var users:Map<String, UserDataObject>;
	private var userCount = 0;

	private static final MIN_BROADCAST_UPDATE_INTERVAL:Float = 10;

	private var lastBroadcastUpdate:Float;

	public function new() {
		super();
		users = new Map<String, UserDataObject>();
	}

	override public function start() {
		super.start();
		startUserWSServer();
	}

	override public function kill() {
		WSServer.instance.stop();
	}

	private function startUserWSServer() {
		lastBroadcastUpdate = Date.now().getTime();
		WSServer.instance.onConnectionOpened = onConnectionOpened;
		WSServer.instance.onConnectionClosed = onConnectionClosed;
		WSServer.instance.onConnectionError = onConnectionError;
		WSServer.instance.onMessage = onMessage;
		WSServer.instance.start();
	}

	private function onConnectionOpened(wsUUID:String) {
		LOG_INFO("WS Connection opened: " + wsUUID);
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

		var udo:UserDataObject = {
			wsUUID: wsUUID,
			userID: data.userID,
			data: data.data
		};

		updateUser(wsUUID, udo);
	}

	private function onUserDisconnected(wsUUID:String) {
		LOG_INFO("onUserDisconnected " + wsUUID);
		unregisterUser(wsUUID);
	}

	private function unregisterUser(wsUUID:String) {
		if (users.exists(wsUUID)) {
			users.remove(wsUUID);
			userCount--;
			sendBroadcastUpdate();
		}
	}

	private function updateUser(wsUUID:String, udo:UserDataObject) {
		udo.wsUUID = wsUUID;

		if (users.exists(wsUUID) != true) {
			userCount++;
		}

		users.set(wsUUID, udo);
		sendBroadcastUpdate();
	}

	private function sendBroadcastUpdate() {
		WSServer.instance.updateAllConnections(getGlobalData());
	}

	private function getGlobalData():GlobalData {
		var data:GlobalData = new GlobalData();
		data.users = users;
		data.connectedUsers = userCount;
		return data;
	}
}
