package spilehx.p2pserver.framemessaging;

import js.Browser;
import js.html.MessageEvent;

class IframeMessaging extends Messaging{
  private var origin:String; // must match the host's origin

  public function new(origin:String) {
    super(origin)
    this.origin = origin;
    Browser.window.addEventListener("message", onMessage);

    sendToParent("child:ready", { ok: true, at: Date.now().getTime() });
  }

  public function sendToParent<T>(type:String, payload:T):Void {
    var env:MsgEnvelope<T> = {
      type: type,
      id: newId(),
      payload: payload
    };
    Browser.window.parent.postMessage(env, origin);
  }

  function onMessage(e:MessageEvent):Void {
    if (e.origin != origin) return;

    var env:Dynamic = e.data;
    if (env == null || env.type == null) return;

    switch (env.type:String) {
      case "host:hello":
        trace("Hello from host: " + Std.string(env.payload));
        // respond with some object
        sendToParent("child:data", { answer: 42, echo: env.payload });
      default:
    }
  }

  static inline function newId():String {
    return Std.string(Math.floor(Math.random() * 1e15));
  }
}
