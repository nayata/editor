package heaps;


class Component extends h2d.Object {
	static var all:Array<Component> = [];


	public function new(?parent:h2d.Object) {
		super(parent);
		all.push(this);
	}


	public function update() {
	}


	override function onRemove() {
		super.onRemove();
		all.remove(this);
	}


	public static function updateAll() {
		for (component in all) {
			component.update();
		}
	}
}