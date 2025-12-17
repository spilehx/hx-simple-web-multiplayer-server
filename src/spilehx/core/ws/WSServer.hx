package spilehx.core.ws;

import hx.ws.Types.MessageType;
import hx.ws.SocketImpl;
import hx.ws.WebSocketServer;
import hx.ws.WebSocketHandler;

class WSServer {
	@:isVar public var activeConnections(get, null):Int;

	private var server:WebSocketServer<WSServerHandler>;
	private var host:String;
	private var port:Int;
	private var maxConnections:Int;

	public var onConnectionOpened:String->Void;
	public var onConnectionClosed:String->Void;
	public var onConnectionError:String->Void;
	public var onMessage:String->String->Void;

	public static final instance:WSServer = new WSServer();

	private function new(?maxConnections:Int = 200, ?port:Int = 5000) {
		this.host = getHost();
		this.maxConnections = maxConnections;
		this.port = port;
	}

	public function start() {
		server = new WebSocketServer<WSServerHandler>(host, port, maxConnections);
		server.start();
	}

	public function stop() {
		server.stop();
	}

	public function connectionOpened(uuid:String) {
		if (onConnectionOpened != null) {
			onConnectionOpened(uuid);
		}
	}

	public function connectionClosed(uuid:String) {
		if (onConnectionClosed != null) {
			onConnectionClosed(uuid);
		}
	}

	public function connectionError(uuid:String) {
		LOG_ERROR("Connection error " + uuid);
		if (onConnectionError != null) {
			onConnectionError(uuid);
		}
	}

	public function updateAllConnections(dataObject:Dynamic) {
		if (server != null) {
			for (handler in server.handlers) {
				var wsServerHandler:WSServerHandler = cast(handler);
				wsServerHandler.sendDataObJect(dataObject);
			}
		}
	}

	public function sendToUUID(wsUUID:String, dataObject:Dynamic) {
		for (handler in server.handlers) {
			var wsServerHandler:WSServerHandler = cast(handler);
			if (wsServerHandler.id == wsUUID) {
				wsServerHandler.sendDataObJect(dataObject);
				return;
			}
		}
	}

	function get_activeConnections():Int {
		this.activeConnections = server.totalHandlers();
		return activeConnections;
	}

	function getHost():String {
		// for setting the WS Server host based on where deployed
		var host:String;
		if (WSServer.isRunningInDocker()) {
			host = "0.0.0.0";
		} else {
			host = "localhost";
		}

		return host;
	}

	public static function isRunningInDocker():Bool {
		// for detecting if a HL app is running in docker
		// often used as a 'trick' to decide if the app is deployed (ie live)
		var pathToDockerEnv:String = "/.dockerenv";
		var isRunningInDocker:Bool = sys.FileSystem.exists(pathToDockerEnv);
		return isRunningInDocker;
	}
}

class WSServerHandler extends WebSocketHandler {
	public function new(s:SocketImpl) {
		super(s);
		onopen = onOpen;
		onclose = onClose;
		onerror = onError;
		onmessage = onMessage;
	}

	private function onOpen() {
		WSServer.instance.connectionOpened(id);
	}

	public function sendDataObJect(obj) {
		var dataString:String = WSDataTools.objectDataString(obj);
		send(dataString);
	}

	private function onClose() {
		WSServer.instance.connectionClosed(id);
	}

	private function onError(error) {
		WSServer.instance.connectionError(id);
	}

	private function onMessage(message:MessageType) {
		switch (message) {
			case BytesMessage(content):
				LOG_WARN("Unexpected bytes message recieved");
				trace(content.readAllAvailableBytes());
			case StrMessage(content):
				if (WSServer.instance.onMessage != null) {
					WSServer.instance.onMessage(id, content);
				}
		}
	}
}
