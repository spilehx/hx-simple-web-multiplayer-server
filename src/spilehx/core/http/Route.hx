package spilehx.core.http;

class Route {
	static var GET_METHOD:String = "GET";
	static var POST_METHOD:String = "POST";
	static var PUT_METHOD:String = "PUT";
	static var HEAD_METHOD:String = "HEAD";

	@:isVar public var path(default, null):String;
	public var dataObjectClassName:String;
	public var dataObjectClass:Class<RestDataObject>;

	#if (!js)
	private var response:weblink.Response;
	private var request:weblink.Request;

	public function new(path:String, dataObject:RestDataObject, methodType:String, server:weblink.Weblink) {
		this.path = path;
		this.dataObjectClass = Type.getClass(dataObject);
		if (methodType == GET_METHOD) {
			server.get(path, handler);
			server.post(path, notImplementedHandler);
			server.put(path, notImplementedHandler);
		} else if (methodType == POST_METHOD) {
			server.post(path, handler);
			server.get(path, notImplementedHandler);
			server.put(path, notImplementedHandler);
		} else if (methodType == PUT_METHOD) {
			server.put(path, handler);
			server.get(path, notImplementedHandler);
			server.post(path, notImplementedHandler);
		} else if (methodType == HEAD_METHOD) {
			server.head(path, handler);
		} else {
			LOG_ERROR("Method Not Found");
		}
	}

	private function notImplementedHandler(request:weblink.Request, response:weblink.Response) {
		var err:String = "BAD METHOD " + Date.now() + " , " + request.method + " , " + request.path;
		LOG_WARN(err);

		var responseObject = {err: err};
		var responseContent:String = haxe.Json.stringify(responseObject, "\t");
		this.response = response;
		addHeadersToResponse(this.response);
		this.response.status = 400;
		this.response.send(responseContent);
	}

	private function handler(request:weblink.Request, response:weblink.Response) {
		this.response = response;
		this.request = request;
		onRequest(request);
	}

	private function sendGenericBadRequestResponse(?msg:String = null) {
		var err:String = " Internal Server Error " + Date.now() + " , " + request.method + " , " + request.path;
		LOG_WARN(err);

		if (msg != null) {
			err = err + " , " + msg;
		}

		var responseObject = {err: err};
		var responseContent:String = haxe.Json.stringify(responseObject, "\t");
		addHeadersToResponse(this.response);
		this.response.status = 500;
		this.response.send(responseContent);
	}

	private function onRequest(request:weblink.Request) {
		var genericRequestDataObject:RestDataObject = new RestDataObject();
		var requestDataObjectInstance = Type.createInstance(dataObjectClass, []);
	}

	function onServerNewRequest(requestDataObjectInstance:Dynamic) {
		LOG_WARN("onServerNewRequest -  Override in child class");
		respond(requestDataObjectInstance);
	}

	function onServerGetRequest(requestDataObjectInstance:Dynamic) {
		LOG_WARN("onServerGetRequest -  Override in child class");
		respond(requestDataObjectInstance);
	}

	function onServerSetRequest(requestDataObjectInstance:Dynamic) {
		LOG_WARN("onServerSetRequest -  Override in child class");
		respond(requestDataObjectInstance);
	}

	private function respond(responseObject:RestDataObject) {
		var responseContent:String = haxe.Json.stringify(responseObject, "\t");
		addHeadersToResponse(this.response);
		this.response.send(responseContent);
	}

	private function addHeadersToResponse(response:weblink.Response) {
		// TODO: Security issue?
		this.response.headers.add("Access-Control-Allow-Origin", "*");
	}
	#end
}
