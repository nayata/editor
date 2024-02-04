import h3d.Vector;
import h2d.col.Point;
import hxd.Key;
import Project;


class PhysicsExample extends hxd.App {
	var world:World;
	var player:Entity;
	var canJump:Bool = true;
	var speed:Float = 3;


    static function main() {
		new PhysicsExample();
    }


	override function init() {
		engine.backgroundColor = 0x2e2b44;
		s2d.scaleMode = LetterBox(960, 600, true, Center, Center);
		hxd.Res.initLocal();
		
		var project = new Project();
		var scene:SceneData = project.load("Platformer.json");
		
		var obj = project.renderDebugLayer("Collisions");
		s2d.addChild(obj);

		world = new World(scene.width, scene.height);

		var layer:LayerData = project.getLayer("Collisions");

		for (item in layer.tiles) {
			if (item.type == World.STATIC) {
				var body = new Entity();
				body.type = World.STATIC;
				body.x = item.x;
				body.y = item.y;
				body.width = item.width;
				body.height = item.height;

				world.add(body);
			}
		}

		var playerData:BodyData = project.getEntity("Player");

		player = new Entity();
		player.type = World.DYNAMIC;
		world.add(player);

		player.x = playerData.x;
		player.y = playerData.y;

		player.width = playerData.width;
		player.height = playerData.height;

		player.friction = 0.65;

		var graphics = new h2d.Graphics(s2d);
		graphics.lineStyle(2, 0xd81159);
		graphics.beginFill(0xd81159, 0.75);
		graphics.drawRect(-player.width*0.5+1, -player.height*0.5+1, player.width - 2, player.height - 2);
		graphics.endFill();

		player.sprite = graphics;
	}


	override function update(dt:Float) {
		super.update(dt);

		if (Key.isDown(Key.UP) && player.ground && canJump) {
			player.velocity.y = -12;
			player.ground = false;
			canJump = false;
		}
		if (Key.isReleased(Key.UP)) {
			canJump = true;
		}

		if (Key.isDown(Key.LEFT)) player.velocity.x -= speed;
		if (Key.isDown(Key.RIGHT)) player.velocity.x += speed;

		if (!player.ground) player.velocity.y += 9.8 / 16;

		player.x += player.velocity.x;
		player.y += player.velocity.y;

		player.velocity.x *= player.friction;

		world.update(hxd.Timer.tmod);
	}
 }


 class World {
	public static final STATIC:Int = 0;
	public static final DYNAMIC:Int = 1;
	public static final KINEMATIC:Int = 2;
	public static final SENSOR:Int = 3;
	public static final CELL:Int = 4;
	public static final IMAGE:Int = 5;

	public var children:Array<Entity> = [];


	public function new(w:Float, h:Float) {}


	public function add(body:Entity) {
		children.push(body);
	}


	public function update(tmod:Float) {
		for (body in children) {
			if (body.type != STATIC) body.update(tmod);
		}

		detectCollision();

		for (body in children) {
			body.render();
		}
	}


	function detectCollision() {
		for (i in 0...children.length) {
			var a = children[i];
			if (a.type != DYNAMIC) continue;

			for (j in 0...children.length) {
				var b = children[j];
				if (a != b) resolveCollision(a, b);
			}
		}
	}


	function resolveCollision(a:Entity, b:Entity) {
		if (collide(a, b)) {
			switch (b.type) {
				case STATIC:
					var mtd = intersect(a, b);
	
					a.addPosition(mtd.x, mtd.y);
		
					if (mtd.x != 0) a.velocity.x += mtd.x * 0.5;
					if (mtd.y != 0) a.velocity.y += mtd.y * 0.5;
				case DYNAMIC:
					var dx:Float = a.x - b.x; 
					var dy:Float = a.y - b.y;
						
					var overlap:Float = Math.sqrt(dx * dx + dy * dy);
					var epsilon:Float = a.mid.x + b.mid.x;
									
					if (overlap <= epsilon) {
						var len:Float = (epsilon - overlap) * 0.5;
									
						if (overlap == 0) dx = overlap = 0.0001;
						dx /= overlap; 
						dy /= overlap;
					
						a.addPosition(dx * len, dy * len);
						b.addPosition(-dx * len, -dy * len);
					}
				case KINEMATIC:
					var mtd = intersect(a, b);

					mtd.x = Math.round(mtd.x);
					mtd.y = Math.round(mtd.y);
	
					a.addPosition(mtd.x, mtd.y);
		
					if (mtd.x != 0) a.velocity.x += mtd.x * 0.5;
					if (mtd.y != 0) a.velocity.y += mtd.y * 0.5;

					if (a.ground) {
						a.velocity.x += b.velocity.x * (1-a.friction);
						a.velocity.y = b.velocity.y;
					}
				case SENSOR:
				default:
			}
		}
	}


	public function collide(a:Entity, b:Entity):Bool {
		if (a.min.x >= b.max.x) return false;
		if (a.max.x <= b.min.x) return false;
		if (a.min.y >= b.max.y) return false;
		if (a.max.y <= b.min.y) return false;
		return true;
	}


	public function intersect(a:Entity, b:Entity):Point {
		var mtd:Point = new Point(0, 0);

		var left = (b.min.x - a.max.x);
		var right = (b.max.x - a.min.x);
		var top = (b.min.y - a.max.y);
		var bottom = (b.max.y - a.min.y);
		
		// box dont intersect
		if (left > 0 || right < 0) return mtd;
		if (top > 0 || bottom < 0) return mtd;

		// box intersect. work out the mtd on both x and y axes
		if (Math.abs(left) < right) {
			mtd.x = left;
		}
		else {
			mtd.x = right;
		}
		
		if (Math.abs(top) < bottom) {
			mtd.y = top;
		}
		else {
			mtd.y = bottom;
		}
		
		// 0 the axis with the largest mtd value
		if (Math.abs(mtd.x) < Math.abs(mtd.y)) {
			mtd.y = 0;
		}
		else {
			mtd.x = 0; 
			if (Math.abs(top) < bottom) {
				a.ground = true;
			}
		}

		return mtd;
	}
}


class Entity {
	public var sprite:h2d.Object;
	public var type:Int = 0;

	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;

	public var width(default, set):Float = 0;
	public var height(default, set):Float = 0;

	public var min:Point = new Point(0, 0);
	public var max:Point = new Point(0, 0);
	public var mid:Point = new Point(0, 0);

	public var velocity:Point = new Point(0, 0);
	public var friction:Float = 0.98;
	public var ground:Bool = false;


	public function new() {}

	function set_x(value:Float):Float {
		x = value;
		min.x = x - mid.x;
		max.x = x + mid.x;
		return x;
	}

	function set_y(value:Float):Float {
		y = value;
		min.y = y - mid.y;
		max.y = y + mid.y;
		return y;
	}

	function set_width(value:Float):Float {
		width = value;
		mid.x = width * 0.5;
		min.x = x - mid.x;
		max.x = x + mid.x;
		return width;
	}

	function set_height(value:Float):Float {
		height = value;
		mid.y = height * 0.5;
		min.y = y - mid.y;
		max.y = y + mid.y;
		return height;
	}

	public function addPosition(px:Float, py:Float) {
		x += px;
		y += py;
	}

	public function update(tmod:Float) {
		ground = false;
	}

	public function render() {
		if (sprite != null) sprite.setPosition(x, y);
	}
}