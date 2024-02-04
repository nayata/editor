import hxd.Event;
import h3d.Vector;
import h2d.col.Point;
import hxd.Key;

import ui.Panel;
import editor.MenuPanel;
import editor.SidePanel;
import editor.AtlasPanel;
import editor.Properties;
import editor.PathTool;

import editor.Scene;
import editor.Layer;
import editor.Project;

import tile.Tile;
import tile.Image;

import Types;


class Editor extends hxd.App {
	public static var ME:Editor;

	public var WIDTH:Int = 1600;
	public var HEIGHT:Int = 900;

	public var project:Project = new Project();
	public var atlas:Array<Array<h2d.Tile>>;

	public var palette:Array<Int> = [0xd50000, 0x304ffe, 0x00a651, 0xffc107, 0xff5722, 0x985a44, 0x9e9e9e];
	public var colors:Array<Int> = [0x0496ff, 0xd81159, 0xb000d3, 0x80bc00, 0x7029cf, 0xffffff];

	var scene:Scene;
	
	var sceneWidth:Int = 960;
	var sceneHeight:Int = 600;
	var gridSize:Int = 60;

	var stage:h2d.Interactive;
	var view:editor.CursorGroup;
	var control:ui.Gizmo2D;
	var highlight:ui.Highlight;
	var brush:ui.Brush;
	
	var position = new Vector(0, 0, 0);
	var destination = new Vector(0, 0, 0);
	var transform = new Vector(0, 0, 0);
	var binding = new Vector(0, 0, 0);

	var step:Int = 10;
	var scaleSign:Int = 1;

	var tool:Action = Select;
	var state:State = Lock;

	var showName:Bool = true;
	var showPath:Bool = true;
	var showGrid:Bool = true;

	var layer:Layer = null;
	var tiles:Array<Tile> = [];
	var selected:Tile = null;

	var menuPanel:MenuPanel;
	var sidePanel:SidePanel;
	var atlasPanel:AtlasPanel;
	var itemPanel:Properties;

	var tooltip:ui.Tooltip;
	var message:ui.Message;
	var warning:ui.Warning;

	var pathTool:PathTool;
	var pathPanel:Panel;

	var minZoom:Float = 0.1;
	var maxZoom:Float = 9.0;
	var zoomPower:Float = 0.125;
	var zoom:Float = 1;
	
	
    static function main() {
		ME = new Editor();
    }


	override function init() {
		hl.UI.closeConsole();
		engine.backgroundColor = 0x282828;

		#if( hl && debug )
			hxd.Res.initLocal();
		#else
			hxd.Res.initEmbed();
		#end

		atlas = hxd.Res.ui.toTile().grid(40);

		initStage();
		initScene();
		initTools();

		onScene();
		onResize();
	}


	function initStage() {
		stage = new h2d.Interactive(s2d.width, s2d.height);
		stage.cursor = null;
		stage.onPush = onDown;
		stage.onMove = onMove;
		stage.onRelease = onUp;
		stage.onWheel = onWheel;
		stage.onOver = onOver;

		scene = new Scene();
		scene.addDefaultLayer();
		scene.setSize(sceneWidth, sceneHeight);
		scene.setGrid(gridSize);

		s2d.add(stage, Const.STAGE);
		s2d.add(scene, Const.SCENE);
	}


	function initScene() {
		sceneWidth = scene.width;
		sceneHeight = scene.height;
		gridSize = scene.gridSize;
		step = Std.int(gridSize /2);

		layer = scene.layer;
		tiles = layer.tiles;
	}


	function initTools() {
		menuPanel = new MenuPanel();
		menuPanel.setBorder(Side.Bottom);
		menuPanel.borderStyle(Side.Outer);
		menuPanel.setSize(WIDTH, 40);

		sidePanel = new SidePanel();
		sidePanel.setBorder(Side.Left);
		sidePanel.borderStyle(Side.Outer);
		sidePanel.setSize(300, HEIGHT-Style.borderSize);

		atlasPanel = sidePanel.atlasPanel;
		itemPanel = sidePanel.itemPanel;

		tooltip = new ui.Tooltip();
		message = new ui.Message();
		warning = new ui.Warning();

		pathTool = new PathTool();
		pathPanel = pathTool.tool;

		s2d.add(menuPanel, Const.MENUS);
		s2d.add(sidePanel, Const.MENUS);
		s2d.add(pathPanel, Const.MENUS);
		s2d.add(message, Const.MENUS);
		s2d.add(tooltip, Const.MENUS);
		s2d.add(warning, Const.MENUS);

		view = new editor.CursorGroup();
		s2d.add(view, Const.CURSOR);

		control = view.control;
		highlight = view.highlight;
		brush = view.brush;
	}


