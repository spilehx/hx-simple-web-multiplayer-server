package spilehx.p2pserver.dataobjects.socketmessage;

class GlobalMessage extends SocketMessage {
	@:isVar public var data(default, default):GlobalData;

	public function new() {
		super();
		data = null;
	}
}
