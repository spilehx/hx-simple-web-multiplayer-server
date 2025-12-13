package spilehx.p2pserver.framemessaging;

import js.Browser;
import js.html.IFrameElement;
import js.html.MessageEvent;

class HostMessaging {
  private var iframe:IFrameElement;
  private var targetOrigin:String;

  

  public function new(iframe:IFrameElement, targetOrigin:String) {
    this.iframe = iframe;
    this.targetOrigin = targetOrigin;
    Browser.window.addEventListener("message", onMessage);
  }

  public function sendToIframe<T>(type:String, payload:T):Void {
    // Ensure iframe is loaded before calling this (or queue until onload)
    var env:MsgEnvelope<T> = {
      type: type,
      id: newId(),
      payload: payload
    };
    iframe.contentWindow.postMessage(env, targetOrigin);
  }

  function onMessage(e:MessageEvent):Void {
    // 1) verify origin
    if (e.origin != targetOrigin){
      return;
    }

    // 2) verify source is actually our iframe
    if (e.source != iframe.contentWindow){
       return;
    }

    // 3) parse envelope
    var env:Dynamic = e.data;
    if (env == null || env.type == null) {
      return;
    }

    switch (env.type:String) {
      case "child:ready":
        trace("Child ready: " + Std.string(env.payload));
      case "child:data":
        trace("Got data from child: " + Std.string(env.payload));
      default:
        // ignore unknown types
    }
  }

  static inline function newId():String {
    return Std.string(Math.floor(Math.random() * 1e15));
  }
}
