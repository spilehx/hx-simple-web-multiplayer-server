package spilehx.p2pserver.server.socketmanager;

import haxe.Constraints.Function;
import spilehx.p2pserver.dataobjects.socketmessage.SocketMessage;
import spilehx.p2pserver.dataobjects.socketmessage.RegisterUserMessage;
import spilehx.p2pserver.dataobjects.socketmessage.KeepAliveMessage;
import spilehx.p2pserver.dataobjects.GlobalData;
import spilehx.p2pserver.dataobjects.UserDataObject;

class SocketManagerDataHelper {
	public static final SOCKET_EVENT_OPEN:String = "SOCKET_OPEN";
	public static final SOCKET_EVENT_CLOSE:String = "SOCKET_CLOSE";
	public static final SOCKET_EVENT_ERROR:String = "SOCKET_ERROR";
	public static final SOCKET_EVENT_REGISTERED:String = "SOCKET_REGISTER";
	public static final SOCKET_EVENT_KEEPALIVE:String = "SOCKET_KEEPALIVE";
	public static final SOCKET_EVENT_MESSAGE:String = "SOCKET_MESSAGE";

	@:isVar public var updateAllConnections(null, default):Dynamic->Void;
	@:isVar public var sendToUUID(null, default):String->Dynamic->Void;

	private var users:Map<String, UserDataObject>;
	private var userCount = 0;

	private var msgQueue:Array<Void->Void> = [];

	public function new() {
		users = new Map<String, UserDataObject>();
	}

	public function onMessageHeartbeat() {
		var queueItemCalled:Bool = callNext();
		if (queueItemCalled != true) {
			var keepAliveMessage:KeepAliveMessage = new KeepAliveMessage();
			keepAliveMessage.ts = Date.now().getTime();
			updateAllConnections(keepAliveMessage);
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
				data: ""
			};
			users.set(wsUUID, udo);
		}
	}

	public function unregisterUser(wsUUID:String) {
		if (users.exists(wsUUID) == true) {
			users.remove(wsUUID);
			userCount--;
		}
	}

	public function onMessage(wsUUID:String, data:Dynamic) {
		if (data.messageType == new RegisterUserMessage().messageType) {
			onRegisterUserMessage(wsUUID, data);
		}
	}

	private function onRegisterUserMessage(wsUUID:String, data:Dynamic) {
		var registerUserMessage:RegisterUserMessage = new RegisterUserMessage();
		populateFromDynamic(registerUserMessage, data);

		if (users.exists(wsUUID) == true) {
			var u:UserDataObject = users.get(wsUUID);
			u.userID = registerUserMessage.userID;
			users.set(wsUUID, u);

			sendToUser(u, registerUserMessage);
		}
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

	private function callAll():Void {
		while (callNext()) {}
	}

	private function clearQueue():Void {
		msgQueue.resize(0);
	}

	private inline function queuedCount():Int {
		return msgQueue.length;
	}
}
