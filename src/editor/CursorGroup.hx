package editor;


class CursorGroup extends h2d.Object {
	public var brush:ui.Brush;
	public var control:ui.Gizmo2D;
	public var highlight:ui.Highlight;

	
	public function new(?parent:h2d.Object) {
		super(parent);

		brush = new ui.Brush(this);
		brush.visible = false;

		control = new ui.Gizmo2D(this);
		control.setSize(10, 10);
		control.visible = false;

		highlight = new ui.Highlight(this);
		highlight.visible = false;
	}
}