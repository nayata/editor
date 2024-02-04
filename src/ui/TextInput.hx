package ui;


class TextInput extends h2d.Object {
	var width:Float = 10;
	var height:Float = 10;

	var back:h2d.ScaleGrid;
	var face:h2d.ScaleGrid;
	var input:h2d.TextInput;

	var handler:Void->Void;
	var value:String;

	public var minimum:Float = 0;
	public var restricted:String = "";
	public var text(get, set):String;


	public function new(?parent:h2d.Object, xpos:Float = 0, ypos:Float =  0, text:String = "", event:Void->Void = null) {
		super(parent);

		x = xpos;
		y = ypos;

		if (event != null) handler = event;
		value = text;

		back = new h2d.ScaleGrid(Editor.ME.atlas[0][5], 10, 10, this);
		face = new h2d.ScaleGrid(Editor.ME.atlas[1][5], 10, 10, this);
		face.visible = false;

		input = new h2d.TextInput(hxd.Res.robotoRegular.toFont(), this);
		input.inputWidth = 74;
		input.text = text;

		input.textColor = Style.INPUT;
		input.textAlign = h2d.Text.Align.Left;
		input.smooth = true;

		input.onChange = onChange;
		input.onFocus = function(_) {
			value = input.text;
			face.visible = true;
		}
		input.onFocusLost = function(_) {
			face.visible = false;
			checkValue();
		}

		setSize(100, 40);
	}


	function onChange() {
		var valid = validateValue();

		if (valid && input.text != "-") {
			value = minimumValue(input.text);
			input.text = value;
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
		var minus = StringTools.contains(restricted, "-");

		for (index in 0...length) {
			var char = string.charAt(index);
			var valid = StringTools.contains(restricted, char);
			
			if (minus && char == "-" && index > 0) return false;
			if (!valid) return false;
		}

		return true;
	}


	function checkValue() {
		if (input.text == "-0") input.text = "0";
		if (input.text == "-") {
			input.text = value;
			if (handler != null) handler();
		}
	}


	function minimumValue(string:String):String {
		if (minimum == 0) return string;

		var digit = Std.parseFloat(string);
		if (digit < minimum) string = Std.string(minimum);

		return string;
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

		input.x = 12;
		input.y = height*0.5 - input.textHeight*0.5;

		input.inputWidth = Std.int(width-24);
	}
}