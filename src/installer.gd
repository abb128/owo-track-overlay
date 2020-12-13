extends Node

export var db_path: NodePath;
onready var db: GDMLReactiveDatablock = get_node(db_path);

func get_runtime_path(extra_path: String) -> String:
	var OVRInterface = OpenVRInterface.new();
	return OVRInterface.get_runtime_path() + extra_path;

func get_driver_path() -> String:
	return OS.get_executable_path().get_base_dir() + "\\driver";

func get_runtime_exe_path(exe: String) -> String:
	var win64_dir = get_runtime_path("\\bin\\win64");
	var dir = Directory.new();
	if(dir.open(win64_dir) != OK):
		db.fatal_error = "Failed! Could not find SteamVR runtime at " + win64_dir + ". Try manual installation.";
		return "";
	
	return win64_dir + "\\" + exe + ".exe";

func is_driver_installed() -> bool:
	var output := [];
	
	var result := OS.execute(get_runtime_exe_path("vrpathreg"),
		[], true, output, true);
	
	var driver_path = get_driver_path();
	
	print(get_runtime_exe_path("vrpathreg"));
	
	print(driver_path);
	print(str(output));
	
	return (driver_path in str(output));

func generic_vrpathreg(command: String) -> void:
	var driver_path := get_driver_path();
	
	var dir := Directory.new();
	if(dir.open(driver_path) != OK):
		db.fatal_error = "Could not open path " + driver_path + "! Ensure that it exists.";
		return;
	
	var output = [];
	var result = OS.execute(get_runtime_exe_path("vrpathreg"),
		[command, driver_path], true, output, true)
	
	if(result == 0):
		db.install_result = var2str([command, output]);
	else:
		db.fatal_error = "Something has went wrong! " + var2str([command, result, output]);
	

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
