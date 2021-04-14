extends Node

# i really need to do this better

export var db_path: NodePath;
onready var db: GDMLReactiveDatablock = get_node(db_path);

export var cancel_btn: NodePath;
onready var cancel: Button = get_node(cancel_btn).get_child(0);

export var continue_btn: NodePath;
onready var cont: Button = get_node(continue_btn).get_child(0);

export var start_btn_1: NodePath;
onready var start_1: Button = get_node(start_btn_1).get_child(0);

export var timer_p_1: NodePath;
onready var timer_1 = get_node(timer_p_1).get_child(0);

export var start_btn_2: NodePath;
onready var start_2: Button = get_node(start_btn_2).get_child(0);

export var timer_p_2: NodePath;
onready var timer_2 = get_node(timer_p_2).get_child(0);


onready var owoIPC: OwoIPC = get_node("/root/owoIPCSingleton");

onready var persistence = preload("res://src/persistence.gd").new();



func complete_calibration() -> void:
	yield(get_tree().create_timer(0.5), "timeout");
	
	# TOOD: this sucks, but currently there is little other choice
	var node: TrackerSettings = db.get_parent().find_node("TrackerSettingsScript", true, false);
	if(!node):
		print("Error cant find");
	
	node.after_calibration_read_vectors();
	
	cancel();

func start_timer_2() -> void:
	owoIPC.set_calibrating_down(db.owo_device_id, true);
	db.timer_running = true;
	timer_2.start_timer(1);
	yield(timer_2, "ended");
	db.timer_running = false;
	
	owoIPC.set_calibrating_down(db.owo_device_id, false);
	
	complete_calibration();
	

func start_timer_1() -> void:
	db.timer_running = true;
	timer_1.start_timer(3);
	yield(timer_1, "ended");
	db.timer_running = false;
	
	owoIPC.set_calibrating(db.owo_device_id, false);
	
	db.calibrating_mode = 3

func cancel() -> void:
	db.calibrating_mode = 0;
	owoIPC.set_calibrating(db.owo_device_id, false);
	owoIPC.set_calibrating_down(db.owo_device_id, false);

func cont() -> void:
	db.calibrating_mode = 2;
	owoIPC.set_calibrating(db.owo_device_id, true);

func tracker_added(idx: int, port: int) -> void:
	if(idx != db.owo_device_id):
		return;
	
	var calibration_val: float = persistence.get_yaw_calibration_from_file();
	if(calibration_val != 0.0):
		owoIPC.set_yaw(db.owo_device_id, calibration_val);
		db.is_calibrated = true;
	else:
		db.calibrating_mode = 1;

func _ready() -> void:
	add_child(persistence);
	cancel.connect("pressed", self, "cancel");
	cont.connect("pressed", self, "cont");
	start_1.connect("pressed", self, "start_timer_1");
	start_2.connect("pressed", self, "start_timer_2");
	
	owoIPC.connect("tracker_added", self, "tracker_added");
