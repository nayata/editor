package editor;

import ui.Label;
import ui.TextInput;
import ui.Tab;

import Types;


class SidePanel extends ui.Panel {
	
	public var layerPanel:LayerPanel;
	public var itemPanel:Properties;
	public var scenePanel:SceneProperties;

	public var imagePanel:ImagePanel;
	public var atlasPanel:AtlasPanel;

	var layer:Tab;
	var scene:Tab;

	var activeLayer:Int = 0;
	var position:Float = 0;


	public function new(?parent:h2d.Object) {
		super(parent);

		layer = new Tab(this, layerTab);
		layer.text = "Layers";
		layer.index = 0;

		layer.setBorder(Side.Right);
		layer.borderStyle(Side.Inner);
		layer.setSize(150, 46);

		scene = new Tab(this, sceneTab);
		scene.text = "Scene";
		scene.index = 1;

		scene.setBorder(Side.Left);
		scene.borderStyle(Side.Inner);
		scene.setSize(150, 46);

		layer.active = true;
		scene.active = false;

		itemPanel = new Properties(layer.view);
		itemPanel.y = 160;

		imagePanel = new ImagePanel(layer.view);
		imagePanel.y = 160;

		atlasPanel = new AtlasPanel(layer.view);
		atlasPanel.y = 160;

		layerPanel = new LayerPanel(layer.view);
		layerPanel.onResize = onResize;

		scenePanel = new SceneProperties(scene.view);
		scenePanel.y = 40;
	}


	function layerTab(event:hxd.Event) {
		layer.active = true;
		scene.active = false;
	}


	function sceneTab(event:hxd.Event) {
		layer.active = false;
		scene.active = true;
	}


	public function setLayer(value:Int) {
		if (activeLayer == value) return;
		activeLayer = value;

		switch (activeLayer) {
			case LayerType.Collision:
				itemPanel.visible = true;
				imagePanel.visible = false;
				atlasPanel.visible = false;
				position = 0;
			case LayerType.Image:
				itemPanel.visible = true;
				imagePanel.visible = true;
				atlasPanel.visible = false;
				position = imagePanel.height+40;
			case LayerType.Atlas:
				itemPanel.visible = true;
				imagePanel.visible = false;
				atlasPanel.visible = true;
				position = atlasPanel.height+40;
			case LayerType.Grid:
				itemPanel.visible = false;
				imagePanel.visible = false;
				atlasPanel.visible = false;
				position = 0;
			default:
		}
	}


	override public function onResize() {
		imagePanel.y = layerPanel.position+40;
		atlasPanel.y = layerPanel.position+40;
		atlasPanel.onResize();

		itemPanel.y = layerPanel.position+position+40;
		itemPanel.onResize();
	}
}