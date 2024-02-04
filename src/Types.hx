enum State {
	Lock;
	Add;
	Hand;
	Move;
	Scale;
	ScaleX;
	ScaleY;
	Draw;
	Erase;
	Image;
	Brush;
	Path;
}

enum Side {
	None;
	Top;
	Right;
	Bottom;
	Left;
	Horisontal;
	Vertical;
	Inner;
	Outer;
}

enum Action {
	None;
	Select;
	Hand;
	Add;
	Draw;
	Image;
	Brush;
	Erase;
	OrderDown;
	OrderUp;
	Duplicate;
	Delete;
}

enum MenuEvent {
	None;

	New;
	Open;
	Save;
	SaveAs;
	Export;
	About;
	Exit;

	Front;
	Forward;
	Backward;
	Back;
	Top;
	Vertical;
	Bottom;
	Left;
	Horizontal;
	Right;

	ActualSize;
	FitScreen;
	HideNames;
	ShowNames;
	HidePath;
	ShowPath;
	HideGrid;
	ShowGrid;

	posX;
	posY;
	Width;
	Height;
	Name;

	Data;
	Tag;
	Path;
	AddData;
	AddTag;
	AddPath;
	RemoveData;
	RemoveTag;
	RemovePath;
	CustomColor;
	DefaultColor;

	Collision;
	Image;
	Atlas;
	Grid;
	Delete;
}

enum abstract LayerType(Int) to Int {
	var Collision;
	var Grid;
	var Image;
	var Atlas;
}

enum abstract TileType(Int) to Int {
	var Static;
	var Dynamic;
	var Kinematic;
	var Sensor;
	var Cell;
	var Image;
}