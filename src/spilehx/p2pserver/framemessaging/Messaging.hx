package spilehx.p2pserver.framemessaging;

import js.html.IFrameElement;
import js.html.MessageEvent;
import js.Browser;

class Messaging {
	private static final ENTITY_HOST:String = "host";
	private static final ENTITY_CHILD:String = "child";
	private static final MSG_TYPE_READY:String = "ready";
	private static final MSG_TYPE_DATA:String = "data";

	@:isVar public var MSG_READY(default, null):String;
	@:isVar public var MSG_DATA(default, null):String;

	@:isVar public var onMessage(default, default):Dynamic->Void;

	private var entity:String = "";

	private var targetReady:Bool = false;

	private var targetOrigin:String;
	private var iframe:IFrameElement; // used in parent page

	public function new(targetOrigin:String, entity:String) {
		this.entity = entity;
		MSG_READY = entity + ":" + MSG_TYPE_READY;
		MSG_DATA = entity + ":" + MSG_TYPE_DATA;
		this.targetOrigin = targetOrigin;
		Browser.window.addEventListener("message", onMessageReceived);
	}

	function newId():String {
		return Std.string(Math.floor(Math.random() * 1e15));
	}

	function onMessageReceived(e:MessageEvent):Void {
		if (e.origin != targetOrigin) {
			return;
		}

		var env:Dynamic = e.data;
		if (env == null || env.type == null) {
			return;
		}

		var msgType:String = env.type;
		var msgPayload:Dynamic = env.payload;

		if (msgType.split(":").pop() == MSG_TYPE_READY) {
			if (targetReady == false) {
				targetReady = true;
				sendReadyMessage(); // got ready message - respond in kind
			}
		} else if (msgType.split(":").pop() == MSG_TYPE_DATA) {
			if (onMessage != null) {
				onMessage(msgPayload);
			}
		} else {
			LOG_ERROR("Bad frame comms message: " + msgType);
		}
	}

	public function sendData(payload:Dynamic) {
		dispatchMessage(MSG_DATA, payload);
	}

	public function dispatchMessage<T>(type:String, payload:T):Void {
		var env:MsgEnvelope<T> = {
			type: type,
			id: newId(),
			payload: payload
		};

		if (entity == Messaging.ENTITY_CHILD) {
			Browser.window.parent.postMessage(env, targetOrigin);
		} else if (entity == Messaging.ENTITY_HOST) {
			iframe.contentWindow.postMessage(env, targetOrigin);
		} else {
			LOG_ERROR("BAT ENTITY  " + entity);
		}
	}

	public function sendReadyMessage() {
		dispatchMessage(MSG_READY, {ok: true, at: Date.now().getTime()});
	}
}
