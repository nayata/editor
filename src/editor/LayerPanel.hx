package editor;

import ui.Panel;
import ui.LayerItem;
import Types;


class LayerPanel extends h2d.Object {
	var editMenu:ui.DropMenu;

	var input:h2d.Interactive;
	var dragger:Dragger;
	var panel:h2d.Flow;

	var items:Array<LayerItem> = [];
	var highlightedItem:Int = -1;
	var highlightedLayer:Int = -1;

	var itemHeight:Float = 40;
	var itemSelectWidth:Float = 60;

	var width:Float = 300;
	var height:Float = 40;

	var minHeight = 40;
	var maxHeight = 320;

	var doubleClickTime:Int = 30;
	var doubleClick:Int = -1;

	public var onResize:Void->Void;
	public var position:Float = 120 + Style.borderSize;
	public var selectedItem(default, set):Int = -1;

	public var scene(default, set):Scene;


	public function new(?parent:h2d.Object) {
		super(parent);

		panel = new h2d.Flow(this);
		panel.layout = Vertical;
		panel.minWidth = 300;
		panel.maxHeight = 120;
		panel.overflow = Scroll;
		panel.y = itemHeight;

		panel.reverse = true;

		panel.scrollBar.backgroundTile = h2d.Tile.fromColor(Style.menuBack);
		panel.scrollBar.alpha = 1;

		panel.scrollBarCursor.backgroundTile = h2d.Tile.fromColor(Style.menuText);
		panel.scrollBarCursor.minWidth = 10;

		input = new h2d.Interactive(0, 0, this);
		input.cursor = Default;
		input.y = itemHeight;

		input.onClick = onClick;
		input.onMove = onMove;
		input.onOver = onOver;
		input.onOut = onOut;

		dragger = new Dragger(this);
		dragger.onChange = onChange;
		dragger.y = minHeight+itemHeight;

		editMenu = new ui.DropMenu(this, 300-60, 0, "", editEvent);
		editMenu.itemAlign(Side.Right);
		editMenu.itemSize(200, 40);
		editMenu.setSize(40, 40);

		editMenu.addItem("Add Collision Layer", Collision, false);
		editMenu.addItem("Add Image Layer", Image, false);
		editMenu.addItem("Add Atlas Layer", Atlas, false);
		editMenu.addItem("Add Grid Layer", Grid, false);
		editMenu.addDivider();
		editMenu.addItem("Order Up", Forward, false);
		editMenu.addItem("Order Down", Backward, false);
		editMenu.addDivider();
		editMenu.addItem("Delete", Delete, false);

		var face = new h2d.Bitmap(this);
		face.tile = Editor.ME.atlas[0][3];
		face.x = 300-60;

		setSize(300, 40);
	}


	function set_scene(s) {
		scene = s;

		panel.removeChildren();

		items = [];
		highlightedItem = -1;
		selectedItem = -1;

		position = 120 + Style.borderSize;
		minHeight = 40;

		dragger.minHeight = 80;
		dragger.maxHeight = 80;
		dragger.position = 0;
		dragger.y = minHeight+itemHeight;

		panel.maxHeight = Std.int(dragger.position - itemHeight);
		position = panel.innerHeight + 80 + Style.borderSize;
		panel.scrollPosY = 0;

		setSize(300, 40);
		addSceneLayers();

		return s;
	}


	function editEvent() {
		var event = editMenu.event;

		switch (event) {
			case Collision:
				scene.addLayer(LayerType.Collision, "Collision Layer", selectedItem+1);
				addItem(LayerType.Collision, "Collision Layer");
			case Grid:
				scene.addLayer(LayerType.Grid, "Grid Layer", selectedItem+1);
				addItem(LayerType.Grid, "Grid Layer");
			case Image:
				scene.addLayer(LayerType.Image, "Image Layer", selectedItem+1);
				addItem(LayerType.Image, "Image Layer");
			case Atlas:
				scene.addLayer(LayerType.Atlas, "Atlas Layer", selectedItem+1);
				addItem(LayerType.Atlas, "Atlas Layer");	
			case Forward:
				orderLayer(1);
			case Backward:
				orderLayer(-1);
			case Delete:
				removeLayer();
			default:
		}
	}


	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;

		input.width = width;
		input.height = height;

		var bound = panel.scrollBar.visible ? 290 : 300;

