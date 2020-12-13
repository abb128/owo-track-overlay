extends Node

# this is a real mess sorry

onready var persistence = preload("res://src/persistence.gd").new();
onready var warning_player = preload("res://src/warning_player.gd").new();
onready var owoIPC: OwoIPC = get_node("/root/owoIPCSingleton");

export var owo_device_id: int = 0;

func set_predict(to: bool) -> void:
	owoIPC.set_predict(owo_device_id, to);

func set_calibrate(b: bool):
	owoIPC.set_calibrating(owo_device_id, b);

var waiter = 0;
var initialized = false;
var time: float = 0.0;

func _process(delta: float) -> void:
	if(!initialized):
		waiter += 1;
		if(waiter > 4):
			initialized = true;
			ready();
	
	if(!datablock.tracker_found):
		waiter += 1;
		if(waiter > 16):
			ready(); # recheck
			waiter = 0;
		return;
	
	time += delta;
	if(time > 1.0):
		time = 0.0;
		var is_alive_now: bool = yield(owoIPC.is_alive(owo_device_id), "completed");
		if(!is_alive_now && datablock.is_alive):
			warning_player.warn();
		
		datablock.is_alive = is_alive_now;

func complete_calibration() -> void:
	datablock.is_calibrated = true;
	set_calibrate(false);
	
	var yaw: float = yield(owoIPC.get_yaw(owo_device_id), "completed");
	persistence.save_calibration_to_file(yaw);



var install_check_tries: int = 0;

func ready():
	if((!datablock.is_installed) && (install_check_tries < 5)):
		datablock.is_installed = is_driver_installed();
		install_check_tries += 1;
	
	
	
	set_calibrate(false);
	datablock.shouldPredict = yield(owoIPC.get_predict(owo_device_id), "completed");
	
	var calibration_val: float = persistence.get_calibration_from_file();
	if(calibration_val != 0.0):
		owoIPC.set_yaw(owo_device_id, calibration_val);
		datablock.is_calibrated = true;


func populate_ip_info():
	
	
	datablock.connection = "Port 6969 (UDP). Local IP is probably one of: ";
	



func add_children():
	add_child(persistence);
	add_child(warning_player);
	add_child(owoIPC);

func _ready():
	add_children();
	make_connections();
	populate_ip_info();
	
	
