package editor;

import hxd.Event;
import h3d.Vector;
import h2d.col.Point;
import hxd.Key;
import heaps.TextureAtlas;
import h2d.Bitmap;

import Types;


class TextureView extends heaps.Component {
	var atlas:TextureAtlas;
	var image:Bitmap = null;

	var input:h2d.Interactive;
	var scene:h2d.Object;
	var view:h2d.Bitmap;
	var bound:h2d.Graphics;
	var mask:h2d.Mask;

	var lock:h2d.Interactive;

	var position = new Point(0, 0);
	var expanded = new Point(0, 0);
	var dragging = new Point(0, 0);

	var empty:Bool = true;
	var active:Bool = false;
	var drag:Bool = false;

	var minZoom:Float = 0.2;
	var maxZoom:Float = 1.0;
	var zoomPower:Float = 0.125;
	var zoom:Float = 1;

	var handler:Void->Void;

	public var width:Int = 220;
	public var height:Int = 124;

	public var highlighted:String = "";
	public var selected:String = "";
	public var picked:Bool = false;


	public function new(?parent:h2d.Object, xpos:Float = 0, ypos:Float =  0, ?event:Void->Void) {
		super(parent);

		position.x = xpos;
		position.y = ypos;
		x = xpos;
		y = ypos;

		if (event != null) handler = event;

		input = new h2d.Interactive(220, 124, this);
		input.backgroundColor = 0xff444444;
		input.enableRightButton = true;
		input.cursor = Default;

		input.onClick = onClick;
		input.onWheel = onWheel;
		input.onMove = onMove;
		input.onOver = onOver;
		input.onOut = onOut;

		lock = new h2d.Interactive(220, 124, this);
		lock.cursor = Default;
		lock.onOut = unlock;
		lock.visible = false;
		
		view = new Bitmap(hxd.Res.view.toTile(), this);

		mask = new h2d.Mask(width, height, this);
		scene = new h2d.Object(mask);
		bound = new h2d.Graphics(scene);

		setSize(220, 124);
	}


	override public function update() {
		if (!active) return;

		if (hxd.Key.isDown(hxd.Key.MOUSE_MIDDLE)) {
			var mouse = globalToLocal(new Point(Editor.ME.s2d.mouseX, Editor.ME.s2d.mouseY));

			dragging.x = mouse.x - scene.x;
			dragging.y = mouse.y - scene.y;

			drag = true;
		}
		if (hxd.Key.isReleased(hxd.Key.MOUSE_MIDDLE)) {
			drag = false;
		}
	}


	function onWheel(event:Event) {
		if (empty || !active) return;

		input.focus();

		if (event.wheelDelta > 0) {
			zoom -= zoomPower;
		} else {
			zoom += zoomPower;
		}

		if (zoom < minZoom) zoom = minZoom;
		if (zoom > maxZoom) zoom = maxZoom;

		var ratio = 1 - zoom / scene.scaleX;

		var mouse = globalToLocal(new Point(Editor.ME.s2d.mouseX, Editor.ME.s2d.mouseY));

		scene.x += (mouse.x - scene.x) * ratio;
		scene.y += (mouse.y - scene.y) * ratio;

		scene.scaleX = scene.scaleY = zoom;
	}


	function onClick(e:hxd.Event) {
		if (!active) return;

		if (e.button == hxd.Key.MOUSE_LEFT) {
			if (highlighted != "") {
				selected = highlighted;
				if (handler != null) handler();

				setPosition(position.x, position.y);
				setSize(220, 124);

				active = false;
				picked = true;

				hideBound();
				setLock();
			}
		}
	}


	function onMove(e:hxd.Event) {
		if (!active) return;

		if (drag) {
			var mouse = globalToLocal(new Point(Editor.ME.s2d.mouseX, Editor.ME.s2d.mouseY));

			scene.x = mouse.x - dragging.x;
			scene.y = mouse.y - dragging.y;

			return;
		}

		var mouse = scene.globalToLocal(new Point(Editor.ME.s2d.mouseX, Editor.ME.s2d.mouseY));

		for (tile in atlas.regions) {
			var xMin:Float = tile.x;
			var yMin:Float = tile.y;
		
			var xMax:Float = tile.x + tile.w;
			var yMax:Float = tile.y + tile.h;

			if (mouse.x >= xMin && mouse.x < xMax && mouse.y >= yMin && mouse.y < yMax) {
				if (highlighted != tile.name) {
					highlighted = tile.name;

					setBound(xMin, yMin, tile.w, tile.h);
				}

				break;
			}
		}
	}


	function onOver(e:hxd.Event) {
		if (Editor.ME.missingTool()) {
			Editor.ME.showMessage("Use Select or Brush tool");
			return;
		}

		if (empty) return;
		if (active) return;
		if (picked) return;
		
		setSize(expanded.x, expanded.y);

		setPosition(-expanded.x+260, 0);
		input.focus();

		view.visible = true;
		highlighted = "";

		active = true;
	}


	function onOut(e:hxd.Event) {
		if (empty) return;

		highlighted = "";

		setPosition(position.x, position.y);
		setSize(220, 124);
		input.blur();

		view.visible = false;
		hideBound();

		active = false;
		drag = false;
	}


	function setLock() {
		var mouse = globalToLocal(new Point(Editor.ME.s2d.mouseX, Editor.ME.s2d.mouseY));

		if (mouse.x >= lock.x && mouse.x < lock.x+lock.width && mouse.y >= lock.y && mouse.y < lock.y+lock.height) {
			lock.visible = true;
		}
	}


	function unlock(e:hxd.Event) {
		lock.visible = false;
	}


	function setBound(xpos:Float = 0, ypos:Float =  0, w:Float, h:Float) {
		var line = 2 / zoom;

		bound.clear();
		bound.lineStyle(line, 0xFFE600);
		bound.drawRect(0, 0, w, h);

		bound.x = xpos;
		bound.y = ypos;

		bound.visible = true;
	}


	function hideBound() {
		bound.visible = false;
	}


	public function set(texture:TextureAtlas) {
		if (!empty) image.remove();

		atlas = texture;
		image = atlas.bitmap;
		scene.addChildAt(image, 0);

		scene.scaleX = scene.scaleY = 1;
		zoom = 1;

		scene.x = scene.y = 0;

		empty = false;
		view.visible = false;
		hideBound();
		onResize();
	}


	public function setSize(w:Float, h:Float) {
		width = Std.int(w);
		height = Std.int(h);

		input.width = width;
		input.height = height;

		mask.width = width;
		mask.height = height;
	}


	public function onResize() {
		if (empty) return;
		if (image == null) return;

		var safeBorder = 80;

		var w = Editor.ME.WIDTH - 300 - safeBorder;
		var h = Editor.ME.HEIGHT - parent.y - 40 - safeBorder;

		var sx = w / image.tile.width;
		var sy = h / image.tile.height;

		zoom = Math.min(sx, sy);
		zoom = Math.min(zoom, maxZoom);

		scene.scaleX = scene.scaleY = zoom;

		expanded.x = image.tile.width * zoom;
		expanded.y = image.tile.height * zoom;
	}


	public function clear() {
		if (empty) return;

		image.remove();
		view.visible = true;
		atlas = null;
		empty = true;
	}
}