package ui;


class Message extends heaps.Component {
	var label:h2d.Text;
	var timer:Int = 0;

	public var text(default, set):String;


	public function new(?parent:h2d.Object) {
		super(parent);


		label = new h2d.Text(hxd.Res.robotoRegular.toFont(), this);
		label.textColor = 0x777777;
		label.textAlign = h2d.Text.Align.Center;
		label.smooth = true;
	}


	override public function update() {
		if (timer > 0) {
			timer--;
			if (timer < 10) alpha -= 0.1;
			if (timer == 0) visible = false;
		}
	}


	function set_text(t:String) {
		label.text = t;

		alpha = 1;
		visible = true;
		timer = 80;

		return t;
	}
}