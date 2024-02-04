package tile;


class Image extends Tile {

	
	public function new(?parent:h2d.Object) {
		super(parent);

		bitmap = new h2d.Bitmap(this);
	}


	override public function redraw() {
		bitmap.width = width;
		bitmap.height = height;
	}


	override public function setLabel() {
	}
}