	function onScene() {
		hxd.Window.getInstance().title = scene.name;
		
		sceneWidth = scene.width;
		sceneHeight = scene.height;
		gridSize = scene.gridSize;
		step = Std.int(gridSize /2);

		layer = scene.layer;
		tiles = layer.tiles;

		sidePanel.scenePanel.scene = scene;
		sidePanel.layerPanel.scene = scene;

		layerEvent();

		setName(showName);
		setPath(showPath);

		setView();
	}


	function onDown(event:Event) {
		if (hxd.Key.isDown(hxd.Key.SPACE) || tool == Hand) {
			position.x = snap(s2d.mouseX - scene.x, 1);
			position.y = snap(s2d.mouseY - scene.y, 1);

			state = Hand;
			return;
		}

		var mouse = scene.globalToLocal(new Point(s2d.mouseX, s2d.mouseY));

		if (selected != null && tool == Image) {
			destination.x = snap(mouse.x, step);
			destination.y = snap(mouse.y, step);
				
			selected.x = destination.x - selected.width * 0.5;
			selected.y = destination.y - selected.height * 0.5;

			selected.position.x = selected.x + selected.width * 0.5;
			selected.position.y = selected.y + selected.height * 0.5;

			atlasPanel.onClick();
			setControl();

			tool = Select;

			return;
		}
		if (tool == Brush && brush.state == Draw) {
			destination.x = snap(mouse.x, step);
			destination.y = snap(mouse.y, step);

			var tileOverlap = onTile(tiles, brush.tile);
			if (tileOverlap == null) addFromImage(brush.tile);

			atlasPanel.onClick();

			state = Brush;

			return;
		}		
		if (tool == Add) {
			position.x = snap(mouse.x-30, gridSize);
			position.y = snap(mouse.y-30, gridSize);

			selected = addTile(position.x, position.y, gridSize, gridSize);
			setControl();

			position.x = snap(selected.x);
			position.y = snap(selected.y);

			binding.x = selected.x;
			binding.y = selected.y;

			state = Add;

			return;
		}
		if (tool == Draw) {
			position.x = snap(mouse.x-30, gridSize);
			position.y = snap(mouse.y-30, gridSize);

			if (position.x >= 0 && position.y >= 0 && position.x <= sceneWidth-gridSize && position.y <= sceneHeight-gridSize) {
				var type = layer.type == LayerType.Collision ? TileType.Static : TileType.Cell;
				var tileAtPoint = inTile(tiles, position.x, position.y);
				if (tileAtPoint == null) addTile(position.x, position.y, gridSize, gridSize, type);
			}

			selected = null;
			setControl();

			state = Draw;
			return;
		}
		if (tool == Erase) {
			var tileAtPoint = inTile(tiles, mouse.x, mouse.y);
			if (tileAtPoint != null) removeTile(tileAtPoint);

			selected = null;
			setControl();

			state = Erase;
			return;
		}

		if (selected != null && selected.hasPath() && showPath) {
			var size = 30;

			for (point in selected.path) {
				var xMin:Float = point.x - size;
				var yMin:Float = point.y - size;
				var xMax:Float = point.x + size;
				var yMax:Float = point.y + size;

				if (mouse.x >= xMin && mouse.x < xMax && mouse.y >= yMin && mouse.y < yMax) {
					pathTool.selection = point;
					
					position.x = snap(mouse.x-30, gridSize);
					position.y = snap(mouse.y-30, gridSize);

					view.highlight.setState(Move, selected.width, selected.height);
					view.highlight.setPosition(point.x, point.y);

					state = Path;
					return;
				}
			}
		}

		var selectedTile:Bool = false;

		var i = tiles.length-1;

		while (i >= 0) {
			var tile = tiles[i];

			var size = 10 / zoom;

			var xMin:Float = tile.x - size;
			var yMin:Float = tile.y - size;
		
			var xMax:Float = tile.x + tile.width + size;
			var yMax:Float = tile.y + tile.height + size;

			if (mouse.x >= xMin && mouse.x < xMax && mouse.y >= yMin && mouse.y < yMax) {
				selectedTile = true;
				selected = tile;

				break;
			}

			i--;
		}

		if (selectedTile) {
			position.x = snap(mouse.x, step) - selected.x;
			position.y = snap(mouse.y, step) - selected.y;

			control.x = selected.x + selected.width * 0.5;
			control.y = selected.y + selected.height * 0.5;
			
			control.setSize(selected.width, selected.height);

			state = control.getState(s2d.mouseX, s2d.mouseY);

			if (state == Scale) {
				position.x = snap(selected.x);
				position.y = snap(selected.y);

				binding.x = control.sideX == Left ? selected.x + selected.width : selected.x;
				binding.y = control.sideY == Top ? selected.y + selected.height : selected.y;

				transform.x = selected.width;
				transform.y = selected.height;
			}
			if (state == ScaleX) {
				binding.x = control.sideX == Left ? selected.x + selected.width : selected.x;
			}
			if (state == ScaleY) {
				binding.y = control.sideY == Top ? selected.y + selected.height : selected.y;
			}
		}

		if (!selectedTile) {
			selected = null;
		}

		setControl();
	}

	
	function onMove(event:Event) {
		var mouse = scene.globalToLocal(new Point(s2d.mouseX, s2d.mouseY));

		if (selected != null && tool == Image) {
			destination.x = snap(mouse.x, step);
			destination.y = snap(mouse.y, step);
				
			selected.x = destination.x - selected.width * 0.5;
			selected.y = destination.y - selected.height * 0.5;

			selected.position.x = selected.x + selected.width * 0.5;
			selected.position.y = selected.y + selected.height * 0.5;
		}

		if (state == Lock && tool == Brush) {
			destination.x = snap(mouse.x, step);
			destination.y = snap(mouse.y, step);
				
			brush.tile.x = destination.x - brush.tile.width * 0.5;
			brush.tile.y = destination.y - brush.tile.height * 0.5;

			brush.tile.position.x = brush.tile.x + brush.tile.width * 0.5;
			brush.tile.position.y = brush.tile.y + brush.tile.height * 0.5;
		}

		if (state == Brush && brush.state == Draw) {
			destination.x = snap(mouse.x, step);
			destination.y = snap(mouse.y, step);
				
			brush.tile.x = destination.x - brush.tile.width * 0.5;
			brush.tile.y = destination.y - brush.tile.height * 0.5;

			brush.tile.position.x = brush.tile.x + brush.tile.width * 0.5;
			brush.tile.position.y = brush.tile.y + brush.tile.height * 0.5;

			var tileOverlap = onTile(tiles, brush.tile);
			if (tileOverlap == null) addFromImage(brush.tile);
		}

		if (state == Hand) {
			scene.x = snap(s2d.mouseX - position.x, 1);
			scene.y = snap(s2d.mouseY - position.y, 1);
			view.x = scene.x;
			view.y = scene.y;
		}

		if (state == Draw) {
			destination.x = snap(mouse.x-30, gridSize);
			destination.y = snap(mouse.y-30, gridSize);

			if (destination.x != position.x || destination.y != position.y) {
				if (destination.x >= 0 && destination.y >= 0 && destination.x <= sceneWidth-gridSize && destination.y <= sceneHeight-gridSize) {
					var type = layer.type == LayerType.Collision ? TileType.Static : TileType.Cell;
					var tileAtPoint = inTile(tiles, destination.x, destination.y);
					if (tileAtPoint == null) addTile(destination.x, destination.y, gridSize, gridSize, type);

					position.x = destination.x;
					position.y = destination.y;
				}
			}
		}

		if (state == Erase) {
			var tile = inTile(tiles, mouse.x, mouse.y);
			if (tile != null) {
				if (tile == selected) {
					selected = null;
					setControl();
				}
				removeTile(tile);
			}
		}

		if (state == Path) {
			destination.x = snap(mouse.x, step);
			destination.y = snap(mouse.y, step);

			pathTool.selection.x = destination.x;
			pathTool.selection.y = destination.y;

			view.highlight.setPosition(destination.x, destination.y);

			onPosition(selected);
		}

		if (selected == null) return;

		var gridSnap:Int = hxd.Key.isDown(hxd.Key.CTRL) ? 1 : step;

		switch (state) {
			case Move:
				destination.x = snap(mouse.x, gridSnap);
				destination.y = snap(mouse.y, gridSnap);
					
				selected.x = destination.x - position.x;
				selected.y = destination.y - position.y;

				selected.position.x = selected.x + selected.width * 0.5;
				selected.position.y = selected.y + selected.height * 0.5;

				control.x = selected.x + selected.width * 0.5;
				control.y = selected.y + selected.height * 0.5;

				onPosition(selected);
			case Add:
				destination.x = snap(mouse.x, step);
				destination.y = snap(mouse.y, step);

				if (destination.x != position.x || destination.y != position.y) {
					control.sideX = destination.x > position.x ? Right : Left;
					control.sideY = destination.y > position.y ? Bottom : Top;

					binding.x = control.sideX == Left ? selected.x + selected.width : selected.x;
					binding.y = control.sideY == Top ? selected.y + selected.height : selected.y;
				}
					
				destination.x = Math.abs(destination.x-binding.x);
				destination.y = Math.abs(destination.y-binding.y);
					
				if (destination.x < gridSize) destination.x = gridSize;
				if (destination.y < gridSize) destination.y = gridSize;
	
				selected.width = destination.x;
				selected.height = destination.y;
	
				if (control.sideX == Left) selected.x = binding.x - selected.width;
				if (control.sideX == Right) selected.x = binding.x;
	
				if (control.sideY == Top) selected.y = binding.y - selected.height;
				if (control.sideY == Bottom) selected.y = binding.y;
						
				control.x = selected.x + selected.width * 0.5;
				control.y = selected.y + selected.height * 0.5;
	
				control.setSize(selected.width, selected.height);
				
				onTransform(selected);
			case Scale:
				destination.x = snap(mouse.x, gridSnap);
				destination.y = snap(mouse.y, gridSnap);
				
				destination.x = Math.abs(destination.x-binding.x);
				destination.y = Math.abs(destination.y-binding.y);
				destination.z = destination.x > destination.y ? destination.x : destination.y;
				
				if (destination.x < gridSize) destination.x = gridSize;
				if (destination.y < gridSize) destination.y = gridSize;
				if (destination.z < gridSize) destination.z = gridSize;

				selected.width = destination.x;
				selected.height = destination.y;

				if (hxd.Key.isDown(hxd.Key.SHIFT)) {
					if (transform.x > transform.y) {
						selected.width = destination.z;
						selected.height = selected.width*(transform.y/transform.x);
					}
					else {
						selected.width = selected.height*(transform.x/transform.y);
						selected.height = destination.z;
					}

					selected.width = snap(selected.width, 1);
					selected.height = snap(selected.height, 1);
				}

				if (control.sideX == Left) selected.x = binding.x - selected.width;
				if (control.sideX == Right) selected.x = binding.x;

				if (control.sideY == Top) selected.y = binding.y - selected.height;
				if (control.sideY == Bottom) selected.y = binding.y;

				selected.centerLabel();
					
				control.x = selected.x + selected.width * 0.5;
				control.y = selected.y + selected.height * 0.5;

				control.setSize(selected.width, selected.height);

				onTransform(selected);
			case ScaleX:
				destination.x = snap(mouse.x, gridSnap);
				destination.x = Math.abs(destination.x-binding.x);
				if (destination.x < gridSize) destination.x = gridSize;

				selected.width = destination.x;
				
				if (control.sideX == Left) selected.x = binding.x - selected.width;
				if (control.sideX == Right) selected.x = binding.x;

				selected.centerLabel();

				control.x = selected.x + selected.width * 0.5;
				control.y = selected.y + selected.height * 0.5;

				control.setSize(selected.width, selected.height);

				onTransform(selected);
			case ScaleY:
				destination.y = snap(mouse.y, gridSnap);
				destination.y = Math.abs(destination.y-binding.y);
				if (destination.y < gridSize) destination.y = gridSize;

				selected.height = destination.y;
				
				if (control.sideY == Top) selected.y = binding.y - selected.height;
				if (control.sideY == Bottom) selected.y = binding.y;

				selected.centerLabel();

				control.x = selected.x + selected.width * 0.5;
				control.y = selected.y + selected.height * 0.5;

				control.setSize(selected.width, selected.height);

				onTransform(selected);
			case Lock:
				var size = 10 / zoom;
				var over = false;

				var xMin:Float = selected.x - size;
				var yMin:Float = selected.y - size;
			
				var xMax:Float = selected.x + selected.width + size;
				var yMax:Float = selected.y + selected.height + size;
	
				if (mouse.x >= xMin && mouse.x < xMax && mouse.y >= yMin && mouse.y < yMax) {
					over = true;
				}
				control.setHover(s2d.mouseX, s2d.mouseY, over);

				if (selected.hasPath() && showPath) {
					view.highlight.visible = false;
					size = 30;
		
					for (point in selected.path) {
						xMin = point.x - size;
						yMin = point.y - size;
						xMax = point.x + size;
						yMax = point.y + size;
		
						if (mouse.x >= xMin && mouse.x < xMax && mouse.y >= yMin && mouse.y < yMax) {
							view.highlight.setState(Path, 60, 60);
							view.highlight.setPosition(point.x, point.y);
						}
					}
				}
			default:
		}

		itemPanel.update(selected);
	}

	
	function onUp(event:Event) {
		if (state == Image) setControl();
		view.highlight.visible = false;
		state = Lock;
	}


