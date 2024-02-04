package ui;

import Types;


class DropMenu extends h2d.Object {
	var input:h2d.Interactive;
	var back:h2d.Graphics;
	var face:h2d.Graphics;

	var panel:h2d.Object;
	var label:h2d.Text;

	var items:Array<MenuItem> = [];
	var dividers:Int = 0;

	var highlightedItem:Int = -1;
	var onEvent:Void->Void;
	
	var width:Float = 40;
	var height:Float = 40;

	var itemWidth:Float = 40;
	var itemHeight:Float = 40;
	var align:Side = Left;

	public var selectedItem(default, set):Int = -1;
	public var event:MenuEvent = None;


	public function new(?parent:h2d.Object, xpos:Float = 0, ypos:Float =  0, ?text:String = "", ?handler:Void->Void = null) {
		super(parent);

		x = xpos;
		y = ypos;

		input = new h2d.Interactive(0, 0, this);
		if (handler != null) onEvent = handler;
		input.cursor = Default;

		input.onClick = onClick;
		input.onMove = onMove;
		input.onOver = onOver;
		input.onOut = onOut;

		back = new h2d.Graphics(this);
		face = new h2d.Graphics(this);
		back.visible = false;
		face.visible = false;

		panel = new h2d.Object(this);
		panel.visible = false;

		label = new h2d.Text(hxd.Res.robotoRegular.toFont(), this);
		label.text = text;
		label.textColor = Style.TEXT;
		label.textAlign = h2d.Text.Align.Left;
		label.smooth = true;
		label.alpha = 0.75;

		setSize(60, 40);
	}


	public function addItem(value:String, ?type:MenuEvent = None, ?closable:Bool = true) {
		var item = new MenuItem(panel, type, dividers+itemHeight*items.length, value, closable);
		item.setSize(itemWidth, itemHeight);

		items.push(item);
	}


	public function addDivider() {
		var item = new MenuItem(panel, None, dividers+itemHeight*items.length);
		item.setDivider(itemWidth, 10);
		dividers += 10;
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		input.width = width;
		input.height = height;

		back.clear();
		back.beginFill(Style.menuBack);
		back.drawRect(0, 0, width, height);
		back.endFill();

		label.x = 16;
		label.y = height*0.5 - label.textHeight*0.5;

		itemSize(itemWidth, itemHeight);
	}


	public function itemAlign(position:Side) {
		align = position;
	}


	public function itemSize(w:Float, h:Float) {
		itemWidth = w;
		itemHeight = h;

		switch (align) {
			case Left:
				panel.x = 0;
				face.x = 0;
			case Right:
				panel.x = width-itemWidth;
				face.x = width-itemWidth;
			default:
		}
	}


	public function itemText(?item:Int, text:String) {
		var selected = item != null ? item : selectedItem;
		items[selected].text = text;
	}


	public function itemType(?item:Int, type:MenuEvent) {
		var selected = item != null ? item : selectedItem;
		items[selected].event = type;
	}


	function onClick(e:hxd.Event) {
		if (!panel.visible) return;

		if (highlightedItem != -1) {
			selectedItem = highlightedItem;

			event = items[selectedItem].event;

			if (onEvent != null) onEvent();

			if (items[selectedItem].closable) close();
		}
	}


	function onMove(e:hxd.Event) {
		if (!panel.visible) return;

		var clickPos = new h2d.col.Point(e.relX, e.relY-height);
		highlightedItem = -1;

		for (i in 0...items.length) {
			var item = items[i];

			var yMin = item.y;
			var yMax = item.y + itemHeight;

			item.onOver(false);

			if (clickPos.y >= yMin && clickPos.y < yMax) {
				highlightedItem = i;
				item.onOver(true);
			}
		}
	}


	function onOver(e:hxd.Event) {
		panel.visible = true;

		input.width = itemWidth;
		input.height = dividers+items.length*itemHeight+itemHeight;
		input.x = panel.x;
		input.focus();

		face.clear();
		face.beginFill(Style.menuFill);
		face.drawRect(0, 0, input.width, input.height-itemHeight);
		face.endFill();

		back.visible = true;
		face.visible = true;

		panel.y = height;
		face.y = height;

		label.alpha = 1;
	}


	function onOut(e:hxd.Event) {
		close();
	}


	function close() {
		input.width = width;
		input.height = height;
		input.x = 0;

		panel.visible = false;
		back.visible = false;
		face.visible = false;

		label.alpha = 0.75;

		highlightedItem = -1;

		for (item in items) {
			item.onOver(false);
		}
	}


	function set_selectedItem(s) {
		if( s < 0 )
			s = -1;
		else if( s >= items.length )
			s = items.length - 1;

		return selectedItem = s;
	}
}


class MenuItem extends h2d.Object {
	var back:h2d.Graphics;
	var label:h2d.Text;
	
	var width:Float = 220;
	var height:Float = 40;

	public var text(get, set):String;
	public var event:MenuEvent = None;
	public var closable:Bool = true;


	public function new(?parent:h2d.Object, type:MenuEvent = None, pos:Float = 0, text:String = "", close:Bool = true) {
		super(parent);

		y = pos;
		event = type;
		closable = close;

		back = new h2d.Graphics(this);
		back.visible = false;

		label = new h2d.Text(hxd.Res.robotoRegular.toFont(), this);
		label.text = text;
		label.textColor = Style.menuText;
		label.textAlign = h2d.Text.Align.Left;
		label.smooth = true;

		setSize(220, 40);
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		back.clear();
		back.beginFill(Style.menuOver);
		back.drawRect(0, 0, width, height);
		back.endFill();

		label.x = 24;
		label.y = height*0.5 - label.textHeight*0.5;
	}

	public function setDivider(w:Float, h:Float) {
		width = w;
		height = h;

		back.clear();
		back.beginFill(Style.menuOver);
		back.drawRect(0, 0, width, height);
		back.endFill();

		var divider = new h2d.Graphics(this);

		divider.beginFill(Style.menuDivider);
		divider.drawRect(4, 0, width-8, 2);
		divider.endFill();

		divider.y = height*0.5 - 1;
	}


	public function onOver(value:Bool) {
		back.visible = value;
		label.textColor = value ? 0xffffff : Style.menuText;
	}


	function get_text():String {
		return label.text;
	}


	function set_text(t:String) {
		label.text = t;
		return t;
	}
}