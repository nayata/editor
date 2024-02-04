package heaps;


class TextureAtlas {
	public var name:String = "";
	public var content:Map<String,Array<{ t : h2d.Tile, width : Int, height : Int }>>;
	public var regions:Array<{ name : String, x : Int, y : Int, w : Int, h : Int }>;
	public var bitmap:h2d.Bitmap;


	public function new(entry:String, file:h2d.Bitmap) {
		bitmap = file;

		content = new Map();
		regions = [];

		var lines = entry.split("\n");

		while( lines.length > 0 ) {
			var line = StringTools.trim(lines.shift());
			if ( line == "" ) continue;
			var scale = 1.;
			while( lines.length > 0 ) {
				if( lines[0].indexOf(":") < 0 ) break;
				var line = StringTools.trim(lines.shift()).split(": ");
				switch( line[0] ) {
				case "size":
					var wh = line[1].split(",");
					var w = Std.parseInt(wh[0]);
					scale = file.tile.width / w;
				default:
				}
			}
			while( lines.length > 0 ) {
				var line = StringTools.trim(lines.shift());
				if( line == "" ) break;
				var prop = line.split(": ");
				if( prop.length > 1 ) continue;
				var key = line;
				var tileX = 0, tileY = 0, tileW = 0, tileH = 0, tileDX = 0, tileDY = 0, origW = 0, origH = 0, index = 0;
				while( lines.length > 0 ) {
					var line = StringTools.trim(lines.shift());
					var prop = line.split(": ");
					if( prop.length == 1 ) {
						lines.unshift(line);
						break;
					}
					var v = prop[1];
					switch( prop[0] ) {
					case "rotate":
						if( v == "true" ) throw "Rotation not supported in atlas";
					case "xy":
						var vals = v.split(",");
						tileX = Std.parseInt(vals[0]);
						tileY = Std.parseInt(vals[1]);
					case "size":
						var vals = v.split(",");
						tileW = Std.parseInt(vals[0]);
						tileH = Std.parseInt(vals[1]);
					case "offset":
						var vals = v.split(",");
						tileDX = Std.parseInt(vals[0]);
						tileDY = Std.parseInt(vals[1]);
					case "orig":
						var vals = v.split(",");
						origW = Std.parseInt(vals[0]);
						origH = Std.parseInt(vals[1]);
					case "index":
						index = Std.parseInt(v);
						if( index < 0 ) index = 0;
					default:
						trace("Unknown prop " + prop[0]);
					}
				}
				// offset is bottom-relative
				tileDY = origH - (tileH + tileDY);

				var t = file.tile.sub(Std.int(tileX * scale), Std.int(tileY * scale), Std.int(tileW * scale), Std.int(tileH * scale), tileDX, tileDY);
				if( scale != 1 ) t.scaleToSize(tileW, tileH);
				var tl = content.get(key);
				if( tl == null ) {
					tl = [];
					content.set(key, tl);

					regions.push({name : key, x : Std.int(tileX * scale), y : Std.int(tileY * scale), w:Std.int(tileW * scale), h:Std.int(tileH * scale)});
				}
				tl[index] = { t : t, width : origW, height : origH };
			}
		}

		// remove first element if index started at 1 instead of 0
		for( tl in content ) {
			if( tl.length > 1 && tl[0] == null ) tl.shift();
		}
	}


	function tileAlign( t : h2d.Tile, halign : h2d.Flow.FlowAlign, valign : h2d.Flow.FlowAlign, width : Int, height : Int ) {
		if( halign == null ) halign = Left;
		if( valign == null ) valign = Top;
		var dx = 0, dy = 0;
		switch( halign ) {
		case Middle:
			dx = width >> 1;
		case Right:
			dx = width;
		default:
		}
		switch( valign ) {
		case Middle:
			dy = height >> 1;
		case Bottom:
			dy = height;
		default:
		}
		return t.sub(0, 0, t.width, t.height, t.dx - dx, t.dy - dy);
	}


	public function get( name : String, ?horizontalAlign : h2d.Flow.FlowAlign, ?verticalAlign : h2d.Flow.FlowAlign ) : h2d.Tile {
		var c = content.get(name);
		if( c == null )
			return null;
		var t = c[0];
		if( t == null )
			return null;
		return tileAlign(t.t, horizontalAlign, verticalAlign, t.width, t.height);
	}





}