	inline function snap(value:Float, step:Int = 10) {
		return Math.round(value / step) * step;
	}


	function addTile(rx:Float, ry:Float, rw:Float, rh:Float, ?name:String = "empty", ?type:Int = 0, ?color:Int = -1):Tile {
		var tile = createTile(rx, ry, rw, rh, name, type, color);
			
		tiles.push(tile);
		layer.addChild(tile);

		return tile;
	}


	public function createTile(rx:Float, ry:Float, rw:Float, rh:Float, name:String, type:Int, color:Int = -1):Tile {
		var tile = new Tile();
			
		tile.x = rx;
		tile.y = ry;
		
		tile.width = rw;
		tile.height = rh;

		tile.position.x = rx+rw*0.5;
		tile.position.y = ry+rh*0.5;

		tile.name = name;
		tile.type = type;

		tile.color = color;

		color = color == -1 ? colors[tile.type] : palette[tile.color];
			
		tile.graphics.lineStyle(2, color);
		tile.graphics.beginFill(color, 0.75);
		tile.graphics.drawRect(1, 1, rw-2, rh-2);
		tile.graphics.endFill();

		tile.graphics.beginFill(color, 0.75);
		tile.graphics.drawRect(rw/2-2, rh/2-2, 4, 4);
		tile.graphics.endFill();

		tile.setLabel();
		tile.showLabel(showName);

		return tile;
	}


