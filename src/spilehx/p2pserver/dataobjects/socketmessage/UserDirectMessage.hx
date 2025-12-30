package spilehx.p2pserver.dataobjects.socketmessage;

// This is the message a single user can send private to another user
class UserDirectMessage extends SocketMessage {
	@:isVar public var data(default, default):Dynamic;
	@:isVar public var userID(default, default):String;
	@:isVar public var fromUserID(default, default):String;

	public function new() {
		super();
		data = {};
		userID = ""; // default
		fromUserID = ""; // default
	}
}
