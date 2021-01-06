extends Node

export var db_path: NodePath;
onready var db = get_node(db_path);

export var db_s_path: NodePath;
onready var db_s = get_node(db_s_path);

export var device_id: int;

onready var owoIPC: OwoIPC = get_node("/root/owoIPCSingleton");

export var pos_predict := false setget set_predict;
export var device_space := false setget set_device_space;
export var hip_height: float = 0.0 setget set_hip_height;

export var tracker_offset: Vector3 setget set_tracker_offset;
export var headset_offset: Vector3 setget set_tracker_offset;
export var global_offset: Vector3 setget set_tracker_offset;

export var global_rot_offset: Vector3 setget set_tracker_offset;
export var local_rot_offset: Vector3 setget set_tracker_offset;

export var is_advanced: bool setget set_tracker_offset;

const Persistence = preload("res://src/persistence.gd");
onready var persistence: Persistence = Persistence.new();

func set_tracker_offset(to) -> void:
	update_vectors();
	update_savefile();

func update_vectors():
	if(!db):
		return;
	
	var offset_tracker: Vector3 = Vector3.ZERO;
	var offset_global: Vector3 = Vector3.ZERO;
	if(!db_s.advanced):
		offset_tracker = Vector3(0, -hip_height if device_space else 0, 0);
		offset_global = Vector3(0, -hip_height if !device_space else 0, 0);
	else:
		offset_tracker = db.trackerOffset;
		offset_global = db.globalOffset;
	
	owoIPC.set_offset_local_t(device_id, offset_tracker);
	owoIPC.set_offset_global(device_id, offset_global);
	
	owoIPC.set_offset_local_d(device_id, db.headOffset);
	
	owoIPC.set_rot_offset_global(device_id, Vector3(
		deg2rad(db.globalRotOffset.x),
		deg2rad(db.globalRotOffset.y),
		deg2rad(db.globalRotOffset.z)
	));
	
	owoIPC.set_rot_offset_local(device_id, Vector3(
		deg2rad(db.localRotOffset.x),
		deg2rad(db.localRotOffset.y),
		deg2rad(db.localRotOffset.z)
	));


func set_predict(to: bool):
	owoIPC.set_predict(device_id, to);
	pos_predict = to;
	update_savefile();

func set_device_space(to: bool):
	device_space = to;
	update_vectors();
	update_savefile();

func set_hip_height(to: float):
	hip_height = to;
	update_vectors();
	update_savefile();

var loaded: bool = false;

func update_savefile() -> void:
	if(!loaded || (persistence == null)):
		return;
	persistence.save_datablock_settings(db_s, "simple_settings_0");
	persistence.save_datablock_settings(db, "adv_settings_0");


func tracker_added(a, b):
	update_vectors();

func _ready():
	add_child(persistence);
	persistence.load_datablock_settings(db_s, "simple_settings_0");
	persistence.load_datablock_settings(db, "adv_settings_0");
	loaded = true;
	
	owoIPC.connect("tracker_added", self, "tracker_added");
	update_vectors();
