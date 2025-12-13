package spilehx.p2pserver.framemessaging;

import js.html.IFrameElement;

class HostMessaging extends Messaging {
	public function new(iframe:IFrameElement, targetOrigin:String) {
		super(targetOrigin, Messaging.ENTITY_HOST);
		this.iframe = iframe;
	}
}
