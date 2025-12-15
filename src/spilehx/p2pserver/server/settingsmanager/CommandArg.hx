package spilehx.p2pserver.server.settingsmanager;

class CommandArg {
	@:isVar public var keyValue(default, null):String;
	@:isVar public var targetProperty(default, null):String;
	@:isVar public var description(default, null):String;

	public function new(keyValue:String, targetProperty:String, description:String) {
		this.keyValue = "-" + keyValue;
		this.targetProperty = targetProperty;
		this.description = description;
	}
}