package editor;

import ui.Label;
import tile.Image;
import Types;


class ImagePanel extends ui.Panel {
	var input:ui.FileInput;
	var activeLayer:Int = 0;


	public function new(?parent:h2d.Object) {
		super(parent);

		setBorder(Side.Bottom);
		borderStyle(Side.Inner);
		setSize(300, 80 + Style.borderSize);

		input = new ui.FileInput(this, 40, 0, onClick);
		input.text = "Add Image";
		input.setIcon(2, 2);

		visible = false;
	}


	function onClick(e:hxd.Event) {
		if (Editor.ME.missingTool()) {
			Editor.ME.showMessage("Use Select tool");
			return;
		}

		var nativeOptions:hl.UI.FileOptions = { }
		nativeOptions.title = "Open Image";
		nativeOptions.filters = [{name: "Image Files", exts: ["png", "jpeg", "jpg"]}];

		var file = hl.UI.loadFile(nativeOptions);

		if (file != null) {
			var name = haxe.io.Path.withoutDirectory(file);
			var data = sys.io.File.getBytes(file);

			var res = Editor.ME.project.resPath;
			var raw = file.substr(res.length).split("\\").join("/");
			var path = res == "" ? name : raw;

			var tile = hxd.res.Any.fromBytes(file, data).toImage().toTile();

			var image = new Image();
			image.bitmap.tile = tile;
				
			image.width = tile.width;
			image.height = tile.height;
	
			image.name = "empty";
			image.source = path;
			image.type = TileType.Image;

			Editor.ME.imageEvent(image);
		} 
	}
}