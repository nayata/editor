package ui;

import Types;


class Tool extends h2d.Object {
	var input:h2d.Interactive;
	var back:h2d.Graphics;
	var face:h2d.Bitmap;
	
	var width:Float = 40;
	var height:Float = 40;

	var handler:Action->Void;

	public var toggle:Bool = false;
	public var selected(default, set):Bool;
	public var active(default, set):Bool;

	public var action:Action = None;
	public var tooltip:String = "";

	

	public function new(?parent:h2d.Object, xpos:Float = 0, ypos:Float =  0, event:Action->Void = null) {
		super(parent);

		x = xpos;
		y = ypos;

		input = new h2d.Interactive(0, 0, this); 
		if (event != null) handler = event;
		input.cursor = Default;

		input.onClick = onClick;
		input.onOver = onOver;
		input.onOut = onOut;

		back = new h2d.Graphics(this);
		back.visible = false;

		face = new h2d.Bitmap(this);

		setSize(40, 40);
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		input.width = width;
		input.height = height;

		face.x = width*0.5 - 20;
		face.y = height*0.5 - 20;
	}

	
	public function setIcon(tx:Int, ty:Int) {
		face.tile = Editor.ME.atlas[tx][ty];
	}


	function set_selected(value:Bool):Bool {
		if (!toggle) return false;
		
		selected = value;
		back.visible = selected;

		//face.alpha = 0.75;
		//if (selected) face.alpha = 1;

		back.clear();
		back.beginFill(Style.TOOL);
		back.drawRect(0, 0, width, height);
		back.endFill();

		return value;
	}


	function set_active(value:Bool):Bool {
		active = value;
		input.visible = active;

		face.alpha = active ? 1 : 0.3;

		return value;
	}


	function onClick(e:hxd.Event) {
		if (handler != null) handler(action);
	}


	function onOver(e:hxd.Event) {
		if (tooltip != "") Editor.ME.setTooltip(true, tooltip);

		if (selected) return;
		//face.alpha = 0.75;
	}


	function onOut(e:hxd.Event) {
		Editor.ME.setTooltip(false);

		if (selected) return;
		//face.alpha = 1;
	}

}