class GridExample extends hxd.App {
	var grid:Map<Int, Bool> = new Map();
	var gridWidth:Int;
	var gridSize:Int;
	
	var label:h2d.Text;

	inline function setGridCell(cx, cy, value) grid.set(gridCell(cx, cy), value);
	inline function gridCell(cx, cy) return cx + cy*gridWidth;
	inline function snap(value:Float, step:Int = 10) return Math.round(value / step);
	

    static function main() {
		new GridExample();
    }


	override function init() {
		engine.backgroundColor = 0x2e2b44;
		s2d.scaleMode = LetterBox(960, 600, false, Center, Center);
		hxd.Res.initLocal();


		var project = new Project();
		var scene = project.load("grid.json");

		var obj = project.debugRender();
		s2d.addChild(obj);

		var cWid:Int = Math.round(scene.width/scene.gridSize);
		var cHei:Int = Math.round(scene.height/scene.gridSize);

		gridWidth = cWid;
		gridSize = scene.gridSize;

		for (cy in 0...cHei) {
			for(cx in 0...cWid) {
				setGridCell(cx,cy, true);
			}
		}

		var layer = project.defaultLayer();
		for (cell in layer.grid) {
			setGridCell(cell.cellX, cell.cellY, false);
		}

		label = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		label.textColor = 0xffffff;
		label.x = label.y = 64;
	}


	override function update(dt:Float) {
		super.update(dt);

		var cx = snap(s2d.mouseX-gridSize*0.5, gridSize);
		var cy = snap(s2d.mouseY-gridSize*0.5, gridSize);

		label.text = "cell x: " + cx + "\ncell y: " + cy + "\nwalkable: " + grid.get(gridCell(cx, cy));
	}
 }