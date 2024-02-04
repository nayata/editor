package editor;

import ui.Label;
import ui.TextInput;
import ui.NameInput;
import ui.DataInput;
import tile.Tile;

import Types;


class Properties extends h2d.Object {
	var xBox:ui.TextInput;
	var yBox:ui.TextInput;

	var widthBox:ui.TextInput;
	var heightBox:ui.TextInput;

	var nameBox:ui.NameInput;
	var typeBox:ui.Dropdown;

	var editMenu:ui.DropMenu;
	var nameLabel:ui.Label;

	var dataBox:ui.DataInput;
	var tagBox:ui.DataInput;

	var activeLayer:Int = 0;


	public function new(?parent:h2d.Object) {
		super(parent);

		var hinting = 4;

		var title = new h2d.Text(hxd.Res.robotoMedium.toFont(), this);
		title.text = "Properties";
		title.textColor = Style.TEXT;
		title.textAlign = h2d.Text.Align.Left;
		title.smooth = true;

		title.x = 40;
		title.y = -hinting;

		var label = new Label(this, 40, 40 - hinting, "X");
		label = new Label(this, 160, 40 - hinting, "Y");

		xBox = new TextInput(this, 40, 60, "280", xChange);
		xBox.restricted = "-1234567890";

		yBox = new TextInput(this, 160, 60, "128", yChange);
		yBox.restricted = "-1234567890";

		label = new Label(this, 40, 120 - hinting, "Width");
		label = new Label(this, 160, 120 - hinting, "Height");

		widthBox = new TextInput(this, 40, 140, "280", widthChange);
		widthBox.restricted = "1234567890";
		widthBox.minimum = 1;

		heightBox = new TextInput(this, 160, 140, "128", heightChange);
		heightBox.restricted = "1234567890";
		heightBox.minimum = 1;

		nameBox = new NameInput(this, 40, 220, "Name:", "empty", nameChange);
		nameBox.setSize(220, 40);

		nameLabel = new Label(this, 65, 290 - hinting, "empty");
		nameLabel.visible = false;

		var icon = new h2d.Bitmap(nameLabel);
		icon.x = -35;
		icon.y = -11;
		icon.tile = Editor.ME.atlas[3][4];

		dataBox = new DataInput(this, 40, 340, "Data:", "empty", dataChange);
		dataBox.setSize(220, 40);
		dataBox.setIcon(0, 4);
		dataBox.visible = false;

		tagBox = new DataInput(this, 40, 400, "Tag:", "0", tagChange);
		tagBox.restricted = "1234567890";
		tagBox.setSize(220, 40);
		tagBox.setIcon(1, 4);
		tagBox.visible = false;

		typeBox = new ui.Dropdown(this, 40, 280, typeChange);
		typeBox.addItems(["Static", "Dynamic", "Kinematic", "Sensor"]);
		typeBox.selectedItem = 0;

		editMenu = new ui.DropMenu(this, 300-80, -15, "", editEvent);
		editMenu.itemAlign(Side.Right);
		editMenu.itemSize(200, 40);
		editMenu.setSize(40, 40);

		editMenu.addItem("Tile custom color", CustomColor, false);
		editMenu.addItem("Tile default color", DefaultColor, false);
		editMenu.addDivider();
		editMenu.addItem("Add Data field", AddData, false);
		editMenu.addItem("Add Tag field", AddTag, false);
		editMenu.addDivider();
		editMenu.addItem("Add Path", AddPath, false);

		icon = new h2d.Bitmap(editMenu);
		icon.tile = Editor.ME.atlas[0][3];

		visible = false;
	}


	function xChange() {
		Editor.ME.tileEvent(posX, xBox.text);
	}
	function yChange() {
		Editor.ME.tileEvent(posY, yBox.text);
	}
	function widthChange() {
		Editor.ME.tileEvent(Width, widthBox.text);
	}
	function heightChange() {
		Editor.ME.tileEvent(Height, heightBox.text);
	}
	function nameChange() {
		Editor.ME.tileEvent(Name, nameBox.text);
	}
	function typeChange() {
		Editor.ME.tileTypeEvent(typeBox.selectedItem);
	}
	function dataChange() {
		Editor.ME.tileEvent(Data, dataBox.text);
	}
	function tagChange() {
		Editor.ME.tileEvent(Tag, tagBox.text);
	}


