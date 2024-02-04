package ui;


class Warning extends heaps.Component {
	var input:h2d.Interactive;
	var back:h2d.Graphics;
	var face:h2d.Bitmap;
	var label:h2d.Text;
	
	public var width:Float = 40;
	public var height:Float = 40;

	public var text(default, set):String;


	public function new(?parent:h2d.Object) {
		super(parent);

		input = new h2d.Interactive(0, 0, this); 
		input.onClick = onClick;

		back = new h2d.Graphics(this);
		face = new h2d.Bitmap(Editor.ME.atlas[4][1], this);
		
		label = new h2d.Text(hxd.Res.robotoRegular.toFont(), this);
		label.textColor = Style.INPUT;
		label.textAlign = h2d.Text.Align.Center;
		label.smooth = true;

		setSize(480, 60);

		visible = false;
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		input.width = width;
		input.height = height;

		back.clear();
		back.beginFill(Style.TOOL);
		back.drawRect(0, 0, width, height);
		back.endFill();

		face.x = width-50;
		face.y = height*0.5 - 20;
	}


	function onClick(e:hxd.Event) {
		visible = false;
	}

	function set_text(t:String) {
		label.text = t;

		label.x = width*0.5;
		label.y = height*0.5 - label.textHeight*0.5;

		visible = true;

		return t;
	}


	public function onResize() {
		x = (Editor.ME.WIDTH - 300)*0.5-width*0.5;
		y = 80;
	}
}