	function addFromImage(tile:Tile):Image {
		var image = new Image();

		image.bitmap.tile = tile.bitmap.tile;

		image.x = tile.x;
		image.y = tile.y;

		image.position.x = tile.position.x;
		image.position.y = tile.position.y;
			
		image.width = tile.width;
		image.height = tile.height;

		image.name = tile.name;
		image.source = tile.source;
		image.type = TileType.Image;

		tiles.push(image);
		layer.addChild(image);

		image.redraw();

		return image;
	}


	function onPosition(tile:Tile) {
		pathTool.draw(selected);
	}


	function onTransform(tile:Tile) {
		tile.position.x = tile.x + tile.width * 0.5;
		tile.position.y = tile.y + tile.height * 0.5;

		tile.redraw();
		pathTool.draw(selected);
	}


	function duplicateTile(tile:Tile) {
		if (tile == null) return;
		
		if (tile.type == TileType.Image) {
			selected = addFromImage(tile);
		}
		else {
			selected = addTile(tile.x, tile.y, tile.width, tile.height, tile.name, tile.type, tile.color);
		}

		selected.data = tile.data;
		selected.tag = tile.tag;

		showMessage("Tile duplicated");

		setControl();
	}


	function removeTile(tile:Tile) {
		if (tile == null) return;
		
		tiles.remove(tile);
		tile.remove();
	}


