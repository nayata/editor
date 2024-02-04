package editor;

import h2d.col.Point;
import tile.Tile;


class Scene extends h2d.Object {
	public var width:Int = 960;
	public var height:Int = 540;
	public var gridSize:Int = 10;

	public var pivot = new Point();
	public var scaling:Float = 1;

	var back:h2d.Graphics;
	var grid:h2d.Graphics;

	public var layer:Layer;
	public var layers:Array<Layer> = [];
	var canvas:Canvas;
	

	public function new(?parent:h2d.Object) {
		super(parent);

		name = "New Scene";

		back = new h2d.Graphics(this);
		grid = new h2d.Graphics(this);

		canvas = new Canvas(this);
		
		setSize(width, height);
	}
    

	public function addDefaultLayer() {
		var item = new Layer(canvas);
		item.name = "Collision Layer";
		item.type = 0;
		layers.push(item);
		
		layer = layers[0];
	}


	public function addLayer(type:Int = 0, text:String = "", ?position:Int = -1):Layer {
		var item = new Layer();
		item.name = text;
		item.type = type;

		canvas.addChildAt(item, position);
		layers.insert(position, item);
		
		layer = layers[layers.length-1];

		return item;
	}


	public function setLayer(type:Int = 0, text:String = ""):Layer {
		var item = new Layer();
		item.name = text;
		item.type = type;

		canvas.addChild(item);
		layers.push(item);
		
		layer = layers[layers.length-1];

		return item;
	}


	public function removeLayer(index:Int) {
		var item = layers[index];

		layers.remove(item);
		item.remove();
		
		layer = layers[layers.length-1];
	}


	public function orderLayer(selected:Int, order:Int) {
		if (selected <= 0 && order == -1) return;
		if (selected == layers.length-1 && order == 1) return;

		var idx0 = selected;
		var idx1 = selected+order;
		var tmp = layers[idx0];

		layers[idx0] = layers[idx1];
		layers[idx1] = tmp;

		canvas.orderLayer(selected, selected+order);
	}


	public function orderItem(selected:Int, order:Int, bring:Bool):Tile {
		if (selected <= 0 && order == -1) return layer.tiles[selected];
		if (selected == layer.tiles.length-1 && order == 1) return layer.tiles[selected];

		if (bring) {
			var tile = layer.tiles[selected];

			if (order == -1) {
				layer.addChildAt(tile, 0);
				layer.tiles.remove(tile);
				layer.tiles.unshift(tile);

				return tile;
			}
			else if (order == 1) {
				layer.addChild(tile);
				layer.tiles.remove(tile);
				layer.tiles.push(tile);

				return tile;
			}
		}

		var idx0 = selected;
		var idx1 = selected+order;
		var tmp = layer.tiles[idx0];

		layer.tiles[idx0] = layer.tiles[idx1];
		layer.tiles[idx1] = tmp;

		layer.orderItem(selected, selected+order);

		return layer.tiles[idx1];
	}


	public function setSize(w:Int, h:Int) {
		width = w;
		height = h;

		back.clear();
        back.beginFill(Style.GRID);
        back.drawRect(0, 0, width, height);
        back.endFill();

		setGrid(gridSize);
	}


	public function setOrigin(xpos:Float = 0, ypos:Float =  0) {
		pivot.x = xpos;
		pivot.y = ypos;
	}


	public function setGrid(g:Int) {
		gridSize = Std.int(Math.max(g, 10));
		update();
	}


	public function togleGrid(value:Bool) {
		grid.visible = value;
	}


	public function update() {
		var gridLinesX:Int = Math.round(width / gridSize);
        var gridLinesY:Int = Math.round(height / gridSize);

        grid.clear();
		grid.lineStyle(1 / scaling, Style.CELL);
        
        for (i in 0...gridLinesX) {
            grid.moveTo(pivot.x + i * gridSize, 0);
            grid.lineTo(pivot.x + i * gridSize, height);
        }

        for (i in 0...gridLinesY) {
			grid.moveTo(0, pivot.y + i * gridSize);
            grid.lineTo(width, pivot.y + i * gridSize);
        }
	}
	
}


class Canvas extends h2d.Object {
	

	public function new(?parent:h2d.Object) {
		super(parent);
	}

	public function orderLayer(selected:Int, order:Int) {
		var tmp = children[selected];

		children[selected] = children[order];
		children[order] = tmp;
	}
}