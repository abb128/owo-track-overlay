extends Node


onready var persistence = preload("res://components/helper_scripts/persistence.gd").new();
onready var warning_player = preload("res://components/helper_scripts/warning_player.gd").new();

export var device_id: int = 1 setget set_id ;
export var data_block: NodePath;
onready var datablock = get_node(data_block);

export var calib_btn: NodePath;
onready var calib = get_node(calib_btn);

export var calib_start_btn: NodePath;
onready var calib_start = get_node(calib_start_btn);

export var timer_path: NodePath;
onready var timer = get_node(timer_path).get_child(0);

export var calib_cancel_path: NodePath;
onready var calib_cancel = get_node(calib_cancel_path).get_child(0);

export var calib_continue_path: NodePath;
onready var calib_continue = get_node(calib_continue_path).get_child(0);

export var install_path: NodePath;
onready var install_btn = get_node(install_path).get_child(0);
export var install_path_1: NodePath;
onready var install_btn_1 = get_node(install_path_1).get_child(0);


export var uninstall_path_1: NodePath;
onready var uninstall_btn_1 = get_node(uninstall_path_1).get_child(0);
export var uninstall_path: NodePath;
onready var uninstall_btn = get_node(uninstall_path).get_child(0);


export var should_predict: bool = false setget set_pred;

var device: TrackedDevice;

func set_pred(to: bool) -> void:
	should_predict = to;
	if(!initialized):
		return;
	set_pos_predict(to);

func set_id(new):
	device_id = new;

func gen_stream() -> StreamPeerBuffer:
	var array = PoolByteArray();
	var stream = StreamPeerBuffer.new();
	stream.big_endian = true;
	stream.data_array = array;
	return stream;

func get_alive() -> bool:
	var stream := gen_stream();
	
	stream.put_8(8);
	stream.put_8(0);
	var data: PoolByteArray = device.send_message(stream.data_array);
	return data[0] == 2;


func get_calibration_yaw() -> float:
	var stream := gen_stream();
	
	stream.put_8(7);
	stream.put_8(0);
	var data: PoolByteArray = device.send_message(stream.data_array);
	var s := data.get_string_from_ascii();
	return s.to_float();

func set_calibration_yaw(yaw: float) -> void:
	var stream := gen_stream();
	
	stream.put_8(6);
	stream.put_data(str(yaw).to_ascii());
	stream.put_8(0);
	var data: PoolByteArray = device.send_message(stream.data_array);

func get_version() -> int:
	var stream := gen_stream();
	
	stream.put_8(5);
	stream.put_8(0);
	var data: PoolByteArray = device.send_message(stream.data_array);
	return data[0];

func get_pos_predict() -> bool:
	var stream := gen_stream();
	
	stream.put_8(4);
	stream.put_8(0);
	var data: PoolByteArray = device.send_message(stream.data_array);
	return data[0] == 2;

func set_pos_predict(predict: bool) -> void:
	var stream := gen_stream();
	
	stream.put_8(3);
	stream.put_8(2 if predict else 1);
	stream.put_8(0);
	var data: PoolByteArray = device.send_message(stream.data_array);
	print(data[0]);



func set_calibrate(i: int):
	datablock.calibrating = i;
	
	var stream := gen_stream();
	
	stream.put_8(1);
	stream.put_8(2 if (datablock.calibrating == 2) else 1);
	stream.put_8(0);
	device.send_message(stream.data_array);

var waiter = 0;
var initialized = false;
var time: float = 0.0;
func _process(delta: float) -> void:
	if(!initialized):
		waiter += 1;
		if(waiter > 4):
			initialized = true;
			ready();
	
	if(!datablock.is_installed):
		waiter += 1;
		if(waiter > 16):
			ready(); # recheck
			waiter = 0;
		return;
	
	time += delta;
	if(time > 1.0):
		time = 0.0;
		var is_alive_now := get_alive();
		
		if(!is_alive_now && datablock.is_alive):
			warning_player.warn();
		
		datablock.is_alive = is_alive_now;

func complete_calibration() -> void:
	datablock.is_calibrated = true;
	set_calibrate(false);
	
	var yaw = get_calibration_yaw();
	persistence.save_calibration_to_file(yaw);