	function inTile(tiles:Array<Tile>, x:Float, y:Float):Tile {
		for (tile in tiles) {
			var xMin:Float = tile.x;
			var yMin:Float = tile.y;
		
			var xMax:Float = tile.x + tile.width;
			var yMax:Float = tile.y + tile.height;

			if (x >= xMin && x < xMax && y >= yMin && y < yMax) {
				return tile;
			}
		}

		return null;
	}


	function onTile(tiles:Array<Tile>, entry:Tile):Tile {
		for (tile in tiles) {
			if (intersect(tile, entry)) {
				return tile;
			}
		}
		return null;
	}


	function intersect(a:Tile, b:Tile):Bool {
		if (a.x >= b.x + b.width) return false;
		if (a.x + a.width <= b.x) return false;
		if (a.y >= b.y + b.height) return false;
		if (a.y + a.height <= b.y) return false;
		return true;
	}


	function setControl() {
		if (selected == null) {
			menuPanel.setTool(false);
			itemPanel.visible = false;
			control.visible = false;

			pathTool.remove();
			return;
		}

		menuPanel.setTool(true);
		itemPanel.update(selected);
		pathTool.set(selected);

		control.x = selected.x + selected.width * 0.5;
		control.y = selected.y + selected.height * 0.5;

		control.scaling = zoom;
		control.setSize(selected.width, selected.height);
		control.visible = true;
	}


	function setView() {
		if (sceneWidth > stage.width || sceneHeight > stage.height) {
			fitScreen();
		}
		else {
			resetView();
		}
	}


	function resetView() {
		zoom = 1;

		scene.scaleX = scene.scaleY = zoom;

		scene.x = WIDTH * 0.5 - sceneWidth * 0.5 - sidePanel.width * 0.5;
		scene.y = HEIGHT * 0.5 - sceneHeight * 0.5 + menuPanel.height * 0.5;

		scene.scaling = zoom;
		scene.update();

		control.scaling = zoom;
		control.update();

		view.setScale(zoom);
		view.setPosition(scene.x, scene.y);

		view.highlight.scaling = zoom;
		view.highlight.update();
	}


