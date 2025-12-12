package spilehx.core.threadservices;

// import cricket8.squares.dataobjects.NewMatchData;
// import cricket8.squares.dataobjects.UserDataObject;
// import squaresfeedserver.SquaresFeedServerController;
// import cricket8.squares.dataobjects.MatchData;
import sys.thread.Mutex;

/*
	Singleton that handles all state updates and message processing on the main thread.
 */
class Dispatcher {
	private var queue = new MessageQueue<DispatcherMessage>();

	public static final instance:Dispatcher = new Dispatcher();

	private function new() {}

	// Posts a message to the dispatcher queue.
	public function post(msg:DispatcherMessage):Void {
		queue.push(msg);
	}

	// Updates internal state or processes queued messages.
	public function update():Void {
// 		for (msg in queue.popAll()) {
// 			switch (msg) {
// 				case DecimalMatchListUpdated(matchListIDs):
// 					SquaresFeedServerController.instance.onDecimalMatchListUpdated(matchListIDs);
// 				case UpdateNewMatchData(newMatchData):
			
// 					SquaresFeedServerController.instance.onUpdateNewMatchData(newMatchData);
// //TODO:TIDEY REMOVE OLD IMPLEMTATION
// 				// case UpdateMatchDataArray(matchDataArray):
// 				// 	// SquaresFeedServerModel.instance.updateMatchDataArray(matchDataArray);
// 				// 	SquaresFeedServerController.instance.onUpdateMatchDataArray(matchDataArray);

// 				// case UpdateMatchData(matchData):
// 				// 	SquaresFeedServerController.instance.onUpdateMatchData(matchData);
				
// 				case UpdateActiveUserData(userDataObject):
// 					SquaresFeedServerController.instance.onUpdateActiveUserData(userDataObject);
// 					// SquaresFeedServerModel.instance.updateMatchData(matchData);
// 			}
// 		}
	}
}

/*
	Enum defining messages passed between threads to update the DataModel or manage Subscribers.
 */
enum DispatcherMessage {
	// UpdateMatchDataArray(matchDataArray:Array<MatchData>);
	// UpdateMatchData(matchData:MatchData);

	// UpdateActiveUserData(userDataObject:UserDataObject);

	// //New system
	// UpdateNewMatchData(newMatchData:NewMatchData);
	// 	DecimalMatchListUpdated(matchListIDs:Array<String>);
}

/*
	Thread-safe message queue used to store and transfer messages between threads.
 */
class MessageQueue<T> {
	var queue:Array<T> = [];
	var mutex:Mutex = new Mutex();

	// Performs a specific operation in the application.
	public function new() {}

	// Pushes a message to the internal queue.
	public function push(msg:T):Void {
		mutex.acquire();
		queue.push(msg);
		mutex.release();
	}

	// Function: popAll - Describe what this function does.
	public function popAll():Array<T> {
		mutex.acquire();
		var copy = queue.copy();
		queue = [];
		mutex.release();
		return copy;
	}
}
