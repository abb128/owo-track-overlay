extends Node

# i really need to do this better

export var db_path: NodePath;
onready var db: GDMLReactiveDatablock = get_node(db_path);

export var cancel_btn: NodePath;
onready var cancel: Button = get_node(cancel_btn).get_child(0);

export var continue_btn: NodePath;
onready var cont: Button = get_node(continue_btn).get_child(0);

export var start_btn: NodePath;
onready var start: Button = get_node(start_btn).get_child(0);

export var timer_p: NodePath;
onready var timer = get_node(timer_p).get_child(0);


onready var owoIPC: OwoIPC = get_node("/root/owoIPCSingleton");

onready var persistence = preload("res://src/persistence.gd").new();


func complete_calibration() -> void:
	owoIPC.set_calibrating(db.owo_device_id, false);
	yield(get_tree().create_timer(0.5), "timeout");
	var yaw: float = yield(owoIPC.get_yaw(db.owo_device_id), "completed");
	persistence.save_calibration_to_file(yaw);

func start_timer() -> void:
	db.timer_running = true;
	timer.start_timer(5);
	yield(timer, "ended");
	db.timer_running = false;
	
	complete_calibration();
	
	cancel();

func cancel() -> void:
	db.calibrating_mode = 0;

func cont() -> void:
	db.calibrating_mode = 2;
	owoIPC.set_calibrating(db.owo_device_id, true);

func tracker_added(idx: int, port: int) -> void:
	if(idx != db.owo_device_id):
		return;
	
	var calibration_val: float = persistence.get_calibration_from_file();
	if(calibration_val != 0.0):
		owoIPC.set_yaw(db.owo_device_id, calibration_val);
		db.is_calibrated = true;
	else:
		db.calibrating_mode = 1;

func _ready() -> void:
	add_child(persistence);
	cancel.connect("pressed", self, "cancel");
	cont.connect("pressed", self, "cont");
	start.connect("pressed", self, "start_timer");
	
	owoIPC.connect("tracker_added", self, "tracker_added");
