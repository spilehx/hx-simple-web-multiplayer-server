package spilehx.p2pserver.framemessaging;

class IframeMessaging extends Messaging {
	public function new(targetOrigin:String) {
		super(targetOrigin, Messaging.ENTITY_CHILD);
	}
}
