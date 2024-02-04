package ui;

import Types;


class Highlight extends h2d.Graphics {
	var state:State = Lock;

	var width:Float = 10;
	var height:Float = 10;

	public var scaling:Float = 1;

	
	public function setState(value:State, w:Float, h:Float) {
		state = value;

		width = w;
		height = h;

		visible = true;

		update();
	}


	public function update() {
		if (!visible) return;
		
		switch (state) {
			case Path:
				clear();
				lineStyle(4 / scaling, 0xFFD900, 1.0);
				drawRect(-width*0.5, -height*0.5, width, height);
			case Move:
				clear();
				lineStyle(1 / scaling, 0xFFFFFF, 0.5);
				beginFill(0xFFFFFF, 0.25);
				drawRect(-width*0.5+0.5, -height*0.5+0.5, width-1, height-1);
				endFill();
			default:
		}
	}
}