	function fitScreen() {
		var safeBorder = 20;

		var w = stage.width - safeBorder;
		var h = stage.height - safeBorder;

		var sx = w / sceneWidth;
		var sy = h / sceneHeight;

		zoom = Math.min(sx, sy);

		scene.scaleX = scene.scaleY = zoom;

		scene.x = w * 0.5 - (sceneWidth*zoom) * 0.5;
		scene.y = h * 0.5 - (sceneHeight*zoom) * 0.5;

		scene.x += safeBorder * 0.5 + Style.borderSize * 0.5;
		scene.y += menuPanel.height + safeBorder * 0.5 - Style.borderSize * 0.5;

		scene.scaling = zoom;
		scene.update();

		control.scaling = zoom;
		control.update();

		view.setScale(zoom);
		view.setPosition(scene.x, scene.y);

		view.highlight.scaling = zoom;
		view.highlight.update();
	}

	
	function onWheel(event:Event) {
		if (!stage.hasFocus()) return;

		if (event.wheelDelta > 0) {
			zoom -= zoomPower;
		} else {
			zoom += zoomPower;
		}

		if (zoom < minZoom) zoom = minZoom;
		if (zoom > maxZoom) zoom = maxZoom;

		var ratio = 1 - zoom / scene.scaleX;

		scene.x += (s2d.mouseX - scene.x) * ratio;
		scene.y += (s2d.mouseY - scene.y) * ratio;

		scene.scaleX = scene.scaleY = zoom;
		scene.scaling = zoom;
		scene.update();
  
		control.scaling = zoom;
		control.update();

		view.setScale(zoom);
		view.setPosition(scene.x, scene.y);

		view.highlight.scaling = zoom;
		view.highlight.update();
	}


	function onOver(e:hxd.Event) {
		stage.focus();
	}


	override function update(dt:Float) {
		super.update(dt);

		if (hxd.Key.isDown(hxd.Key.MOUSE_MIDDLE)) {
			position.x = snap(s2d.mouseX - scene.x, 1);
			position.y = snap(s2d.mouseY - scene.y, 1);

			state = Hand;
		}
		if (hxd.Key.isReleased(hxd.Key.MOUSE_MIDDLE)) {
			state = Lock;
		}

		if (hxd.Key.isDown(hxd.Key.MOUSE_RIGHT)) {
			state = Erase;
		}
		if (hxd.Key.isReleased(hxd.Key.MOUSE_RIGHT)) {
			state = Lock;
		}

		heaps.Component.updateAll();

		if (selected == null) return;
		if (s2d.mouseX > stage.width) return;

		var moving = false;
		var movingStep = 10;

		if (Key.isPressed(Key.UP)) {
			selected.y -= movingStep;
			moving = true;
		}
		if (Key.isPressed(Key.DOWN))  {
			selected.y += movingStep;
			moving = true;
		}
		if (Key.isPressed(Key.LEFT))  {
			selected.x -= movingStep;
			moving = true;
		}
		if (Key.isPressed(Key.RIGHT))  {
			selected.x += movingStep;
			moving = true;
		}

		if (moving) {
			selected.position.x = selected.x + selected.width * 0.5;
			selected.position.y = selected.y + selected.height * 0.5;

			control.x = selected.x + selected.width * 0.5;
			control.y = selected.y + selected.height * 0.5;

			itemPanel.update(selected);
			onPosition(selected);
		}
	}


	override function onResize() {
		super.onResize();

		WIDTH = hxd.Window.getInstance().width;
		HEIGHT = hxd.Window.getInstance().height;

		stage.width = WIDTH - sidePanel.width;
		stage.height = HEIGHT - menuPanel.height;
		stage.y = menuPanel.height;

		menuPanel.setSize(WIDTH, menuPanel.height);

		sidePanel.setSize(sidePanel.width, HEIGHT - menuPanel.height - Style.borderSize);
		sidePanel.x = WIDTH - sidePanel.width;
		sidePanel.y = menuPanel.height + Style.borderSize;
		sidePanel.onResize();

		pathPanel.x = stage.width * 0.5;
		pathPanel.y = 80;

		warning.onResize();

		setView();
	}


	//
	// Public API
	//

	public function toolEvent(event:Action) {
		disableTool();

		switch (event) {
			case Select:
				tool = event;
			case Hand:
				tool = event;
			case Add:
				tool = event;
			case Draw:
				tool = event;
				if (layer.type == LayerType.Atlas) tool = Brush;
			case Erase:
				tool = event;
			case Duplicate:
				if (selected != null) {
					duplicateTile(selected);
				}
			case Delete:
				if (selected != null) {
					removeTile(selected);
					selected = null;
					setControl();
				}
			default:
		}
	}


	function disableTool() {
		if (tool == Brush) {
			brush.visible = false;
			brush.state = Lock;
			state = Lock;
		}
	}


	public function tileEvent(event:MenuEvent, value:String = "") {
		if (selected == null) return;

		switch (event) {
			case posX:
				selected.position.x = Std.parseFloat(value);
				selected.x = selected.position.x - selected.width * 0.5;
				onPosition(selected);
			case posY:
				selected.position.y = Std.parseFloat(value);
				selected.y = selected.position.y - selected.height * 0.5;
				onPosition(selected);
			case Width:
				selected.width = Std.parseFloat(value);
				selected.centerLabel();
				onTransform(selected);
			case Height:
				selected.height = Std.parseFloat(value);
				onTransform(selected);
			case Name:
				selected.name = value;
				selected.setLabel();
				selected.showLabel(showName);
			case CustomColor:
				selected.color = getColor(selected.color);
				onTransform(selected);
				selected.setLabel();
			case DefaultColor:
				selected.color = -1;
				onTransform(selected);
				selected.setLabel();
			case Data:
				selected.data = value;
			case Tag:
				selected.tag = Std.parseInt(value);
			case Path:
				pathTool.event(value);
				selected.showPath(showPath);
			default:
		}
		setControl();
	}


