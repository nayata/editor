class TileGroupRender extends hxd.App {
	var label:h2d.Text;


    static function main() {
		new TileGroupRender();
    }


	override function init() {
		engine.backgroundColor = 0x2e2b44;
		s2d.scaleMode = LetterBox(960, 600, true, Center, Center);
		hxd.Res.initLocal();
		
		var project = new Project();
		project.load("Platformer.json");
		
		var imageLayer = project.renderLayer("Background");
		s2d.addChild(imageLayer);

		var tileLayer = project.renderLayer("Level");
		s2d.addChild(tileLayer);

		label = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		label.x = label.y = 10;
	}


	override function update(dt:Float) {
		super.update(dt);

		label.text = "Draw calls: " + engine.drawCalls;
	}
 }