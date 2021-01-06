extends Node

export var inputX: NodePath;
export var inputY: NodePath;
export var inputZ: NodePath;

onready var iX: Range = get_node(inputX);
onready var iY: Range = get_node(inputY);
onready var iZ: Range = get_node(inputZ);

export var mainDB: NodePath;
onready var db = get_node(mainDB);


export var vecValue: Vector3 setget set_vecValue;

func set_vecValue(to: Vector3) -> void:
	if(iX == null):
		return;
	
	vecValue = to;
	
	iX.value = to.x;
	iY.value = to.y;
	iZ.value = to.z;

func value_changed(value: float, idx: int) -> void:
	db.value = Vector3(iX.value, iY.value, iZ.value);

func _ready() -> void:
	iX.connect("value_changed", self, "value_changed", [0]);
	iY.connect("value_changed", self, "value_changed", [1]);
	iZ.connect("value_changed", self, "value_changed", [2]);
