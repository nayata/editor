package ui;


class FileInput extends h2d.Object {
	var input:h2d.Interactive;
	var back:h2d.ScaleGrid;
	var face:h2d.Bitmap;
	var label:h2d.Text;
	
	var width:Float = 40;
	var height:Float = 40;

	public var text(get, set):String;


	public function new(?parent:h2d.Object, xpos:Float = 0, ypos:Float =  0, ?event:hxd.Event->Void) {
		super(parent);

		x = xpos;
		y = ypos;

		back = new h2d.ScaleGrid(Editor.ME.atlas[0][5], 10, 10, this);

		face = new h2d.Bitmap(this);
		face.tile = Editor.ME.atlas[2][2];

		input = new h2d.Interactive(0, 0, this);
		if (event != null) input.onClick = event;

		label = new h2d.Text(hxd.Res.robotoRegular.toFont(), this);
		label.textColor = Style.INPUT;
		label.textAlign = h2d.Text.Align.Center;
		label.smooth = true;

		setSize(220, 40);
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		back.width = width;
		back.height = height;

		input.width = width;
		input.height = height;

		label.x = width*0.5 + 10;
		label.y = height*0.5 - label.textHeight*0.5;

		face.x = label.x - label.textWidth*0.5 - 40;
		face.x = Math.max(face.x, 0);
	}

	
	public function setIcon(tx:Int, ty:Int) {
		face.tile = Editor.ME.atlas[tx][ty];
	}


	public function setBackground(tx:Int, ty:Int) {
		back.tile = Editor.ME.atlas[tx][ty];
	}


	function get_text():String {
		return label.text;
	}

	function set_text(t:String) {
		label.text = t;
		setSize(220, 40);
		return t;
	}
}