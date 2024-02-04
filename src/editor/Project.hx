package editor;

import haxe.Json;
import editor.Scene;
import Types;


class Project {
	public var resPath:String = "";
	public var filePath:String = "";
	public var fileName:String = "scene";


	public function new() {
	}


	public function open():String {
		var title = "Open File";

		var nativeOptions:hl.UI.FileOptions = { }
		nativeOptions.title = "Open File";
		nativeOptions.filters = [{name: "json", exts: ["json"]}];

		var file = hl.UI.loadFile(nativeOptions);

		if (file != null) {
			resPath = haxe.io.Path.directory(file).split("\\").join("/")+"/";
			filePath = file;

			var text = sys.io.File.getContent(filePath);
			return text;
		} 
		else {
			return null;
		}

		return null;
	}


	public function save(scene:Scene, ?newFile:Bool = false):Bool {
		var data = [];

		for (layer in scene.layers) {
			var tiledata = [];
			var griddata = [];

			switch (layer.type) {
				case LayerType.Collision:
					for (tile in layer.tiles) {
						tiledata.push({name : tile.name, type : tile.type, originX : tile.x, originY : tile.y, x : tile.position.x, y : tile.position.y, width : tile.width, height : tile.height, source : "", color : tile.color, data : tile.data, tag : tile.tag, path : tile.path});
					}
				case LayerType.Image:
					for (tile in layer.tiles) {
						tiledata.push({name : tile.name, type : tile.type, originX : tile.x, originY : tile.y, x : tile.position.x, y : tile.position.y, width : tile.width, height : tile.height, source : tile.source, color : tile.color, data : tile.data, tag : tile.tag, path : null});
					}
				case LayerType.Atlas:
					for (tile in layer.tiles) {
						tiledata.push({name : tile.name, type : tile.type, originX : tile.x, originY : tile.y, x : tile.position.x, y : tile.position.y, width : tile.width, height : tile.height, source : tile.source, color : tile.color, data : tile.data, tag : tile.tag, path : null});
					}
				case LayerType.Grid:
					for (tile in layer.tiles) {
						var cx = Std.int(tile.position.x / scene.gridSize);
						var cy = Std.int(tile.position.y / scene.gridSize);
		
						griddata.push({cellX : cx, cellY : cy});
					}
				default:
			}

			data.push({name : layer.name, type : layer.type, atlas : layer.atlas, tiles : tiledata, grid : griddata});
		}

		var json = Json.stringify({
			name: scene.name,
			width: scene.width,
			height: scene.height,
			gridSize: scene.gridSize,
			layers: data
		});

		if (filePath != "" && newFile == false) {
			sys.io.File.saveContent(filePath, json);
			return true;
		}
		else {
			var nativeOptions:hl.UI.FileOptions = { }
			nativeOptions.title = "Save File";
			nativeOptions.fileName = scene.name + ".json";
			nativeOptions.filters = [{name: "json", exts: ["json"]}];

			var file = hl.UI.saveFile(nativeOptions);

			if (file != null) {
				resPath = haxe.io.Path.directory(file).split("\\").join("/");
				filePath = file;
				sys.io.File.saveContent(filePath, json);
				return true;
			}
		}

		return false;
	}


	public function screenshot(scene:Scene):Bool {
		var tex = new h3d.mat.Texture(scene.width, scene.height, [Target, IsNPOT, Serialize] );

		scene.x = scene.y = 0;
		scene.scaleX = scene.scaleY = 1;
		scene.drawTo(tex);
	
		var pixels = tex.capturePixels();

		var nativeOptions:hl.UI.FileOptions = { }
		nativeOptions.title = "Save Image";
		nativeOptions.fileName = scene.name + ".png";
		nativeOptions.filters = [{name: "png", exts: ["png"]}];

			var file = hl.UI.saveFile(nativeOptions);

			if (file != null) {
				filePath = file;
				sys.io.File.saveBytes(filePath, pixels.toPNG());
				return true;
			}

		return false;
	}
}