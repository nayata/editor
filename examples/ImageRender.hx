class ImageRender extends hxd.App {
	var title:h2d.Object;
	var button:h2d.Object;
	var bounce:Float = 0;
	

    static function main() {
		new ImageRender();
    }


	override function init() {
		engine.backgroundColor = 0x2e2b44;
		s2d.scaleMode = LetterBox(960, 600, false, Center, Center);
		hxd.Res.initLocal();
		
		var project = new Project();
		project.load("UI.json");
		
		var obj = project.render();
		s2d.addChild(obj);

		title = obj.getObjectByName("Title");
		button = obj.getObjectByName("Button");
	}


	override function update(dt:Float) {
		super.update(dt);

		title.y += Math.sin(bounce += 0.075) * 0.25;
	}
 }