		for (item in items) {
			item.setSize(bound, 40);
		}
	}


	function addSceneLayers() {
		for (layer in scene.layers) {
			addItem(layer.type, layer.name);
		}
	}


	function setLayer(index:Int = -1) {
		scene.layer = scene.layers[index];
		Editor.ME.layerEvent();
	}


	function orderLayer(order:Int = -1) {
		scene.orderLayer(selectedItem, order);

		if (selectedItem <= 0 && order == -1) return;
		if (selectedItem == items.length-1 && order == 1) return;

		
		var tempName = items[selectedItem].name;
		var tempType = items[selectedItem].type;

		items[selectedItem].name = items[selectedItem+order].name;
		items[selectedItem].type = items[selectedItem+order].type;
		items[selectedItem].text = items[selectedItem+order].text;

		selectedItem = selectedItem+order;

		items[selectedItem].name = tempName;
		items[selectedItem].type = tempType;
		items[selectedItem].text = tempName;

		for (item in items) {
			item.selected = false;
		}
		items[selectedItem].selected = true;
	}


	function removeLayer() {
		if (items.length == 1) return;

		scene.removeLayer(selectedItem);

		var item = items[selectedItem];
		items.remove(item);
		item.remove();

		var order = selectedItem <= 0 ? 0 : -1;
		selectedItem = selectedItem+order;

		for (item in items) {
			item.selected = false;
		}
		items[selectedItem].selected = true;

		Editor.ME.layerEvent();

		var maxHeightLimit = 40+itemHeight*3;

		dragger.maxHeight = items.length*itemHeight + itemHeight;
		dragger.maxHeight = Math.max(dragger.maxHeight, 80);

		dragger.position = dragger.y > dragger.maxHeight ? dragger.maxHeight : dragger.y;
		dragger.y = dragger.position;

		panel.maxHeight = Std.int(dragger.position - itemHeight);
		position = panel.innerHeight + 80 + Style.borderSize;

		setSize(width, panel.innerHeight);
		onResize();
	}


	function setLayerView(index:Int = -1) {
		var value = items[index].view;
		scene.layers[index].visible = value;
	}


	function layerOver(index:Int = -1) {
		if (index == highlightedLayer) return;

		highlightedLayer = index;
		for (layer in scene.layers) {
			layer.alpha = 0.3;
		}
		scene.layers[highlightedLayer].alpha = 1;
	}


	function layerOut() {
		highlightedLayer = -1;
		for (layer in scene.layers) {
			layer.alpha = 1;
		}
	}


	function addItem(type:Int = 0, text:String = "") {
		var item = new LayerItem(text);
		item.name = text;
		item.type = type;
		items.insert(selectedItem+1, item);

		panel.addChildAt(item, selectedItem);

		item.input.onChange = onChangeName;

		selectedItem = selectedItem+1;

		for (item in items) {
			item.selected = false;
		}
		items[selectedItem].selected = true;

		scene.layer = scene.layers[selectedItem];
		Editor.ME.layerEvent();

		var maxHeightLimit = 40+itemHeight*3;

		dragger.maxHeight = items.length*itemHeight + itemHeight;
		dragger.maxHeight = Math.min(dragger.maxHeight, 320);

		dragger.position = dragger.maxHeight <= maxHeightLimit ? dragger.maxHeight : dragger.y;
		dragger.y = dragger.position;

		panel.maxHeight = Std.int(dragger.position - itemHeight);
		position = panel.innerHeight + 80 + Style.borderSize;

		setSize(width, panel.innerHeight);
		onResize();
	}


	function onChangeName() {
		var text = items[selectedItem].text;
		
		scene.layers[selectedItem].name = text;
		items[selectedItem].name = text;
	}


	function onChange() {
		input.height = Std.int(dragger.position - itemHeight);
		panel.maxHeight = Std.int(dragger.position - itemHeight);
		position = panel.innerHeight + 80 + Style.borderSize;

		setSize(width, panel.innerHeight);
		onResize();
	}


	function onClick(e:hxd.Event) {
		var clickPos = new h2d.col.Point(e.relX, e.relY);

		if (highlightedItem != -1) {
			if (clickPos.x <= width-itemSelectWidth) {

				if (selectedItem == highlightedItem) {
					var current = Math.abs(doubleClick - hxd.Timer.frameCount);
					if (current < doubleClickTime) {
						items[selectedItem].input.focus();
					}
				}

				selectedItem = highlightedItem;
				for (item in items) {
					item.selected = false;
				}
				items[selectedItem].selected = true;
				setLayer(selectedItem);

				doubleClick = hxd.Timer.frameCount;
			}
			else {
				items[highlightedItem].togleView();
				setLayerView(highlightedItem);
			}
		}
	}


	function onMove(e:hxd.Event) {
		var clickPos = new h2d.col.Point(e.relX, e.relY);
		highlightedItem = -1;

		for (i in 0...items.length) {
			var item = items[i];

			var yMin = item.y;
			var yMax = item.y + itemHeight;

			item.onOver(false);

			if (clickPos.y >= yMin && clickPos.y < yMax) {
				highlightedItem = i;
				item.onOver(true);

				layerOver(highlightedItem);
			}
		}
	}


	function onOver(e:hxd.Event) {
		input.focus();
	}


	function onOut(e:hxd.Event) {
		for (item in items) {
			item.onOver(false);
		}
		layerOut();
	}

	function set_selectedItem(s) {
		if( s < 0 )
			s = -1;
		else if( s >= items.length )
			s = items.length - 1;

		return selectedItem = s;
	}
}


class Dragger extends ui.Panel {
	var input:h2d.Interactive;
	var icon:h2d.Bitmap;

	var moving(default, null): Bool;

	public var minHeight:Float = 80;
	public var maxHeight:Float = 80;
	public var position:Float = 0;

	public var onChange:Void->Void = null;
	

	public function new(?parent:h2d.Object) {
		super(parent);

		input = new h2d.Interactive(300, 40, this);
		input.propagateEvents = true;
		input.onPush = onDown;
		input.onMove = onMove;

		icon = new h2d.Bitmap(this);
		icon.tile = Editor.ME.atlas[4][3];
		icon.x = 150-20;

		setBorder(Side.Bottom);
		borderStyle(Side.Outer);
		setSize(300, 40);
	}

	function onDown(event:hxd.Event) {
		if (event.button != 0) return;
		event.propagate = false;
		startMove();
	}

	function onMove(event:hxd.Event) {
		if (moving) return;
	}

	public function startMove() {
		var scene = getScene();
		var dragStart = scene.mouseY-y;

		moving = true;

		input.startCapture(function(e:hxd.Event) {
			switch( e.kind ) {
			case ERelease, EReleaseOutside:
				moving = false;
				input.stopCapture();
			case EMove:
				position = scene.mouseY - dragStart;

				if (position <= minHeight) position = minHeight;
				if (position >= maxHeight) position = maxHeight;

				y = position;

				if (onChange != null) onChange();
			default:
			}
		}, function() {
			moving = false;
		});
	}
}