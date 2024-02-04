package ui;

import h2d.col.Point;
import h2d.Graphics;
import h2d.Bitmap;
import tile.Tile;
import tile.Image;

import Types;


class Brush extends h2d.Object {
	public var width:Float = 10;
	public var height:Float = 10;

	public var state:State = Lock;
	public var tile:Image = null;


	public function new(?parent:h2d.Object) {
		super(parent);

		tile = new Image(this);
		tile.bitmap.tile =  hxd.Res.missing.toTile();
		tile.type = TileType.Image;
		tile.name = "empty";
	}

	
	public function set(entry:Tile) {
		tile.bitmap.tile = entry.bitmap.tile;
		tile.source = entry.source;

		tile.width = entry.width;
		tile.height = entry.height;

		tile.redraw();
	}


	public function update() {
		if (!visible) return;
	}
}