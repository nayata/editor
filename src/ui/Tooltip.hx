package ui;


class Tooltip extends h2d.Object {
	var back:h2d.Graphics;
	var label:h2d.Text;

	public var text(default, set):String;


	public function new(?parent:h2d.Object) {
		super(parent);

		back = new h2d.Graphics(this);

		label = new h2d.Text(hxd.Res.robotoRegular.toFont(), this);
		label.textColor = Style.BORDER;
		label.textAlign = h2d.Text.Align.Left;
		label.smooth = true;
	}


	function set_text(t:String) {
		label.text = t;

		var width = label.textWidth + 12;
		label.x = -label.textWidth*0.5;
		label.y = 10 - label.textHeight*0.5;

		back.clear();
		back.beginFill(Style.BUTTON);
		back.drawRect(-width*0.5, 0, width, 20);
		back.endFill();

		return t;
	}
}