extends Node


export var db_path: NodePath;
onready var db = get_node(db_path);


export var spawn_path: NodePath;
onready var spawn = get_node(spawn_path).get_child(0);

onready var owoIPC: OwoIPC = get_node("/root/owoIPCSingleton");

var did_spawn := false;

func spawn_tracker() -> void:
	var idx = yield(owoIPC.spawn_tracker(db.port_no), "completed");
	did_spawn = true;


func _process(_d: float) -> void:
	var num = yield(owoIPC.get_tracker_count(), "completed");
	if(num > 0):
		db.tracker_spawned = true;
		set_process(false);
	elif(did_spawn):
		db.failure = true;

func initialize() -> void:
	pass

func make_connections() -> void:
	spawn.connect("pressed", self, "spawn_tracker");

func _ready() -> void:
	make_connections();
	initialize();
