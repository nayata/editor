package ui;

import Types;


class LayerItem extends h2d.Object {
	var back:h2d.Graphics;
	var face:h2d.Graphics;
	var icon:h2d.Bitmap;
	var select:h2d.Bitmap;

	public var input:h2d.TextInput;
	
	var width:Float = 300;
	var height:Float = 40;

	public var type(default, set):Int = 0;
	public var selected(default, set):Bool = false;
	public var view(default, set):Bool = true;
	public var text(get, set):String;


	public function new(?parent:h2d.Object, ?pos:Float = 0, text:String = "") {
		super(parent);

		y = pos;

		back = new h2d.Graphics(this);
		back.visible = false;

		icon = new h2d.Bitmap(this);
		icon.x = 20;

		face = new h2d.Graphics(this);
		face.visible = false;
		face.beginFill(Style.TOOL);
		face.drawRect(0, 0, 4, 40);
		face.endFill();

		select = new h2d.Bitmap(this);
		select.tile = Editor.ME.atlas[2][3];
		select.x = 300-60;

		input = new h2d.TextInput(hxd.Res.robotoMedium.toFont(), this);
		input.inputWidth = 180;
		input.text = text;
		input.textColor = Style.TEXT;
		input.textAlign = h2d.Text.Align.Left;
		input.smooth = true;

		setSize(300, 40);
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		back.clear();
		back.beginFill(Style.HIGHLIGHT);
		back.drawRect(0, 0, width, height);
		back.endFill();

		input.x = 60;
		input.y = height*0.5 - input.textHeight*0.5;
	}


	public function onOver(value:Bool) {
		back.visible = value;
	}


	function onOut(e:hxd.Event) {
		back.visible = false;
	}


	public function togleView() {
		view = !view;
	}


	function set_type(value:Int):Int {
		type = value;

		icon.tile = Editor.ME.atlas[value][2];

		return value;
	}


	function set_view(value:Bool):Bool {
		view = value;

		var state = view ? 2 : 3;
		select.tile = Editor.ME.atlas[state][3];

		return value;
	}


	function set_selected(value:Bool):Bool {
		selected = value;
		face.visible = value;
		return value;
	}


	function get_text():String {
		return input.text;
	}


	function set_text(t:String) {
		input.text = t;
		return t;
	}
}


class Checkbox extends h2d.Object {
	var input:h2d.Interactive;
	var back:h2d.Graphics;
	var face:h2d.Bitmap;

	public var selected(default, set):Bool;

	

	public function new(?parent:h2d.Object, xpos:Float = 0, ypos:Float =  0) {
		super(parent);

		x = xpos;
		y = ypos;

		input = new h2d.Interactive(40, 40, this); 
		input.cursor = Default;
		input.visible = false;

		input.onClick = onClick;
		input.onOver = onOver;
		input.onOut = onOut;

		back = new h2d.Graphics(this);
		back.visible = false;

		face = new h2d.Bitmap(this);
		face.tile = Editor.ME.atlas[2][3];

		selected = true;
	}

	function set_selected(value:Bool):Bool {
		selected = value;

		var state = selected ? 2 : 3;

		face.tile = Editor.ME.atlas[state][3];

		return value;
	}

	function onClick(e:hxd.Event) {
		selected = !selected;
	}


	function onOver(e:hxd.Event) {
		face.alpha = 0.75;
	}


	function onOut(e:hxd.Event) {
		face.alpha = 1;
	}

}