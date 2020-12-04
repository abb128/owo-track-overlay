extends Reference
class_name GDMLDependencyManager

var _imported_files: Dictionary;

func check_importing_file(path: String):
	var data = _imported_files.get(path, null);
	if(data == null):
		_imported_files[path] = true;
	elif(data == true):
		printerr("Potentical cyclical dependency! " + path);
	return data;

func finish_importing_file(path: String, save_path: String):
	var data = _imported_files.get(path, null);
	if(data != true):
		printerr("wtf? " + path);
		return false;
	
	data[path] = save_path;
