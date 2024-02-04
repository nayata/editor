package ui;


class Item extends h2d.Object {
	var back:h2d.Graphics;
	var label:h2d.Text;
	
	var width:Float = 220;
	var height:Float = 40;

	public var text(get, set):String;


	public function new(?parent:h2d.Object, pos:Float = 0, text:String = "") {
		super(parent);

		y = pos;

		back = new h2d.Graphics(this);
		back.visible = false;

		label = new h2d.Text(hxd.Res.robotoRegular.toFont(), this);
		label.text = text;
		label.textColor = Style.INPUT;
		label.textAlign = h2d.Text.Align.Left;
		label.smooth = true;

		setSize(220, 40);
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		back.clear();
		back.beginFill(Style.HIGHLIGHT);
		back.drawRect(0, 0, width, height);
		back.endFill();

		label.x = 16;
		label.y = height*0.5 - label.textHeight*0.5;
	}


	public function onOver(value:Bool) {
		back.visible = value;
	}

	function get_text():String {
		return label.text;
	}

	function set_text(t:String) {
		label.text = t;
		return t;
	}
}