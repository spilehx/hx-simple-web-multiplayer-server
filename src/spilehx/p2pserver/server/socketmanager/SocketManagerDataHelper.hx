package spilehx.p2pserver.server.socketmanager;

import spilehx.p2pserver.dataobjects.socketmessage.UserDirectMessage;
import spilehx.p2pserver.dataobjects.socketmessage.GlobalUpdateMessage;
import haxe.Constraints.Function;
import spilehx.p2pserver.dataobjects.socketmessage.SocketMessage;
import spilehx.p2pserver.dataobjects.socketmessage.RegisterUserMessage;
import spilehx.p2pserver.dataobjects.socketmessage.KeepAliveMessage;
import spilehx.p2pserver.dataobjects.socketmessage.GlobalMessage;
import spilehx.p2pserver.dataobjects.GlobalData;
import spilehx.p2pserver.dataobjects.UserDataObject;

class SocketManagerDataHelper {
	public static final SOCKET_EVENT_OPEN:String = "SOCKET_OPEN";
	public static final SOCKET_EVENT_CLOSE:String = "SOCKET_CLOSE";
	public static final SOCKET_EVENT_ERROR:String = "SOCKET_ERROR";
	public static final SOCKET_EVENT_REGISTERED:String = "SOCKET_REGISTER";
	public static final SOCKET_EVENT_KEEPALIVE:String = "SOCKET_KEEPALIVE";
	public static final SOCKET_EVENT_MESSAGE:String = "SOCKET_MESSAGE";

	private static final KEEP_ALIVE_DELAY:Float = 2000;

	@:isVar public var updateAllConnections(null, default):Dynamic->Void;
	@:isVar public var sendToUUID(null, default):String->Dynamic->Void;

	private var users:Map<String, UserDataObject>;
	private var globalData:GlobalData;
	private var userCount = 0;

	private var timeSinceKeepAlive:Float = 0;

	private var msgQueue:Array<Void->Void> = [];

	public function new() {
		globalData = new GlobalData();
		users = new Map<String, UserDataObject>();
	}

	public function onMessageHeartbeat() {
		if (msgQueue.length > 0) {
			while (msgQueue.length > 0) {
				// send all right away
				callNext();
			}
		} else {
			// do keep alive
			var now:Float = Date.now().getTime();
			var since:Float = now - timeSinceKeepAlive;

			if (since > KEEP_ALIVE_DELAY) {
				var keepAliveMessage:KeepAliveMessage = new KeepAliveMessage();
				keepAliveMessage.ts = now;
				updateAllConnections(keepAliveMessage);
				timeSinceKeepAlive = now;
			}
		}
	}

	private function sendToAllUsers(socketMessage:SocketMessage) {
		socketMessage.ts = Date.now().getTime();
		enqueueSendToAll(socketMessage);
	}

	private function sendToUser(udo:UserDataObject, socketMessage:SocketMessage) {
		socketMessage.ts = Date.now().getTime();
		enqueueSendToUser(udo, socketMessage);
	}

	public function registerUser(wsUUID:String) {
		if (users.exists(wsUUID) != true) {
			userCount++;
			var udo:UserDataObject = {
				wsUUID: wsUUID,
				userID: "",
				globalData: {},
				privateData: {}
			};
			users.set(wsUUID, udo);
		}
	}

	public function unregisterUser(wsUUID:String) {
		if (users.exists(wsUUID) == true) {
			users.remove(wsUUID);
			userCount--;
			sendToAllUsers(getGlobalMessage());
		}
	}

	public function onMessage(wsUUID:String, data:Dynamic) {
		if (data.messageType == new RegisterUserMessage().messageType) {
			onRegisterUserMessage(wsUUID, data);
		} else if (data.messageType == new GlobalUpdateMessage().messageType) {
			onGlobalUpdateMessage(wsUUID, data);
		} else if (data.messageType == new UserDirectMessage().messageType) {
			onUserDirectMessage(wsUUID, data);
		}
	}

	private function onUserDirectMessage(wsUUID:String, data:Dynamic) {
		var msg:UserDirectMessage = new UserDirectMessage();

		msg.fromUserID = data.data.fromUserID;
		msg.userID = data.data.userID;
		msg.data = data.data.data; // lol data, data data ffs TODO: fix this
		var targetUser:UserDataObject = findUserFromUserID(msg.userID);
		if (targetUser != null) {
			updateUserPrivateData(targetUser.wsUUID, msg);
		} else {
			LOG_ERROR("bad user");
		}
	}

	private function onGlobalUpdateMessage(wsUUID:String, data:Dynamic) {
		var msg:GlobalUpdateMessage = new GlobalUpdateMessage();
		populateFromDynamic(msg, data);
		updateUserGlobalData(wsUUID, msg);
	}

	private function onRegisterUserMessage(wsUUID:String, data:Dynamic) {
		var registerUserMessage:RegisterUserMessage = new RegisterUserMessage();
		populateFromDynamic(registerUserMessage, data);

		if (users.exists(wsUUID) == true) {
			var u:UserDataObject = users.get(wsUUID);
			u.userID = registerUserMessage.userID;
			users.set(wsUUID, u);
			sendToUser(u, registerUserMessage);
			sendToAllUsers(getGlobalMessage());
		}
	}

	private function updateUserPrivateData(wsUUID:String, userDirectMessage:UserDirectMessage) {
		if (users.exists(wsUUID) == true) {
			var u:UserDataObject = users.get(wsUUID);
			u.privateData = userDirectMessage;
			users.set(wsUUID, u);
			sendToUser(u, userDirectMessage);
		}
	}

	private function updateUserGlobalData(wsUUID:String, userGlobalMsg:GlobalUpdateMessage) {
		if (users.exists(wsUUID) == true) {
			var u:UserDataObject = users.get(wsUUID);
			u.globalData = userGlobalMsg.data;
			users.set(wsUUID, u);
			sendToAllUsers(getGlobalMessage());
		}
	}

	private function getGlobalMessage():GlobalMessage {
		// scrup private data
		var globalMessage:GlobalMessage = new GlobalMessage();
		globalData.connectedUsers = userCount;
		// globalData.users = [for (u in users) u];
		globalData.users = new Array<UserDataObject>();
		for (u in users){
			u.privateData = {};
			globalData.users.push(u);
		}

		globalMessage.data = globalData;
		return globalMessage;
	}

	public static function populateFromDynamic(target:Dynamic, newContentObjData:Dynamic) {
		var fields = Reflect.fields(target);
		for (field in fields) {
			if (Reflect.hasField(newContentObjData, field)) {
				var newValue:Dynamic = Reflect.getProperty(newContentObjData, field);
				Reflect.setField(target, field, newValue);
			}
		}
	}

	private function findUserFromUserID(value:String):Null<UserDataObject> {
		for (u in users) {
			if (u.userID == value) {
				return u;
			}
		}
		return null;
	}

	private function enqueueSendToAll(socketMessage:SocketMessage):Void {
		msgQueue.push(() -> updateAllConnections(socketMessage));
	}

	private function enqueueSendToUser(udo:UserDataObject, socketMessage:SocketMessage):Void {
		msgQueue.push(() -> sendToUUID(udo.wsUUID, socketMessage));
	}

	private function callNext():Bool {
		if (msgQueue.length == 0) {
			return false;
		}
		var fn = msgQueue.shift();
		fn();
		return true;
	}
}
