package spilehx.core.http;

import haxe.io.Bytes;
import haxe.Constraints.Function;
#if (js)
import haxe.http.HttpJs;
#else
import haxe.Http;
#end

class HTTPRequester {
	private var _data:String;
	private var _requestPath:String;
	private var _onSuccess:String->Void;
	private var _onError:Function;
	private var _path:String;

	private var additionalHeaders:Map<String, String>;

	public function new(url:String, data:String, onSuccess:Dynamic->Void, onError:Dynamic->Void) {
		_data = data;
		_requestPath = url;

		_onSuccess = onSuccess;
		_onError = onError;
	}

	public function addHeader(key:String, value:String) {
		if (additionalHeaders == null) {
			additionalHeaders = new Map<String, String>();
		}

		this.additionalHeaders.set(key, value);
	}

	public function get() {
		#if (js)
		var h:HttpJs = new HttpJs(_requestPath);
		#else
		var h:sys.Http = new sys.Http(_requestPath);
		h.onStatus = function(status:Int) {
			// trace("onStatus "+status);
		}
		#end
		h.onData = function(data:String) {
			_onSuccess(data);
		}

		h.onError = function(error) {
			_onError(error);
		}

		populateHeaders(h);
		h.request(false);
	}

	public function post() {
		#if (js)
		var h:HttpJs = new HttpJs(_requestPath);
		#else
		var h:Http = new haxe.Http(_requestPath);
		#end

		h.setPostData(_data);


		h.onData = function(data) {
			_onSuccess(data);
		}

		h.onError = function(error) {
			var responseAsString:String = h.responseBytes.getString(0, h.responseBytes.length, UTF8);
			_onError(error + " " + responseAsString);
		}

		populateHeaders(h);

		h.request(true);
	}

	private function populateHeaders(http) {
		if (additionalHeaders != null) {
			for (k in additionalHeaders.keys()) {
				http.addHeader(k, additionalHeaders[k]);
			}
		}
	}

}