	public function imageEvent(tile:Image) {
		selected = null;
		setControl();

		switch (tool) {
			case Select:
				tiles.push(tile);
				layer.addChild(tile);
		
				selected = tile;
				tool = Image;
			case Brush:
				brush.set(tile);
				brush.visible = true;
				brush.state = Draw;
			default:
		}
	}


	public function tileTypeEvent(value:Int) {
		if (selected == null) return;
		selected.type = value;
		selected.setLabel();
		onTransform(selected);
	}


	public function sceneEvent() {
		sceneWidth = scene.width;
		sceneHeight = scene.height;
		gridSize = scene.gridSize;
		step = Std.int(gridSize /2);
	}


	public function layerEvent() {
		layer = scene.layer;
		tiles = layer.tiles;

		menuPanel.setLayer(layer.type, tool);
		itemPanel.setLayer(layer.type);
		sidePanel.setLayer(layer.type);
		sidePanel.onResize();

		atlasPanel.onLayer(layer.atlas);
		disableTool();

		selected = null;
		setControl();
	}


	public function atlasAssigned():Bool {
		if (layer.atlas != "" && layer.tiles.length > 0) {
			showMessage("Layer Atlas already assigned");
			return true;
		}
		return false;
	}


	public function layerAtlasEvent(atlas:String) {
		layer.atlas = atlas;
	}


	public function missingTool():Bool {
		if (tool == Select || tool == Brush) return false;
		return true;
	}


	public function fileEvent(event:MenuEvent) {
		if (event == None) return;

		switch (event) {
			case New:
				project.filePath = "";
				project.resPath = "";

				disableTool();
				atlasPanel.clear();
				warning.visible = false;
				scene.remove();

				scene = new Scene();
				scene.addDefaultLayer();
				scene.setSize(Const.sceneWidth, Const.sceneHeight);
				scene.setGrid(Const.gridSize);
				scene.togleGrid(showGrid);
		
				s2d.add(scene, Const.SCENE);
				onScene();
			case Open:
				var data = project.open();
				if (data != null && data != "") loadScene(data);
			case Save:
				var file = project.save(scene);
				if (file) showMessage("Scene saved");
			case SaveAs:
				var file = project.save(scene, true);
				if (file) showMessage("Scene saved");
			case Export:
				var data = project.screenshot(scene);
				if (data) showMessage("Image saved");
				resetView();
			case About:
				hxd.System.openURL("https://github.com/nayata/editor");
			case Exit:
				hxd.System.exit();
			default:
		}
	}


	public function loadScene(string:String) {
		var entry = haxe.Json.parse(string);

		disableTool();
		atlasPanel.clear();
		warning.visible = false;
		scene.remove();

		scene = new Scene();
		scene.name = entry.name;
		scene.setSize(entry.width, entry.height);
		scene.setGrid(entry.gridSize);
		scene.togleGrid(showGrid);
		s2d.add(scene, Const.SCENE);

		var layers = entry.layers;

		for (i in 0...layers.length) {
			var item = layers[i];

			layer = scene.setLayer(item.type, item.name);

			switch (layer.type) {
				case LayerType.Collision:
					for (j in 0...item.tiles.length) {
						var data = item.tiles[j];

						var tile = createTile(data.originX, data.originY, data.width, data.height, data.name, data.type, data.color);
						tile.data = data.data;
						tile.tag = data.tag;

						pathTool.create(tile, data.path);

						layer.addChild(tile);
						layer.tiles.push(tile);
					}
				case LayerType.Image:
					for (j in 0...item.tiles.length) {
						var data = item.tiles[j];

						var tile = createImage(data.originX, data.originY, data.width, data.height, data.source, data.name);
						layer.addChild(tile);
						layer.tiles.push(tile);
					}
				case LayerType.Atlas:
					layer.atlas = item.atlas;
					
					if (layer.atlas != "") {
						var atlas = atlasPanel.load(project.resPath+layer.atlas+".atlas");

						if (atlas != null) {
							for (j in 0...item.tiles.length) {
								var data = item.tiles[j];

								var tile = createTexture(atlas, data.source, data.name, data.originX, data.originY, data.width, data.height);
								layer.addChild(tile);
								layer.tiles.push(tile);
							}
						}
						else {
							showWarning("There's no \"" + layer.atlas + ".atlas\" file\nin resource folder");
							layer.atlas = "";
						}
					}
				case LayerType.Grid:
					for (k in 0...item.grid.length) {
						var data = item.grid[k];

						var tile = createTile(data.cellX * entry.gridSize, data.cellY * entry.gridSize, entry.gridSize, entry.gridSize, "empty", TileType.Cell);
						layer.addChild(tile);
						layer.tiles.push(tile);
					}
				default:
			}
		}

		onScene();
	}


