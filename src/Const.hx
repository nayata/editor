class Const {
	public static var sceneWidth:Int = 960;
	public static var sceneHeight:Int = 600;
	public static var gridSize:Int = 60;

	public static var sceneMinWidth:Int = 100;
	public static var sceneMinHeight:Int = 100;
	public static var gridMinSize:Int = 10;

	public static var STAGE = 0;
	public static var SCENE = 1;
	public static var CURSOR = 2;
	public static var MENUS = 3;

	static var uniqueId = 0;

	public static inline function makeId() {
		return uniqueId++;
	}
}