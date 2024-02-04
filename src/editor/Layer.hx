package editor;

import tile.Tile;


class Layer extends h2d.Object {
	public var type:Int = 0;
	public var tiles:Array<Tile> = [];
	public var atlas:String = "";

	
	public function new(?parent:h2d.Object) {
		super(parent);
	}

	public function orderItem(selected:Int, order:Int) {
		var tmp = children[selected];

		children[selected] = children[order];
		children[order] = tmp;
	}
}