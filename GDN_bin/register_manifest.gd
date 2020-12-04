extends Node


var interface: OpenVRInterface;
var time: float = 0;
func _process(delta: float) -> void:
	if(time < 1.0):
		time += delta;
		return;
	
	
	var manifest_path = OS.get_executable_path().get_base_dir() + "\\" + "manifest.vrmanifest";
	interface = OpenVRInterface.new();
	if(interface.is_initialized()):
		if(!interface.is_installed(key)):
			interface.add_manifest(manifest_path, false);
			interface.set_auto_launch(key, true);
		
		set_process(false);
	else:
		time = 0.0;
