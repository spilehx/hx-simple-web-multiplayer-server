package spilehx.p2pserver.dataobjects.socketmessage;

class RegisterUserMessage extends SocketMessage {
	@:isVar public var userID(default, default):String;

	public function new() {
		super();
		userID = ""; // default
	}
}
