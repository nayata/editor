package editor;

import ui.Tool;
import Types;


class MenuPanel extends ui.Panel {
	var fileMenu:ui.DropMenu;
	var editMenu:ui.DropMenu;
	var viewMenu:ui.DropMenu;

	var toolPanel:h2d.Object;
	var viewPanel:h2d.Object;

	var tools:Array<Tool> = [];
	var views:Array<Tool> = [];

	var collisionLayer:Array<Action> = [Select, Hand, Add, Draw, Erase, Duplicate, Delete];
	var imageLayer:Array<Action> = [Select, Hand, Erase, Duplicate, Delete];
	var atlasLayer:Array<Action> = [Select, Hand, Draw, Erase, Duplicate, Delete];
	var gridLayer:Array<Action> = [Hand, Draw, Erase];

	var activeLayer:Int = 0;


	public function new(?parent:h2d.Object) {
		super(parent);

		fileMenu = new ui.DropMenu(this, 10, 5, "File", fileEvent);
		fileMenu.itemAlign(Side.Left);
		fileMenu.itemSize(220, 40);
		fileMenu.setSize(60, 30);

		fileMenu.addItem("New", New);
		fileMenu.addItem("Open", Open);
		fileMenu.addItem("Save", Save);
		fileMenu.addItem("Save As", SaveAs);
		fileMenu.addItem("Export Image", Export);
		fileMenu.addItem("About", About);
		fileMenu.addItem("Exit", Exit);

		editMenu = new ui.DropMenu(this, 70, 5, "Edit", editEvent);
		editMenu.itemAlign(Side.Left);
		editMenu.itemSize(220, 40);
		editMenu.setSize(60, 30);

		editMenu.addItem("Bring to Front", Front, false);
		editMenu.addItem("Bring Forward", Forward, false);
		editMenu.addItem("Send Backward", Backward, false);
		editMenu.addItem("Send to Back", Back, false);
		editMenu.addDivider();
		editMenu.addItem("Align Top", Top, false);
		editMenu.addItem("Align Vertical Center", Vertical, false);
		editMenu.addItem("Align Bottom", Bottom, false);
		editMenu.addDivider();
		editMenu.addItem("Align Left", Left, false);
		editMenu.addItem("Align Horizontal Center", Horizontal, false);
		editMenu.addItem("Align Right", Right, false);

		viewMenu = new ui.DropMenu(this, 130, 5, "View", viewEvent);
		viewMenu.itemAlign(Side.Left);
		viewMenu.itemSize(220, 40);
		viewMenu.setSize(60, 30);

		viewMenu.addItem("Actual Size", ActualSize);
		viewMenu.addItem("Fit on Screen", FitScreen);
		viewMenu.addDivider();
		viewMenu.addItem("Hide Names", HideNames, false);
		viewMenu.addItem("Hide Path", HidePath, false);
		viewMenu.addItem("Hide Grid", HideGrid, false);

		toolPanel = new h2d.Object(this);
		viewPanel = new h2d.Object(this);

		var offset = 0;

		var tool = new Tool(toolPanel, 40 * offset++, 0, toolEvent);
		tool.action = Select;
		tool.setIcon(0, 0);
		tool.toggle = true;
		tool.selected = true;
		tools.push(tool);

		tool = new Tool(toolPanel, 40 * offset++, 0, toolEvent);
		tool.action = Hand;
		tool.setIcon(1, 0);
		tool.toggle = true;
		tools.push(tool);

		tool = new Tool(toolPanel, 40 * offset++, 0, toolEvent);
		tool.action = Add;
		tool.tooltip = "Add collision tile";
		tool.setIcon(2, 0);
		tool.toggle = true;
		tools.push(tool);

		tool = new Tool(toolPanel, 40 * offset++, 0, toolEvent);
		tool.action = Draw;
		tool.tooltip = "Draw tiles";
		tool.setIcon(3, 0);
		tool.toggle = true;
		tools.push(tool);

		tool = new Tool(toolPanel, 40 * offset++, 0, toolEvent);
		tool.action = Erase;
		tool.tooltip = "Erase tiles";
		tool.setIcon(4, 0);
		tool.toggle = true;
		tools.push(tool);

		tool = new Tool(toolPanel, 40 * offset++, 0, toolEvent);
		tool.action = Duplicate;
		tool.tooltip = "Duplicate tile";
		tool.setIcon(2, 1);
		tools.push(tool);

		tool = new Tool(toolPanel, 40 * offset++, 0, toolEvent);
		tool.action = Delete;
		tool.tooltip = "Delete tile";
		tool.setIcon(3, 1);
		tools.push(tool);

		setTool(false);
	}


	function fileEvent() {
		Editor.ME.fileEvent(fileMenu.event);
	}


	function editEvent() {
		Editor.ME.editEvent(editMenu.event);
	}


	function viewEvent() {
		var event = viewMenu.event;

		switch (event) {
			case HideNames:
				viewMenu.itemText("Show Names");
				viewMenu.itemType(ShowNames);
			case ShowNames:
				viewMenu.itemText("Hide Names");
				viewMenu.itemType(HideNames);
			case HidePath:
				viewMenu.itemText("Show Path");
				viewMenu.itemType(ShowPath);
			case ShowPath:
				viewMenu.itemText("Hide Path");
				viewMenu.itemType(HidePath);
			case HideGrid:
				viewMenu.itemText("Show Grid");
				viewMenu.itemType(ShowGrid);
			case ShowGrid:
				viewMenu.itemText("Hide Grid");
				viewMenu.itemType(HideGrid);
			default:
		}
		
		Editor.ME.viewEvent(event);
	}


	function toolEvent(event:Action) {
		var switched:Bool = false;

		for (tool in tools) {
			if (tool.action == event) {
				if (tool.toggle) {
					tool.selected = switched = true;
				}
			}
		}

		for (tool in tools) {
			if (switched && tool.action != event) tool.selected = false;
		}

		Editor.ME.toolEvent(event);
	}


	public function setTool(value:Bool) {
		var array = [Duplicate, Delete];

		for (tool in tools) {
			if (array.contains(tool.action)) tool.active = value;
		}
	}


	public function setTools(array:Array<Action>) {
		for (tool in tools) {
			tool.active = false;
			if (array.contains(tool.action)) tool.active = true;
		}
	}


	public function setLayer(value:Int, tool:Action) {
		if (activeLayer == value) return;
		activeLayer = value;

		switch (activeLayer) {
			case LayerType.Collision:
				setTools(collisionLayer);
				if (!collisionLayer.contains(tool) || tool == Hand) toolEvent(Select);
			case LayerType.Image:
				setTools(imageLayer);
				if (!imageLayer.contains(tool) || tool == Hand) toolEvent(Select);
			case LayerType.Atlas:
				setTools(atlasLayer);
				if (!atlasLayer.contains(tool) || tool == Hand) toolEvent(Select);
			case LayerType.Grid:
				setTools(gridLayer);
				if (!gridLayer.contains(tool)) toolEvent(Hand);
			default:
		}

		//Editor.ME.toolEvent(tool);
	}


	override function onResize() {
		var bound = toolPanel.getBounds();
		toolPanel.x = (width-300) * 0.5 - bound.width * 0.5;
	}
}