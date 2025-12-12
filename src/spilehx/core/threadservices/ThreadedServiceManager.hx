package spilehx.core.threadservices;

// import squaresfeedserver.managers.SquaresFeedServerErrorManager;
// import squaresfeedserver.threadservices.Dispatcher.DispatcherMessage;
import spilehx.core.threadservices.Dispatcher.DispatcherMessage;
import haxe.Constraints.Function;
import haxe.Timer;
import sys.thread.Mutex;
import sys.thread.Thread;

class ThreadedServiceManager {
	private static final MAIN_THREAD_DATA_UPDATE_INTERVAL_MS:Int = 10;
	private static final THREAD_ERROR_BACKOFF_BEFORE_RESTART:Float = 1;
	private static final MAX_THREAD_ERROR_BEFORE_EXIT:Int = 10;

	private static var mutex = new Mutex();

	private var activeThreads:Array<ActiveThread>;

	@:isVar public var onTooManyThreadErrors(null, set):Function;

	private var threadErrors:Int = 0;
	private var dispatcherUpdateTimer:Timer;
	private var lastLoggedThreadCount:Int = 0;

	public static final instance:ThreadedServiceManager = new ThreadedServiceManager();

	private function new() {
		activeThreads = new Array<ActiveThread>();
	}

	public function addService(threadedServiceClass:Class<ThreadedService>, ?args:Array<Dynamic> = null, ?serviceThreadName:String = "",
			onServiceExit:Function) {
		if (args == null) {
			args = [];
		}

		startService(threadedServiceClass, args, serviceThreadName, onServiceExit);
		autoStartDataUpdate();
	}

	private function autoStartDataUpdate() {
		if (dispatcherUpdateTimer == null) {
			startUpdate();
		}
	}

	public function start() {
		startUpdate();
	}

	public function stop() {
		stopUpdate();
	}

	private function startUpdate() {
		dispatcherUpdateTimer = new Timer(MAIN_THREAD_DATA_UPDATE_INTERVAL_MS);
		dispatcherUpdateTimer.run = function() {
			updateDispatcher();
			checkThreadErrors();
		}
	}

	private function stopUpdate() {
		if (dispatcherUpdateTimer != null) {
			dispatcherUpdateTimer.stop();
		}
		dispatcherUpdateTimer = null;
	}

	private function updateDispatcher() {
		Dispatcher.instance.update();
	}

	private function checkThreadErrors() {
		if (threadErrors != ThreadedServiceErrorCounter.errorCount) {
			threadErrors = ThreadedServiceErrorCounter.errorCount;

			if (threadErrors >= MAX_THREAD_ERROR_BEFORE_EXIT) {
				if (onTooManyThreadErrors != null) {
					onTooManyThreadErrors();
				} else {
					ThreadedServiceErrorManager.notImplementedError("ThreadedServiceManager.checkThreadErrors()", "onTooManyThreadErrors not set!");
				}
			}
		}
	}

	private function startService(threadedServiceClass:Class<ThreadedService>, args:Array<Dynamic>, ?serviceThreadName:String = "",
			onServiceExitCallback:Function) {
		var serviceThread:Thread = Thread.createWithEventLoop(() -> {
			while (true) {
				try {
					var threadedService:ThreadedService = Type.createInstance(threadedServiceClass, args);

					mutex.acquire();

					var activeThread:ActiveThread = getActiveThreadFromRegisterByThread(Thread.current());
					if (activeThread != null) {
						activeThread.threadedService = threadedService;
					}

					mutex.release();

					// Do Thread work
					threadedService.onUpdate = function(msg:DispatcherMessage) {
						Dispatcher.instance.post(msg);
					}

					threadedService.onServiceExit = function() {
						if (onServiceExitCallback != null) {
							onServiceExitCallback(serviceThreadName);
						}

						if (activeThread != null) {
							killThread(activeThread);
						}
					}

					threadedService.triggerStart();
					break; // exit loop if start() exits cleanly
				} catch (e) {
					var threadedServiceClassName:String = Type.getClassName(threadedServiceClass).split(".").pop();
					ThreadedServiceErrorCounter.incrementErrorCount();
					ThreadedServiceErrorManager.onThreadError(threadedServiceClassName, ThreadedServiceErrorCounter.errorCount, Std.string(e));
					Sys.sleep(THREAD_ERROR_BACKOFF_BEFORE_RESTART);
				}
			}
		});

		registerThread(serviceThread, serviceThreadName);
	}

