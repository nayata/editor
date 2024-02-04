package editor;

import heaps.TextureAtlas;
import h2d.Bitmap;
import tile.Image;
import ui.Label;

import Types;


class AtlasPanel extends ui.Panel {
	public var atlas:Map<String, TextureAtlas> = new Map();

	var view:editor.TextureView;
	var input:ui.FileInput;

	var current:String = "";


	public function new(?parent:h2d.Object) {
		super(parent);

		setBorder(Side.Bottom);
		borderStyle(Side.Inner);
		setSize(300, 40 + 20 + 124 + 40 + Style.borderSize);

		input = new ui.FileInput(this, 40, 0, onChange);
		input.text = "Add Atlas";
		input.setIcon(3, 2);

		view = new editor.TextureView(this, 40, 60, onSelect);

		visible = false;
	}


	function onChange(event:hxd.Event) {
		if (Editor.ME.atlasAssigned()) return;

		var nativeOptions:hl.UI.FileOptions = { }
		nativeOptions.title = "Open File";
		nativeOptions.filters = [{name: "atlas", exts: ["atlas"]}];

		var file = hl.UI.loadFile(nativeOptions);

		if (file != null) {
			var texture = load(file);
			view.set(texture);

			input.text = wrap(texture.name);
			current = texture.name;

			Editor.ME.layerAtlasEvent(texture.name);
		}
	}


	function onSelect() {
		var name = view.selected;

		var tile = atlas[current].get(name);

		var image = new Image();
		image.bitmap.tile = tile;
			
		image.width = tile.width;
		image.height = tile.height;

		image.name = "empty";
		image.source = name;
		image.type = TileType.Image;

		image.x = Editor.ME.s2d.mouseX - image.width * 0.5;
		image.y = Editor.ME.s2d.mouseY - image.height * 0.5;

		Editor.ME.imageEvent(image);
	}


	public function onLayer(name:String) {
		if (name == current) return;

		if (name == "") {
			view.clear();
			input.text = "Add Atlas";
			current = "";

			return;
		}

		var texture = atlas[name];
		view.set(texture);

		input.text = wrap(name);
		current = name;
	}


	public function load(file:String):TextureAtlas {
		var res = Editor.ME.project.resPath;
		var raw = file.substr(res.length).split("\\").join("/");
		var src = res == "" ? haxe.io.Path.withoutDirectory(file) : raw;

		var name = src.split(".").shift();

		if (atlas.exists(name)) return atlas[name];
		if (!sys.FileSystem.exists(file)) return null;

		var entry = sys.io.File.getContent(file);

		var path = haxe.io.Path.directory(file).split("\\").join("/");
		var link = haxe.io.Path.withoutDirectory(file).split(".").shift();
		var data = sys.io.File.getBytes(path+"/"+link+".png");
		var tile = hxd.res.Any.fromBytes(file, data).toImage().toTile();
		var bitmap = new h2d.Bitmap(tile);

		var texture = new heaps.TextureAtlas(entry, bitmap);
		texture.name = name;

		atlas[name] = texture;

		return texture;
	}


	public function onClick() {
		view.picked = false;
	}


	public function clear() {
		atlas.clear();
		view.clear();

		input.text = "Add Atlas";
		current = "";
	}


	function wrap(entry:String, max:Int = 20):String {
		if (entry.length > max) return "..."+entry.substr(entry.length-max);
		return entry;
	}

	
	override public function onResize() {
		if (view != null) view.onResize();
	}
}