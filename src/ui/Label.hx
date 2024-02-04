package ui;


class Label extends h2d.Object {
	var label:h2d.Text;
	public var text(default, set):String;

	public function new(?parent:h2d.Object, xpos:Float = 0, ypos:Float =  0, text:String = "") {
		super(parent);

		x = xpos;
		y = ypos;

		label = new h2d.Text(hxd.Res.robotoRegular.toFont(), this);
		label.text = text;
		label.textColor = Style.LABEL;
		label.textAlign = h2d.Text.Align.Left;
		label.smooth = true;
	}


	function set_text(t:String) {
		label.text = t;
		return t;
	}
}