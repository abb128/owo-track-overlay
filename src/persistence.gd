extends Node

func get_data_from_file(fname: String):
	var file := File.new();
	var err = file.open("user://" + fname + ".txt", File.READ);
	if(err):
		return null;
	var content = str2var(file.get_as_text());
	file.close();
	return content;

func save_data_to_file(fname: String, data) -> void:
	var file := File.new();
	file.open("user://" + fname + ".txt", File.WRITE);
	file.store_string(var2str(data));
	file.close();







# helpers for easier 

func get_yaw_calibration_from_file() -> float:
	var yaw = get_data_from_file("yaw");
	if((yaw == null) || (typeof(yaw) != TYPE_REAL)):
		return 0.0;
	
	return yaw;
func save_yaw_calibration_to_file(yaw: float) -> void:
	save_data_to_file("yaw", yaw);



# settings
func save_datablock_settings(db: GDMLReactiveDatablock, fname: String) -> void:
	var props = db.__reactive_props;
	save_data_to_file(fname, props);

func load_datablock_settings(db: GDMLReactiveDatablock, fname: String) -> void:
	var data = get_data_from_file(fname);
	if(data is Dictionary):
		for key in data.keys():
			if(db.__reactive_props.has(key)):
				db.__reactive_props[key] = data[key];
