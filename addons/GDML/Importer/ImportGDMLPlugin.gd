tool
extends EditorImportPlugin
class_name ImportGDMLPlugin

var manager: GDMLDependencyManager;

func _init(m: GDMLDependencyManager) -> void:
	manager = m;


func get_importer_name():
	return "gdml.import"

func get_visible_name():
	return "Godot Markup Language"

func get_recognized_extensions():
	return ["gdml"]

func get_save_extension():
	return "scn"

func get_resource_type():
	return "PackedScene"

func get_preset_count():
	return 1

func get_preset_name(i: int):
	return "Default"

func get_import_options(i: int):
	return [{"name": "CustomDefines", "default_value": {"TEST": "TEST"}}];

func get_option_visibility(option: String, options: Dictionary) -> bool:
	return true;

func import(source_file: String, save_path: String, options: Dictionary,  \
		platform_variants: Array, gen_files: Array) -> int:
	var importer := GDMLLoader.new(options);
	var result = importer.import(source_file);
	
	if(result == null):
		result = Node.new();
	
	var packedscene := PackedScene.new();
	var r = packedscene.pack(result);
	
	return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()],
		packedscene);