	public function killThread(targetActiveThread:ActiveThread) {
		mutex.acquire();
		if (targetActiveThread.threadedService != null) {
			targetActiveThread.threadedService.kill();
			unRegisterThread(targetActiveThread);
		}
		mutex.release();
	}

	public function getActiveThreadFromRegisterByThread(thread:Thread):ActiveThread {
		var at:ActiveThread = null;

		for (th in activeThreads) {
			if (th.thread == thread) {
				at = th;
				break;
			}
		}
		return at;
	}

	public function getActiveThreadFromRegisterByID(id:String):ActiveThread {
		var at:ActiveThread = null;

		var activeThreadsCopy = activeThreads.copy();
		mutex.acquire();
		for (th in activeThreadsCopy) {
			if (th.id == id) {
				at = th;
				break;
			}
		}
		mutex.release();
		return at;
	}

	public function getActiveThreads():Array<ActiveThread> {
		mutex.acquire();
		var at = activeThreads;

		mutex.release();
		return at;
	}

	private function registerThread(serviceThread:Thread, id:String) {
		mutex.acquire();
		activeThreads.push(new ActiveThread(serviceThread, id));
		mutex.release();
	}

	public function unRegisterThread(targetActiveThread:ActiveThread) {
		mutex.acquire();
		var index:Int = activeThreads.indexOf(targetActiveThread);

		if (index > -1) {
			activeThreads.splice(index, 1);
		}
		mutex.release();
	}

	function set_onTooManyThreadErrors(onTooManyThreadErrors):Function {
		return this.onTooManyThreadErrors = onTooManyThreadErrors;
	}
}

class ThreadedService {
	@:isVar public var onUpdate(get, set):DispatcherMessage->Void;
	@:isVar public var className(default, null):String;
	@:isVar public var onServiceExit(get, set):Function;

	public function new() {
		className = Type.getClassName(Type.getClass(this)).split(".").pop();
	}

	public function triggerStart() {
		start();
	}

	private function start() {
		LOG_INFO("Starting "+Type.getClassName(Type.getClass(this)).split(".").pop());
	}

	public function kill() {
		ThreadedServiceErrorManager.notImplementedError("ThreadedService.kill()", "kill() should be implemented by Override!");
	}

	private function updateData(dispatcherMessage:DispatcherMessage) {
		if (onUpdate != null) {
			onUpdate(dispatcherMessage);
		}
	}

	private function serviceExit() {
		LOG("ThreadedService.serviceExit()");
		if (onServiceExit != null) {
			onServiceExit();
		} else {
			ThreadedServiceErrorManager.notImplementedError("ThreadedService.serviceExit()", "serviceExit() should be implemented!");
		}
	}

	function get_onUpdate():DispatcherMessage->Void {
		return onUpdate;
	}

	function set_onUpdate(onUpdate):DispatcherMessage->Void {
		return this.onUpdate = onUpdate;
	}

	function get_onServiceExit():Function {
		return onServiceExit;
	}

	function set_onServiceExit(onServiceExit):Function {
		return this.onServiceExit = onServiceExit;
	}
}

class ActiveThread {
	@:isVar public var thread(get, null):Thread;
	@:isVar public var id(get, null):String;
	@:isVar public var threadedService(get, set):ThreadedService;

	public function new(thread:Thread, id:String) {
		this.thread = thread;
		this.id = id;
	}

	function get_id():String {
		return id;
	}

	function get_thread():Thread {
		return thread;
	}

	function get_threadedService():ThreadedService {
		return threadedService;
	}

	function set_threadedService(threadedService):ThreadedService {
		return this.threadedService = threadedService;
	}
}

class ThreadedServiceErrorCounter {
	public static var errorCount:Int = 0;
	private static var mutex = new Mutex();

	public static function incrementErrorCount():Int {
		mutex.acquire();
		errorCount++;
		var current = errorCount;
		mutex.release();
		return current;
	}
}
