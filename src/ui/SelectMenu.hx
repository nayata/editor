package ui;

import Types;


class SelectMenu extends h2d.Object {
	var input:h2d.Interactive;
	var back:h2d.ScaleGrid;
	var face:h2d.Bitmap;

	var panel:h2d.Object;
	var text:String = "empty";
	var label:Item;

	var items:Array<Item> = [];
	var highlightedItem:Int = -1;
	var handler:Void->Void;
	
	var width:Float = 40;
	var height:Float = 40;

	public var selectedItem(default, set):Int = -1;


	public function new(?parent:h2d.Object, xpos:Float = 0, ypos:Float =  0, ?text:String = "", ?event:Void->Void = null) {
		super(parent);

		x = xpos;
		y = ypos;

		input = new h2d.Interactive(0, 0, this);
		if (event != null) handler = event;

		input.onClick = onClick;
		input.onMove = onMove;
		input.onOver = onOver;
		input.onOut = onOut;

		back = new h2d.ScaleGrid(Editor.ME.atlas[0][5], 10, 10, this);
		face = new h2d.Bitmap(this);
		face.tile = Editor.ME.atlas[1][3];
		face.x = 220-40;

		panel = new h2d.Object(this);
		panel.visible = false;
		panel.y = 10;

		label = new Item(this, 0, text);
		label.setSize(220, 40);

		setSize(220, 40);
	}


	public function setLabel(value:String) {
		label.text = value;
		text = value;
	}


	public function addItem(value:String) {
		var item = new Item(panel, 40 + 40*items.length, value);
		items.push(item);
	}


	public function addItems(value:Array<String>) {
		for (index in 0...value.length) {
			var item = new Item(panel, 40*(index+1), value[index]);
			items.push(item);
		}
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		input.width = width;
		input.height = height;

		back.width = width;
		back.height = height;
	}


	function onClick(e:hxd.Event) {
		if (highlightedItem == -1) {
			trace("Type: ");
			if (handler != null) handler();

			panel.visible = false;
			setSize(220, 40);
		}

		if (!panel.visible) return;

		if (highlightedItem != -1) {
			selectedItem = highlightedItem;

			if (handler != null) handler();

			panel.visible = false;
			setSize(220, 40);
		}
	}


	function onMove(e:hxd.Event) {
		if (!panel.visible) return;

		var clickPos = new h2d.col.Point(e.relX, e.relY);
		highlightedItem = -1;

		for (i in 0...items.length) {
			var item = items[i];

			var yMin = item.y;
			var yMax = item.y + 40;

			item.onOver(false);

			if (clickPos.y >= yMin && clickPos.y < yMax) {
				highlightedItem = i;
				item.onOver(true);
			}
		}
	}


	function onOver(e:hxd.Event) {
		if (items.length == 0) return;

		//label.text = text;

		panel.visible = true;
		setSize(220, (items.length + 2)*40);
	}


	function onOut(e:hxd.Event) {
		if (items.length == 0) return;

		//label.text = items[selectedItem].text;

		highlightedItem = -1;

		for (item in items) {
			item.onOver(false);
		}

		panel.visible = false;
		setSize(220, 40);
	}


	function set_selectedItem(s) {
		if( s < 0 )
			s = -1;
		else if( s >= items.length )
			s = items.length - 1;

		var item = items[s];
		if (item != null) label.text = item.text;

		return selectedItem = s;
	}
}