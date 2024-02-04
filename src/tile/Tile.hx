package tile;

import h2d.col.Point;


class Tile extends h2d.Object {
	public var graphics:h2d.Graphics;
	public var drawable:h2d.Graphics;
	public var bitmap:h2d.Bitmap;
	
	public var width:Float;
	public var height:Float;

	public var position:h2d.col.Point = new h2d.col.Point(0, 0);
	
	public var label:h2d.Text;
	public var color:Int = -1;

	public var source:String = "";

	public var type:Int = 0;
	public var path:Array<Point>;
	public var data:String = "";
	public var tag:Int = -1;


	public function new(?parent:h2d.Object) {
		super(parent);
		graphics = new h2d.Graphics(this);
	}


	public function redraw() {
		var fill = color == -1 ? Editor.ME.colors[type] : Editor.ME.palette[color];

		graphics.clear();
		graphics.lineStyle(2, fill);
		graphics.beginFill(fill, 0.75);
		graphics.drawRect(1, 1, width-2, height-2);
		graphics.endFill();

		graphics.beginFill(fill, 0.75);
		graphics.drawRect(width/2-2, height/2-2, 4, 4);
		graphics.endFill();
	}
	

	public function setLabel() {
		if (name == "empty") return;

		if (label == null) {
			label = new h2d.Text(hxd.res.DefaultFont.get(), this);
			label.textAlign = h2d.Text.Align.Center;
			label.y = -20;
		}

		label.text = name;
		label.textColor = color == -1 ? Editor.ME.colors[type] : Editor.ME.palette[color];
		label.x = width * 0.5;
	}


	public function showLabel(value:Bool) {
		if (name == "empty") return;
		if (label != null) label.visible = value;
	}


	public function centerLabel() {
		if (label == null) return;
		label.x = width * 0.5;
	}


	public function hasPath():Bool {
		if (path != null && path.length > 0) return true;
		return false;
	}


	public function showPath(value:Bool) {
		if (!hasPath() || drawable == null) return;
		drawable.visible = value;
	}
}