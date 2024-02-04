package ui;

import Types;


class Button extends h2d.Object {
	var input:h2d.Interactive;
	var label:h2d.Text;
	
	var width:Float = 40;
	var height:Float = 40;

	var handler:Action->Void;

	public var action:Action = None;



	public function new(?parent:h2d.Object, xpos:Float = 0, ypos:Float =  0, text:String = "", event:Action->Void = null) {
		super(parent);

		x = xpos;
		y = ypos;

		input = new h2d.Interactive(0, 0, this);
		if (event != null) handler = event;

		input.onClick = onClick;
		input.onOver = onOver;
		input.onOut = onOut;

		label = new h2d.Text(hxd.Res.robotoRegular.toFont(), this);
		label.text = text;
		label.textColor = Style.TEXT;
		label.textAlign = h2d.Text.Align.Left;
		label.smooth = true;

		label.alpha = 0.75;

		setSize(60, 40);
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		input.width = width;
		input.height = height;

		label.x = width*0.5-label.textWidth*0.5;
		label.y = height*0.5 - label.textHeight*0.5;
	}


	function onClick(e:hxd.Event) {
		if (handler != null) handler(action);
	}


	function onOver(e:hxd.Event) {
		label.alpha = 1;
	}


	function onOut(e:hxd.Event) {
		label.alpha = 0.75;
	}
}