	function createImage(rx:Float, ry:Float, rw:Float, rh:Float, source:String, name:String):Tile {
		var file = project.resPath+source;

		var tile:h2d.Tile;
		if (sys.FileSystem.exists(file)) {
			var data = sys.io.File.getBytes(file);
			tile = hxd.res.Any.fromBytes(file, data).toImage().toTile();
		}
		else {
			tile = hxd.Res.missing.toTile();
		}

		var image = new Image();
		image.bitmap.tile = tile;

		image.x = rx;
		image.y = ry;
		
		image.width = rw;
		image.height = rh;

		image.position.x = rx+rw*0.5;
		image.position.y = ry+rh*0.5;

		image.name = name;
		image.source = source;
		image.type = TileType.Image;

		image.redraw();

		return image;
	}


	function createTexture(atlas:heaps.TextureAtlas, source:String, name:String, rx:Float, ry:Float, rw:Float, rh:Float):Tile {
		var image = new Image();
		image.bitmap.tile = atlas.get(source);

		image.x = rx;
		image.y = ry;
		
		image.width = rw;
		image.height = rh;

		image.position.x = rx+rw*0.5;
		image.position.y = ry+rh*0.5;

		image.name = name;
		image.source = source;
		image.type = TileType.Image;

		image.redraw();

		return image;
	}


	public function editEvent(event:MenuEvent) {
		if (event == None) return;
		if (selected == null) return;

		var position = tiles.indexOf(selected);

		switch (event) {
			case Front:
				selected = scene.orderItem(position, 1, true);
			case Forward:
				selected = scene.orderItem(position, 1, false);
			case Backward:
				selected = scene.orderItem(position, -1, false);
			case Back:
				selected = scene.orderItem(position, -1, true);
			case Top:
				selected.y = 0;
				selected.position.y = selected.y + selected.height * 0.5;
				onPosition(selected);
			case Vertical:
				selected.y = sceneHeight * 0.5 - selected.height * 0.5;
				selected.position.y = selected.y + selected.height * 0.5;
				onPosition(selected);
			case Bottom:
				selected.y = sceneHeight - selected.height;
				selected.position.y = selected.y + selected.height * 0.5;
				onPosition(selected);
			case Left:
				selected.x = 0;
				selected.position.x = selected.x + selected.width * 0.5;
				onPosition(selected);
			case Horizontal:
				selected.x = sceneWidth * 0.5 - selected.width * 0.5;
				selected.position.x = selected.x + selected.width * 0.5;
				onPosition(selected);
			case Right:
				selected.x = sceneWidth - selected.width;
				selected.position.x = selected.x + selected.width * 0.5;
				onPosition(selected);
			default:
		}

		setControl();
	}


	public function viewEvent(event:MenuEvent) {
		if (event == None) return;

		switch (event) {
			case ActualSize:
				resetView();
			case FitScreen:
				fitScreen();
			case ShowNames:
				setName(true);
			case HideNames:
				setName(false);
			case ShowPath:
				setPath(true);
			case HidePath:
				setPath(false);
			case ShowGrid:
				showGrid = true;
				scene.togleGrid(showGrid);
			case HideGrid:
				showGrid = false;
				scene.togleGrid(showGrid);
			default:
		}
	}


	function setName(value:Bool) {
		showName = value;

		for (l in scene.layers) {
			if (l.type == LayerType.Collision) {
				for (tile in l.tiles) {
					tile.showLabel(value);
				}
			}
		}
	}


	function setPath(value:Bool) {
		showPath = value;

		for (l in scene.layers) {
			if (l.type == LayerType.Collision) {
				for (tile in l.tiles) {
					tile.showPath(value);
				}
			}
		}
	}


	function getColor(value:Int):Int {
		if (++value > palette.length-1) value = 0;

		return value;
	}


	public function setTooltip(value:Bool, ?text:String = "") {
		tooltip.visible = value;

		tooltip.text = text;

		var px = snap(s2d.mouseX, 20);
		var py = snap(s2d.mouseY+20, 40) + 10;

		tooltip.x = px;
		tooltip.y = py;
	}


	public function showMessage(text:String = "") {
		message.text = text;
		message.x = stage.width*0.5;
		message.y = 52;
	}


	public function showWarning(text:String = "") {
		warning.text = text;
		warning.x = stage.width*0.5-warning.width*0.5;
		warning.y = 80;
	}


	public function getGridSize():Int {
		return step;
	}
 }