extends Node

func get_calibration_from_file() -> float:
	var file := File.new();
	var err = file.open("user://yaw.txt", File.READ);
	if(err):
		return 0.0;
	var content = str2var(file.get_as_text());
	file.close();
	if(typeof(content) != TYPE_REAL):
		return 0.0;
	
	prints("Loaded yaw",content,"from file");
	return content;


func save_calibration_to_file(yaw: float) -> void:
	var file := File.new();
	file.open("user://yaw.txt", File.WRITE);
	file.store_string(var2str(yaw));
	file.close();
