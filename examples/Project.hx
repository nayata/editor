typedef BodyData = {
	var name : String;
	var type : Int;
	var originX : Float;
	var originY : Float;
	var x : Float;
	var y : Float;
	var width : Float;
	var height : Float;
	var source : String;
	var data : String;
	var tag : Int;
	var path : Array<{x:Float, y:Float}>;
}


typedef GridData = {
	var cellX : Int;
	var cellY : Int;
}


typedef LayerData = {
	var name : String;
	var type : Int;
	var atlas : String;
	var tiles : Array<BodyData>;
	var grid : Array<GridData>;
}


typedef SceneData = {
	var name : String;
	var width : Float;
	var height : Float;
	var gridSize : Int;
	var layers : Array<LayerData>;
}

enum abstract LayerType(Int) to Int {
	var Collision;
	var Grid;
	var Image;
	var Atlas;
}


class Project {
	var colors:Array<Int> = [0x0496ff, 0xb000d3, 0x80bc00, 0xd81159, 0x7029cf, 0xffffff];
	public var scene:SceneData;
	

	public function new() {
	}


	public function load(file:String):SceneData {
		var raw = hxd.Res.load(file);
		scene = haxe.Json.parse(raw.entry.getText());
		return scene;
	}


	public function getEntity(name:String):BodyData {
		if (scene == null) return null;

		for (layer in scene.layers) {
			if (layer.type == LayerType.Collision) {
				for (tile in layer.tiles) {
					if (tile.name == name) return tile;
				}
			}
		}
		return null;
	}


	public function getLayer(name:String):LayerData {
		if (scene == null) return null;

		for (layer in scene.layers) {
			if (layer.name == name) return layer;
		}
		return null;
	}


	public function defaultLayer():LayerData {
		if (scene == null) return null;
		return scene.layers[0];
	}


	public function render(optimized:Bool = true):h2d.Object {
		if (scene == null) return null;

		var object = new h2d.Object();
		var item:h2d.Object;

		for (layer in scene.layers) {
			switch (layer.type) {
				case LayerType.Image:
					item = new h2d.Object(object);
					item.name = layer.name;

					renderImage(item, layer);
				case LayerType.Atlas:
					item = new h2d.Object(object);
					item.name = layer.name;

					if (optimized) {
						renderTile(item, layer);
					}
					else {
						renderTexture(item, layer);
					}
				default:
			}
		}

		return object;
	}


	public function debugRender():h2d.Object {
		if (scene == null) return null;

		var object = new h2d.Object();
		var item:h2d.Object;

		for (layer in scene.layers) {
			item = new h2d.Object(object);
			item.name = layer.name;

			for (tile in layer.tiles) {
				renderGraphics(item, colors[tile.type], tile.originX, tile.originY, tile.width, tile.height);
			}
			for (cell in layer.grid) {
				var size = scene.gridSize;
				renderGraphics(item, colors[4], cell.cellX * size, cell.cellY * size, size, size);
			}
		}

		return object;
	}


	public function renderLayer(name:String, optimized:Bool = true):h2d.Object {
		if (scene == null) return null;

		var object = new h2d.Object();
		var layer = getLayer(name);

		switch (layer.type) {
			case LayerType.Image:
				renderImage(object, layer);
			case LayerType.Atlas:
				if (optimized) {
					renderTile(object, layer);
				}
				else {
					renderTexture(object, layer);
				}
			default:
		}

		object.name = name;
		return object;
	}


	public function renderDebugLayer(name:String):h2d.Object {
		if (scene == null) return null;

		var object = new h2d.Object();
		var layer = getLayer(name);

		for (tile in layer.tiles) {
			renderGraphics(object, colors[tile.type], tile.originX, tile.originY, tile.width, tile.height);
		}
		for (cell in layer.grid) {
			var size = scene.gridSize;
			renderGraphics(object, colors[4], cell.cellX * size, cell.cellY * size, size, size);
		}

		object.name = name;
		return object;
	}


	function renderGraphics(object:h2d.Object, color:Int, x:Float, y:Float, w:Float, h:Float) {
		var graphics = new h2d.Graphics(object);

		graphics.lineStyle(2, color);
		graphics.beginFill(color, 0.75);
		graphics.drawRect(1, 1, w-2, h-2);
		graphics.endFill();
		graphics.beginFill(color, 0.75);
		graphics.drawRect(w/2-2, h/2-2, 4, 4);
		graphics.endFill();

		graphics.x = x;
		graphics.y = y;
	}


	function renderImage(object:h2d.Object, layer:LayerData) {
		for (tile in layer.tiles) {
			var image = new h2d.Bitmap(hxd.Res.load(tile.source).toImage().toTile());
	
			image.x = tile.originX;
			image.y = tile.originY;
			
			image.width = tile.width;
			image.height = tile.height;
	
			image.name = tile.name;

			object.addChild(image);
		}
	}


	function renderTexture(object:h2d.Object, layer:LayerData) {
		if (layer.tiles.length == 0) return;
		if (layer.atlas == "") return;

		var atlas = hxd.Res.load(layer.atlas+".atlas").to(hxd.res.Atlas);

		for (tile in layer.tiles) {
			var image = new h2d.Bitmap(atlas.get(tile.source));
	
			image.x = tile.originX;
			image.y = tile.originY;
			
			image.width = tile.width;
			image.height = tile.height;
	
			image.name = tile.name;

			object.addChild(image);
		}
	}


	function renderTile(object:h2d.Object, layer:LayerData) {
		if (layer.tiles.length == 0) return;
		if (layer.atlas == "") return;

		var atlas = hxd.Res.load(layer.atlas+".atlas").to(hxd.res.Atlas);
		var group = new h2d.TileGroup(object);

		for (tile in layer.tiles) {
			group.add(tile.originX, tile.originY, atlas.get(tile.source));
		}
	}
}