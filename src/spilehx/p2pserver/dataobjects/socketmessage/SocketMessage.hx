package spilehx.p2pserver.dataobjects.socketmessage;

class SocketMessage {
	@:isVar public var messageType(default, default):String;
	@:isVar public var ts(default, default):Float;
	
	public function new() {
		messageType = Type.getClassName(Type.getClass(this)).split(".").pop();
		ts = 0;//default
	}
}
