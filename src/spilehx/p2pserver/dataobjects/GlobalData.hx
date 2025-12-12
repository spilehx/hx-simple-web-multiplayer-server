package spilehx.p2pserver.dataobjects;

class GlobalData {
    public var users:Map<String, UserDataObject>;
    public var connectedUsers:Int;
    public function new() {
        users = new Map<String, UserDataObject>();
        connectedUsers = 0;
    }
}