package editor;

import h2d.col.Point;
import h2d.Graphics;
import h2d.Bitmap;
import tile.Tile;

import Types;


class PathTool {
	public var tool:ui.Panel;

	var submit:ui.FileInput;
	var cencel:ui.FileInput;
	var color = 0xffffff;

	public var tile:Tile = null;
	public var selection:Point = null;


	public function new() {
		tool = new ui.Panel();

		tool.width = 240;
		tool.height = 40;

		submit = new ui.FileInput(tool, 40, 0, addPoint);
		submit.text = "Add Point";
		submit.setSize(120, 40);
		submit.setBackground(2, 5);
		submit.setPosition(-120-2, 0);
		submit.setIcon(0, 1);

		cencel = new ui.FileInput(tool, 40, 0, removePoint);
		cencel.text = "Remove";
		cencel.setSize(120, 40);
		cencel.setBackground(2, 5);
		cencel.setPosition(2, 0);
		cencel.setIcon(1, 1);

		tool.visible = false;
	}


	public function create(entry:Tile, path:Array<{x:Float, y:Float}>) {
		if (path == null) return;

		entry.path = [];
		entry.drawable = new Graphics(entry);

		for (point in path) {
			entry.path.push(new Point(point.x, point.y));
		}
		
		draw(entry);
	}


	public function event(type:String) {
		if (tile == null) return;

		switch (type) {
			case "add":
				if (tile.path == null) tile.path = [];
				if (tile.drawable == null) tile.drawable = new Graphics(tile);

				tile.path.push(new Point(tile.position.x+120, tile.position.y));
				draw(tile);
			case "remove":
				tile.path = null;
				tile.drawable.remove();
				tile.drawable = null;
			default:
		}
	}


	public function set(entry:Tile) {
		tile = entry;
		tool.visible = tile.hasPath();
		selection = null;
	}


	public function get():Tile {
		if (tile != null) return tile;
		return null;
	}


	public function draw(entry:Tile) {
		if (!entry.hasPath()) return;

		var px = entry.width * 0.5;
		var py = entry.height * 0.5;

		var w = entry.width * 0.5;
		var h = entry.height * 0.5;

		entry.drawable.clear();
		entry.drawable.beginFill(color, 1);
		entry.drawable.drawRect(px-4, py-4, 8, 8);
		entry.drawable.endFill();

		for (point in entry.path) {
			dashedLine(entry.drawable, px, py, point.x-entry.position.x+w, point.y-entry.position.y+h);

			px = point.x-entry.position.x+w;
			py = point.y-entry.position.y+h;
		}
	}


	public function remove() {
		tool.visible = false;
		tile = null;
	}


	function addPoint(e:hxd.Event) {
		var id = tile.path.length;
		var px = tile.path[tile.path.length-1].x+120;
		var py = tile.path[tile.path.length-1].y;

		if (selection != null) {
			id = tile.path.indexOf(selection)+1;
			px = selection.x+120;
			py = selection.y;
			selection = null;
		}

		tile.path.insert(id, new Point(px, py));
		draw(tile);
	}


	function removePoint(event:hxd.Event) {
		if (selection != null) {
			tile.path.remove(selection);
			selection = null;
		}
		else {
			tile.path.pop();
		}
		draw(tile);

		if (tile.path.length == 0) {
			tile.path = null;
			tile.drawable.remove();
			tile.drawable = null;
			tool.visible = false;
		}
	}


	function solidLine(drawable:Graphics, px:Float, py:Float, fx:Float, fy:Float) {
		drawable.lineStyle(2, color);
		drawable.moveTo(px, py);
		drawable.lineTo(fx, fy);

		drawable.lineStyle();
		drawable.beginFill(color, 1);
		drawable.drawEllipse(fx, fy, 8, 8, 0, 4);
		drawable.endFill();
	}


	function renderArrows(drawable:Graphics, px:Float, py:Float, fx:Float, fy:Float) {
		var angle = Math.atan2(fy-py, fx-px);
		var arrowAng = 3.141592653589793*0.75;
		var len = Math.sqrt((px-fx)*(px-fx) + (py-fy)*(py-fy));
		var dashLen = 30;
		var count = Std.int(len/dashLen);

		var dx = 0.0;
		var dy = 0.0;

		for (i in 1...count) {
			dx = px + Math.cos(angle)*(i*dashLen);
			dy = py + Math.sin(angle)*(i*dashLen);

			drawable.lineStyle(2, color);
			drawable.moveTo(dx+Math.cos(angle+arrowAng)*10, dy+Math.sin(angle+arrowAng)*10);
			drawable.lineTo(dx, dy);
			drawable.lineTo(dx+Math.cos(angle-arrowAng)*10, dy+Math.sin(angle-arrowAng)*10);
		}

		drawable.lineStyle();
		drawable.beginFill(color, 1);
		drawable.drawEllipse(fx, fy, 8, 8, 0, 4);
		drawable.endFill();
	}


	function diamondLine(drawable:Graphics, px:Float, py:Float, fx:Float, fy:Float) {
		var angle = Math.atan2(fy-py, fx-px);
		var len = Math.sqrt((px-fx)*(px-fx) + (py-fy)*(py-fy));
		var dashLen = 30;
		var count = Std.int(len/dashLen);

		var dx = 0.0;
		var dy = 0.0;

		for (i in 1...count) {
			dx = px + Math.cos(angle)*(i*dashLen);
			dy = py + Math.sin(angle)*(i*dashLen);

			drawable.beginFill(color, 1);
			drawable.drawEllipse(dx, dy, 4, 4, angle, 4);
			drawable.endFill();
		}

		drawable.lineStyle();
		drawable.beginFill(color, 1);
		drawable.drawEllipse(fx, fy, 8, 8, 0, 4);
		drawable.endFill();
	}


	function dotLine(drawable:Graphics, px:Float, py:Float, fx:Float, fy:Float) {
		var angle = Math.atan2(fy-py, fx-px);
		var len = Math.sqrt((px-fx)*(px-fx) + (py-fy)*(py-fy));
		var dashLen = 30;
		var count = Std.int(len/dashLen);

		var dx = 0.0;
		var dy = 0.0;

		for (i in 1...count) {
			dx = px + Math.cos(angle)*(i*dashLen);
			dy = py + Math.sin(angle)*(i*dashLen);

			drawable.beginFill(color, 1);
			drawable.drawRect(dx-3, dy-3, 6, 6);
			drawable.endFill();
		}

		drawable.lineStyle();
		drawable.beginFill(color, 1);
		drawable.drawEllipse(fx, fy, 8, 8, 0, 4);
		drawable.endFill();
	}


	function dashedLine(drawable:Graphics, px:Float, py:Float, fx:Float, fy:Float) {
		var angle = Math.atan2(fy-py, fx-px);
		var len = Math.sqrt((px-fx)*(px-fx) + (py-fy)*(py-fy));

		//var dashLen = 30;
		var dashLen = Math.max(Editor.ME.getGridSize(), 30);
		var count = Std.int(len/dashLen);

		var dx = 0.0;
		var dy = 0.0;

		for (i in 1...count) {
			dx = px + Math.cos(angle)*(i*dashLen-5);
			dy = py + Math.sin(angle)*(i*dashLen-5);

			drawable.lineStyle(5, color);
			drawable.moveTo(dx, dy);
			drawable.lineTo(dx+Math.cos(angle)*10, dy+Math.sin(angle)*10);
		}

		drawable.lineStyle();
		drawable.beginFill(color, 1);
		drawable.drawEllipse(fx, fy, 8, 8, 0, 4);
		drawable.endFill();
	}
}