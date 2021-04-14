extends Node

export var db_path: NodePath;
onready var db = get_node(db_path);

export var calibrator_path: NodePath;
onready var calibrator = get_node(calibrator_path);

export var recal_btn: NodePath;
onready var recal: Button = get_node(recal_btn).get_child(0);

export var recal_btn_down: NodePath;
onready var recal_down: Button = get_node(recal_btn_down).get_child(0);

export var settings_path: NodePath;
onready var settings = get_node(settings_path);

onready var owoIPC: OwoIPC = get_node("/root/owoIPCSingleton");



var alive_check: float = 0.0;
func _process(_d: float) -> void:
	alive_check += _d;
	
	if(alive_check > 0.5 && (port_no > 0)):
		var is_alive = yield(owoIPC.is_alive(db.device_idx), "completed");
		db.alive = is_alive == true;
		settings.alive = db.alive;
		alive_check = 0;


var port_no: int = -1;

func update_connection_info() -> void:
	if(port_no == -1):
		#print("no");
		return;
	
	var info = "Port is " + str(port_no) + ". ";
	
	var output = [];
	OS.execute("ipconfig", [], true, output);
	var IPs = [];
	for data in output:
		for line in data.split("\n"):
			if("IPv4" in line):
				IPs.append(line.split(" : ")[1]);
	
	if(IPs.size() > 0):
		info += "IP is probably one of: " + var2str(IPs);
	else:
		info += "Unable to find your local IP address, please use automatic discovery or manually find it using `ipconfig`. ";
	
	db.cnxninfo = info;


func initialize() -> void:
	db.alive = false;
	update_connection_info();

func tracker_added(idx: int, port: int) -> void:
	if(idx != db.device_idx):
		return;
	port_no = port;
	update_connection_info();

func recalibrate() -> void:
	calibrator.calibrating_mode = 1;

func recalibrate_down() -> void:
	calibrator.calibrating_mode = 3;

func make_connections() -> void:
	owoIPC.connect("tracker_added", self, "tracker_added");
	recal.connect("pressed", self, "recalibrate");
	recal_down.connect("pressed", self, "recalibrate_down");

func _ready() -> void:
	make_connections();
	initialize();
