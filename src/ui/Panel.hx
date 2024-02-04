package ui;

import Types;


class Panel extends h2d.Object {
	var graphics:h2d.Graphics;
	var borders:Array<Side> = [];
	var style:Side = Outer;
	
	public var width:Float = 10;
	public var height:Float = 10;



	public function new(?parent:h2d.Object) {
		super(parent);
		graphics = new h2d.Graphics(this);
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		graphics.clear();
		graphics.beginFill(Style.PANEL);
		graphics.drawRect(0, 0, width, height);
		graphics.endFill();

		drawBorder();
		onResize();
	}


	function drawBorder() {
		var offset = style == Inner ? 1 : 0;

		for (border in borders) {
			switch (border) {
				case Top:
					offset = style == Outer ? 1 : 0;
					graphics.beginFill(Style.BORDER);
					graphics.drawRect(0, -Style.borderSize * offset, width, Style.borderSize);
					graphics.endFill();
				case Right:
					graphics.beginFill(Style.BORDER);
					graphics.drawRect(width-Style.borderSize * offset, 0, Style.borderSize, height);
					graphics.endFill();
				case Bottom:
					graphics.beginFill(Style.BORDER);
					graphics.drawRect(0, height-Style.borderSize * offset, width, Style.borderSize);
					graphics.endFill();
				case Left:
					offset = style == Outer ? 1 : 0;
					graphics.beginFill(Style.BORDER);
					graphics.drawRect(-Style.borderSize * offset, 0, Style.borderSize, height);
					graphics.endFill();
				default:
			}
		}
	}


	public function borderStyle(position:Side) {
		style = position;
	}


	public function setBorder(position:Side) {
		borders.push(position);
	}


	public function onResize() {
	}
}