	function editEvent() {
		var event = editMenu.event;

		switch (event) {
			case CustomColor:
				Editor.ME.tileEvent(event);
			case DefaultColor:
				Editor.ME.tileEvent(event);
			case AddData:
				Editor.ME.tileEvent(Data, "empty");
				editMenu.itemText("Remove Data field");
				editMenu.itemType(RemoveData);
				dataBox.visible = true;
			case RemoveData:
				Editor.ME.tileEvent(Data, "");
				editMenu.itemText("Add Data field");
				editMenu.itemType(AddData);
				dataBox.visible = false;
				dataBox.text = "empty";
			case AddTag:
				Editor.ME.tileEvent(Tag, "0");
				editMenu.itemText("Remove Tag field");
				editMenu.itemType(RemoveTag);
				tagBox.visible = true;
			case RemoveTag:
				Editor.ME.tileEvent(Tag, "-1");
				editMenu.itemText("Add Tag field");
				editMenu.itemType(AddTag);
				tagBox.visible = false;
				tagBox.text = "0";
			case AddPath:
				Editor.ME.tileEvent(Path, "add");
				editMenu.itemText("Remove Path");
				editMenu.itemType(RemovePath);
			case RemovePath:
				Editor.ME.tileEvent(Path, "remove");
				editMenu.itemText("Add Path");
				editMenu.itemType(AddPath);
			default:
		}
		onResize();
	}


	public function update(tile:Tile) {
		xBox.text = Std.string(tile.position.x);
		yBox.text = Std.string(tile.position.y);

		widthBox.text = Std.string(tile.width);
		heightBox.text = Std.string(tile.height);

		nameBox.text = tile.name;
		typeBox.selectedItem = tile.type;

		nameLabel.text = wrap(tile.source, 30);

		dataBox.text = tile.data;
		tagBox.text = Std.string(tile.tag);

		dataBox.visible = tile.data == "" ? false : true;
		tagBox.visible = tile.tag == -1 ? false : true;

		if (tile.data != "") {
			editMenu.itemText(2, "Remove Data field");
			editMenu.itemType(2, RemoveData);
		}
		else {
			editMenu.itemText(2, "Add Data field");
			editMenu.itemType(2, AddData);
		}
		if (tile.tag != -1) {
			editMenu.itemText(3, "Remove Tag field");
			editMenu.itemType(3, RemoveTag);
		}
		else {
			editMenu.itemText(3, "Add Tag field");
			editMenu.itemType(3, AddTag);
		}
		if (tile.path != null && tile.path.length > 0) {
			editMenu.itemText(4, "Remove Path");
			editMenu.itemType(4, RemovePath);
		}
		else {
			editMenu.itemText(4, "Add Path");
			editMenu.itemType(4, AddPath);
		}

		onResize();

		visible = true;
	}


	public function setLayer(value:Int) {
		if (activeLayer == value) return;
		activeLayer = value;

		switch (activeLayer) {
			case LayerType.Collision:
				nameLabel.visible = false;
				editMenu.visible = true;
				nameBox.visible = true;
				typeBox.visible = true;
			case LayerType.Image:
				nameLabel.visible = true;
				editMenu.visible = false;
				nameBox.visible = true;
				typeBox.visible = false;
				dataBox.visible = false;
				tagBox.visible = false;
			case LayerType.Atlas:
				nameLabel.visible = true;
				editMenu.visible = false;
				nameBox.visible = true;
				typeBox.visible = false;
				dataBox.visible = false;
				tagBox.visible = false;
			case LayerType.Grid:
				nameLabel.visible = false;
			default:
		}
	}


	public function onResize() {
		var bound = 340;

		if (dataBox.visible) {
			dataBox.y = bound;
			bound += 60;
		}
		if (tagBox.visible) {
			tagBox.y = bound;
			bound += 60;
		}
	}


	function wrap(entry:String, max:Int = 20):String {
		if (entry.length > max) return "..."+entry.substr(entry.length-max);
		return entry;
	}
}