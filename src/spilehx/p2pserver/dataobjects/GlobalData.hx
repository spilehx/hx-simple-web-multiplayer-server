package spilehx.p2pserver.dataobjects;

class GlobalData {
    public var users:Array<UserDataObject>;
    public var connectedUsers:Int;
    public function new() {
        users = new Array<UserDataObject>();
        connectedUsers = 0;
    }
}