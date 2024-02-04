package ui;


class NameInput extends h2d.Object {
	var width:Float = 10;
	var height:Float = 10;

	var back:h2d.ScaleGrid;
	var face:h2d.ScaleGrid;

	var label:h2d.Text;
	var input:h2d.TextInput;
	var handler:Void->Void;

	public var text(get, set):String;


	public function new(?parent:h2d.Object, xpos:Float = 0, ypos:Float =  0, name:String = "", text:String = "", event:Void->Void = null) {
		super(parent);

		x = xpos;
		y = ypos;

		if (event != null) handler = event;

		back = new h2d.ScaleGrid(Editor.ME.atlas[0][5], 10, 10, this);
		face = new h2d.ScaleGrid(Editor.ME.atlas[1][5], 10, 10, this);
		face.visible = false;

		label = new h2d.Text(hxd.Res.robotoRegular.toFont(), this);
		label.text = name;
		label.textColor = Style.INPUT;
		label.textAlign = h2d.Text.Align.Left;
		label.smooth = true;

		input = new h2d.TextInput(hxd.Res.robotoRegular.toFont(), this);
		input.inputWidth = 74;
		input.text = text;

		input.textColor = Style.TEXT;
		input.textAlign = h2d.Text.Align.Left;
		input.smooth = true;

		input.onChange = onChange;
		input.onFocus = function(_) {
			face.visible = true;
		}
		input.onFocusLost = function(_) {
			face.visible = false;
		}

		setSize(100, 40);
	}


	function onChange() {
		if (handler != null) handler();
	}


	function get_text():String {
		return input.text;
	}


	function set_text(t:String) {
		input.text = t;
		return t;
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		back.width = width;
		back.height = height;

		face.width = width;
		face.height = height;

		label.x = 16;
		label.y = height*0.5 - label.textHeight*0.5;

		input.x = label.textWidth + 20;
		input.y = height*0.5 - input.textHeight*0.5;

		input.inputWidth = Std.int(width - label.textWidth - 34);
	}
}