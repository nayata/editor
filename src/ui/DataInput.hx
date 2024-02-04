package ui;


class DataInput extends h2d.Object {
	var width:Float = 10;
	var height:Float = 10;

	var back:h2d.ScaleGrid;
	var face:h2d.ScaleGrid;
	var icon:h2d.Bitmap;

	var label:h2d.Text;
	var input:h2d.TextInput;
	var handler:Void->Void;
	var value:String;

	public var restricted:String = "";
	public var text(get, set):String;


	public function new(?parent:h2d.Object, xpos:Float = 0, ypos:Float =  0, name:String = "", text:String = "", event:Void->Void = null) {
		super(parent);

		x = xpos;
		y = ypos;

		if (event != null) handler = event;
		value = text;

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
			value = input.text;
			face.visible = true;
		}
		input.onFocusLost = function(_) {
			face.visible = false;
		}

		icon = new h2d.Bitmap(this);

		setSize(100, 40);
	}


	function onChange() {
		var valid = validateValue();

		if (valid) {
			value = input.text;
			if (handler != null) handler();
		}
		else {
			input.text = value;
		}
	}


	function validateValue():Bool {
		if (restricted == "") return true;
		if (input.text == "") return false;

		var string = input.text;
		var length = string.length;

		for (index in 0...length) {
			var char = string.charAt(index);
			var valid = StringTools.contains(restricted, char);
			if (!valid) return false;
		}

		return true;
	}


	function get_text():String {
		return input.text;
	}


	function set_text(t:String) {
		input.text = t;
		return t;
	}


	public function setIcon(tx:Int, ty:Int) {
		icon.tile = Editor.ME.atlas[tx][ty];
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		back.width = width;
		back.height = height;

		face.width = width;
		face.height = height;

		label.x = 40;
		label.y = height*0.5 - label.textHeight*0.5;

		input.x = label.x + label.textWidth + 5;
		input.y = height*0.5 - input.textHeight*0.5;

		input.inputWidth = Std.int(width - label.textWidth - 64);
	}
}