package ui;

import Types;


class Tab extends ui.Panel {
	var interactive:h2d.Interactive;
	var label:h2d.Text;

	public var view:h2d.Object;
	public var index:Int = 0;

	public var text(never, set):String;
	public var active(never, set):Bool;



	public function new(?parent:h2d.Object, handler:hxd.Event->Void = null) {
		super(parent);

		interactive = new h2d.Interactive(0, 0, graphics); 

		if (handler != null) interactive.onClick = handler;

		label = new h2d.Text(hxd.Res.robotoRegular.toFont(), graphics);
		label.text = "text";
		label.textColor = Style.TEXT;
		label.textAlign = h2d.Text.Align.Center;
		label.smooth = true;


		view = new h2d.Object(this);
	}


	override public function setSize(w:Float, h:Float) {
		super.setSize(w, h);

		graphics.x = width * index;

		interactive.width = width;
		interactive.height = height;

		label.x = width*0.5;
		label.y = height*0.5 - label.textHeight*0.5;

		view.y = height;
	}


	function set_active(value:Bool):Bool {
		view.visible = value;

		graphics.clear();
		graphics.beginFill(value ? Style.PANEL : Style.INACTIVE);
		graphics.drawRect(0, 0, width, height);
		graphics.endFill();

		if (!value) drawBorder();

		return value;
	}


	function set_text(value:String):String {
		return label.text = value;
	}
}