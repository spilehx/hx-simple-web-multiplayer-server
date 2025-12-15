package spilehx.p2pserver.framemessaging;

typedef MsgEnvelope<T> = {
  var type:String;     // e.g. "hello", "data", "rpc:call"
  var id:String;       // correlation id for request/response (uuid-ish)
  var payload:T;
}
