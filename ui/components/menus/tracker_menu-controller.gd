extends Node

export var db_path: NodePath;
onready var db = get_node(db_path);

export var calibrator_path: NodePath;
onready var calibrator = get_node(calibrator_path);

export var recal_btn: NodePath;
onready var recal: Button = get_node(recal_btn).get_child(0);


export var pos_predict := false setget set_predict;
export var device_space := false setget set_device_space;
export var hip_height: float = 0.0 setget set_hip_height;


onready var owoIPC: OwoIPC = get_node("/root/owoIPCSingleton");

func update_vectors():
	if(!db):
		return;
	
	var offset_local_tracker = Vector3(0, -hip_height if device_space else 0, 0);
	var offset_global = Vector3(0, -hip_height if !device_space else 0, 0);
	
	
	owoIPC.set_offset_local_t(db.device_idx, offset_local_tracker);
	owoIPC.set_offset_global(db.device_idx, offset_global);


func set_predict(to: bool):
	owoIPC.set_predict(db.device_idx, to);
	pos_predict = to;

func set_device_space(to: bool):
	device_space = to;
	update_vectors();

func set_hip_height(to: float):
	hip_height = to;
	update_vectors();


var alive_check: float = 0.0;
func _process(_d: float) -> void:
	alive_check += _d;
	
	if(alive_check > 0.5 && (port_no > 0)):
		var is_alive = yield(owoIPC.is_alive(db.device_idx), "completed");
		db.alive = is_alive == true;


var port_no: int = -1;

func update_connection_info() -> void:
	if(port_no == -1):
		print("no");
		return;
	
	var info = "Port is " + str(port_no) + ". ";
	
	var output = [];
	OS.execute("ipconfig", [], true, output);
	var IPs = [];
	for data in output:
		for line in data.split("\n"):
			if("IPv4" in line):
				IPs.append(line.split(" : ")[1]);
	
	info += "IP is probably one of: " + var2str(IPs);
	
	db.cnxninfo = info;
	print(db.cnxninfo);


func initialize() -> void:
	db.alive = false;
	update_connection_info();

func tracker_added(idx: int, port: int) -> void:
	prints("Tracker aded",idx,port)
	if(idx != db.device_idx):
		return;
	port_no = port;
	print("aaa");
	update_connection_info();
	
	update_vectors();

func recalibrate() -> void:
	calibrator.calibrating_mode = 1;

func make_connections() -> void:
	owoIPC.connect("tracker_added", self, "tracker_added");
	recal.connect("pressed", self, "recalibrate");

func _ready() -> void:
	make_connections();
	initialize();
