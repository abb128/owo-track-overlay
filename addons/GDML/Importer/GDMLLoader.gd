extends Reference
class_name GDMLLoader

var settings: Dictionary;

static func _get_file_contents(path: String) -> String:
	var file := File.new();
	var err := file.open(path, File.READ);
	if(err):
		printerr("Failed to open file %s: %d" % [path, err]);
		return "";
	var content := file.get_as_text()
	file.close();
	
	return content;


func import(path: String):
	var content := _get_file_contents(path);
	content = GDMLPreProcessor._erase_comments(content);
	

	var preprocessor := GDMLPreProcessor.new(content);
	preprocessor.add_defines_dict(settings["CustomDefines"]);
	
	for i in range(8):
		if(!preprocessor.preprocess_step()):
			break;
	
	content = preprocessor.convert_to_string();
	
	
	prints("Compiling", path);
	var compiler := GDMLCompiler.new(content);
	if(compiler.compile() != OK):
		printerr("Error in compilation");
		return null;
	
	return compiler.main_node;


func _init(settings_v: Dictionary) -> void:
	self.settings = settings_v;
