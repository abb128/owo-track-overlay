tool
extends Node
class_name GDMLReactiveDatablock

export var __nodeDependencies: Dictionary;
export var __reactive_props: Dictionary;

func update_all() -> void:
	# print("Update all ", name);
	for key in __reactive_props.keys():
		update_dependencies(key);

func _ready() -> void:
	update_all();


func force_set(property: String, value) -> void:
	# prints("Force Set","("+name+")",property,value);
	__reactive_props[property] = value;
	update_dependencies(property);

func update_dependencies(prop_n: String) -> void:
	if(!__nodeDependencies.has(prop_n)):
		return;
	
	for prop in __nodeDependencies[prop_n]:
		if(prop == null):
			continue;
		
		get_node(prop).execute();

		# prints("update",prop_n,prop,"new",__reactive_props[prop_n]);


var watcher_mode: bool = false;
var prop_watching;

func _init() -> void:
	pass;

func _get(property: String):
	if(__reactive_props.has(property)):
		if(watcher_mode):
			if(!__nodeDependencies.has(property)):
				__nodeDependencies[property] = [];
			
			var path: NodePath = get_path_to(prop_watching);
			if(path in __nodeDependencies[property]):
				return;
			
			__nodeDependencies[property].append(path);
			
			# prints("Watch mode: %s append %s" % [property, var2str(__nodeDependencies[property])]);
		return __reactive_props[property];
	return null;

var currently_working: Dictionary = {};
func _force_set_base_class_parameter_if_exists(property: String, value):
	currently_working[property] = true;
	set(property, value);
	currently_working.erase(property);


func _set(property: String, value) -> bool:
	# prints("set",property);
	if(currently_working.has(property)):
		return false;
	if(__reactive_props.has(property)):
		# print("_set called!!! " + var2str(property));
		__reactive_props[property] = value;
		_force_set_base_class_parameter_if_exists(property, value);
		update_dependencies(property);

		return true;
	return false;

# required for signal-connector
func set_inverse(value, property: String) -> void:
	set(property, value);