func start_timer() -> void:
	datablock.timer_running = true;
	timer.start_timer(5);
	yield(timer, "ended");
	datablock.timer_running = false;
	complete_calibration();

func get_runtime_path(extra_path: String) -> String:
	var OVRInterface = OpenVRInterface.new();
	return OVRInterface.get_runtime_path() + extra_path;

func generic_vrpathreg(command: String) -> void:
	var driver_path := OS.get_executable_path().get_base_dir() + "\\driver";
	print(driver_path);
	datablock.is_installing = true;
	
	datablock.install_success = true;
	
	var dir := Directory.new();
	if(dir.open(driver_path) != OK):
		datablock.install_success = false;
		datablock.install_result = "Could not open path " + driver_path + "! Ensure that it exists.";
		return;
	
	
	
	var win64_dir = get_runtime_path("\\bin\\win64");
	dir = Directory.new(); #is this needed?
	if(dir.open(win64_dir) != OK):
		datablock.install_success = false;
		datablock.install_result = "Failed! Could not find SteamVR runtime at " + win64_dir + ". Try manual installation.";
		return;
	
	var output = [];
	var result = OS.execute(win64_dir + "\\vrpathreg.exe",
		[command, driver_path], true, output, true)
	
	if(result == 0):
		datablock.install_result = var2str([command, output]);
	else:
		datablock.install_success = false;
		datablock.install_result = "Something has went wrong! " + var2str([command, result, output]);
	

const OpenVRInterface = preload("res://GDN_bin/OpenVRInterface.gdns");
const key = "abb.owoTrackOverlay"

func install_manifest(b: bool) -> void:
	var manifest_path = OS.get_executable_path().get_base_dir() + "\\" + "manifest.vrmanifest";
	var interface := OpenVRInterface.new();
	if(interface.is_initialized()):
		var is_installed: bool = interface.is_installed(key);
		if(is_installed && !b):
			interface.set_auto_launch(key, false);
			interface.remove_manifest(manifest_path);
		elif(!is_installed && b):
			interface.add_manifest(manifest_path, false);
		
		if(b):
			interface.set_auto_launch(key, true);

func install() -> void:
	generic_vrpathreg("adddriver");
	install_manifest(true);

func uninstall() -> void:
	generic_vrpathreg("removedriver");
	install_manifest(false);


func make_connections():
	install_btn.connect("pressed", self, "install");
	uninstall_btn.connect("pressed", self, "uninstall");
	
	install_btn_1.connect("pressed", self, "install");
	uninstall_btn_1.connect("pressed", self, "uninstall");
	
	calib.get_child(0).connect("pressed", self, "set_calibrate", [1]);
	calib_continue.connect("pressed", self, "set_calibrate", [2]);
	calib_cancel.connect("pressed", self, "set_calibrate", [0]);
	calib_start.get_child(0).connect("pressed", self, "start_timer");
	

func ready():
	var found = false;
	device = TrackedDevice.new();
	
	if(!device.is_initialized()):
		datablock.retries += 1;
		return;
	
	for i in range(8):
		device.id = i;
		device_id = i;
		var d_name = device.get_string_property(1002);
		if("VIRT" in d_name):
			found = true;
			break;
	datablock.is_installed = found;
	datablock.finished_loading = true;
	if(!found):
		return;
	set_calibrate(false);
	datablock.shouldPredict = get_pos_predict();
	datablock.device_name = device.get_string_property(1002);
	
	var calibration_val: float = persistence.get_calibration_from_file();
	if(calibration_val != 0.0):
		set_calibration_yaw(calibration_val);
		datablock.is_calibrated = true;


func populate_ip_info():
	var output = [];
	OS.execute("ipconfig", [], true, output);
	
	datablock.connection = "Port 6969 (UDP). Local IP is probably one of: ";
	var IPs = [];
	for data in output:
		for line in data.split("\n"):
			if("IPv4" in line):
				IPs.append(line.split(" : ")[1]);
	
	datablock.connection += var2str(IPs);


func add_children():
	add_child(persistence);
	add_child(warning_player);

func _ready():
	add_children();
	make_connections();
	populate_ip_info();
	
	
