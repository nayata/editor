package ui;

import hxd.Event;
import h3d.Vector;
import h2d.col.Point;
import Types;


class Gizmo2D extends h2d.Object {
	var graphics:h2d.Graphics;
	var highlight:h2d.Graphics;

	var bound:Bound = new Bound();
	var active:Bound = new Bound();
	var hover:Bound = new Bound();

	public var sideX:Side = None;
	public var sideY:Side = None;
		
	public var scaling:Float = 1;


	public function new(parent:h2d.Object) {
		super(parent);

		graphics = new h2d.Graphics(this);
		highlight = new h2d.Graphics(this);
	}


	public function getState(relX:Float, relY:Float):State {
		var mouse = this.globalToLocal(new Point(relX, relY));

		mouse.x -= bound.x;
		mouse.y -= bound.y;

		var px = mouse.x + bound.x;
		var py = mouse.y + bound.y;

		var x = (bound.width - 16) * 0.5;
		var y = (bound.height - 16) * 0.5;

		if( Math.abs(px) > x && Math.abs(py) > y ) {
			sideX = px > 0 ? Right : Left;
			sideY = py > 0 ? Bottom : Top;

			return Scale;
		}
		if( Math.abs(px) > x ) {
			sideX = px > 0 ? Right : Left;

			return ScaleX;
		}
		if( Math.abs(py) > y ) {
			sideY = py > 0 ? Bottom : Top;

			return ScaleY;
		}
		return Move;
	}


	public function setSize(w:Float, h:Float) {
		if (active.width == w && active.height == h) return;

		active.width = w;
		active.height = h;

		w = Math.ceil(w/2)*2;
		h = Math.ceil(h/2)*2;

		bound.x = -w * 0.5 - 5;
		bound.y = -h * 0.5 - 5;

		bound.width = w + 10;
		bound.height = h + 10;

		bound.size.x = w;
		bound.size.y = h;

		update();
	}


	public function setHover(relX:Float, relY:Float, value:Bool) {
		highlight.visible = value;
		if (!value) return;

		var mouse = this.globalToLocal(new Point(relX, relY));

		mouse.x -= bound.x;
		mouse.y -= bound.y;

		var px = mouse.x + bound.x;
		var py = mouse.y + bound.y;

		var x = (bound.width - 16) * 0.5;
		var y = (bound.height - 16) * 0.5;

		hover.x = 0;
		hover.y = 0;

		if( Math.abs(px) > x && Math.abs(py) > y ) {
			hover.x = px > 0 ? 1 : -1;
			hover.y = py > 0 ? 1 : -1;
		}
		else if( Math.abs(px) > x ) {
			hover.x = px > 0 ? 1 : -1;
			hover.y = 0;
		}
		else if( Math.abs(py) > y ) {
			hover.x = 0;
			hover.y = py > 0 ? 1 : -1;
		}

		updateHover();
	}


	public function update() {
		var width = bound.size.x;
		var height = bound.size.y;

		graphics.clear();
		graphics.beginFill(0xFFFFFF, 0.0);
		graphics.drawRect(-width*0.5-5, -height*0.5-5, width + 10, height + 10);
		graphics.endFill();

		var line = 1 / scaling;
		var size = 8 / scaling;
		var half = size / 2;

		graphics.lineStyle(line, 0x575757, 1.0);
		graphics.drawRect(-width*0.5, -height*0.5, width, height);

		graphics.lineStyle(line, 0xd1d1d1);

		graphics.beginFill(0x575757, 0.5);
		graphics.drawRect(-width*0.5-half, -height*0.5-half, size, size);
		graphics.drawRect(width*0.5-half, -height*0.5-half, size, size);
		graphics.drawRect(-width*0.5-half, height*0.5-half, size, size);
		graphics.drawRect(width*0.5-half, height*0.5-half, size, size);

		graphics.drawRect(-width*0.5-half, -half, size, size);
		graphics.drawRect(width*0.5-half, -half, size, size);
		graphics.drawRect(-half, -height*0.5-half, size, size);
		graphics.drawRect(-half, height*0.5-half, size, size);
		graphics.endFill();

		
		highlight.clear();
		highlight.beginFill(0xffffff, 0.75);
		highlight.drawRect(-half, -half, size, size);
		highlight.endFill();

		updateHover();
	}


	function updateHover() {
		if (hover.x == 0 && hover.y == 0) highlight.visible = false;
	
		highlight.x = bound.size.x * 0.5 * hover.x;
		highlight.y = bound.size.y * 0.5 * hover.y;
	}
}


class Bound {
	public var x:Float = 0;
	public var y:Float = 0;
	public var width:Float = 0;
	public var height:Float = 0;
	public var size:Point = new Point(0, 0);

	public function new() {
	}
}