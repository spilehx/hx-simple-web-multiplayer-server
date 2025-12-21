package spilehx.p2pserver.dataobjects.socketmessage;

// This is the message a single user can send to update the global status
class GlobalUpdateMessage extends SocketMessage {
	@:isVar public var data(default, default):Dynamic;
	@:isVar public var userID(default, default):String;

	public function new() {
		super();
		data = {};
		userID = ""; // default
	}
}
