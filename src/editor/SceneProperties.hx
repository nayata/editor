package editor;

import ui.Label;
import ui.Panel;
import ui.TextInput;

import editor.Scene;

import Types;


class SceneProperties extends h2d.Object {
	var nameBox:ui.TextInput;

	var widthBox:ui.TextInput;
	var heightBox:ui.TextInput;

	var gridBox:ui.TextInput;

	public var scene(default, set):Scene;


	public function new(?parent:h2d.Object) {
		super(parent);

		var hinting = 4;

		var title = new h2d.Text(hxd.Res.robotoMedium.toFont(), this);
		title.text = "Scene Settings";
		title.textColor = Style.TEXT;
		title.textAlign = h2d.Text.Align.Left;
		title.smooth = true;

		title.x = 40;
		title.y = -hinting;

		var label = new Label(this, 40, 40 - hinting, "Name");

		nameBox = new TextInput(this, 40, 60, "Untitled", nameChange);
		nameBox.setSize(220, 40);

		label = new Label(this, 40, 140 - hinting, "Width");
		label = new Label(this, 160, 140 - hinting, "Height");

		widthBox = new TextInput(this, 40, 160, "280", sizeChange);
		widthBox.restricted = "1234567890";
		widthBox.minimum = 1;

		heightBox = new TextInput(this, 160, 160, "128", sizeChange);
		heightBox.restricted = "1234567890";
		heightBox.minimum = 1;

		label = new Label(this, 40, 220 - hinting, "Grid size");

		gridBox = new TextInput(this, 40, 240, "60", gridChange);
		gridBox.restricted = "1234567890";
		gridBox.minimum = 1;
	}


	function nameChange() {
		if (scene == null) return;

		scene.name = nameBox.text;
	}


	function sizeChange() {
		if (scene == null) return;

		var w = Std.parseInt(widthBox.text);
		var h = Std.parseInt(heightBox.text);

		scene.setSize(w, h);
		Editor.ME.sceneEvent();
	}


	function gridChange() {
		if (scene == null) return;

		var g = Std.parseInt(gridBox.text);

		scene.setGrid(g);
		Editor.ME.sceneEvent();
	}


	function set_scene(s) {
		scene = s;

		nameBox.text = scene.name;

		widthBox.text = Std.string(scene.width);
		heightBox.text = Std.string(scene.height);

		gridBox.text = Std.string(scene.gridSize);

		return s;
	}
}