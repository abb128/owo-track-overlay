tool
extends EditorPlugin

var import_plugin: ImportGDMLPlugin;
var manager: GDMLDependencyManager;


func _enter_tree():
	manager = GDMLDependencyManager.new();
	import_plugin = ImportGDMLPlugin.new(manager);
	add_import_plugin(import_plugin)


func _exit_tree():
	remove_import_plugin(import_plugin)
	import_plugin = null
