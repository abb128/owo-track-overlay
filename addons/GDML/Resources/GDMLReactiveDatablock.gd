tool
extends Node
class_name GDMLReactiveDatablock

signal value_changed(k, v);

signal bound_value_changed(v);
export var bound_value: String;

export var __nodeDependencies: Dictionary;
export var __reactive_props: Dictionary;

func update_all() -> void:
	# print("Update all ", name);
	for key in __reactive_props.keys():
		update_dependencies(key);

func _ready() -> void:
	update_all();


var reserved_keywords = ["bound_value"];
func fill_reserved_keywords_if_empty() -> void:
	if(reserved_keywords.size() > 0):
		return;
	
	var property_list = ClassDB.class_get_property_list(get_class());
	for v in property_list:
		reserved_keywords.append(v["name"].to_lower());

func force_set(property: String, value) -> void:
	fill_reserved_keywords_if_empty();
	
	if(property in reserved_keywords):
		print("SKIP PROPERTY ",property);
		set(property, value);
		return;
	
	__reactive_props[property] = value;
	update_dependencies(property);

func update_dependencies(prop_n: String) -> void:
	if(prop_n == bound_value):
		emit_signal("bound_value_changed", __reactive_props[prop_n]);
	emit_signal("value_changed", prop_n, __reactive_props[prop_n]);
	
	if(!__nodeDependencies.has(prop_n)):
		return;
	
	for prop in __nodeDependencies[prop_n]:
		if(prop == null):
			continue;
		
		get_node(prop).execute();


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
	if(property == "bound_value"):
		bound_value = value;
	
	fill_reserved_keywords_if_empty();
	if(property in reserved_keywords):
		return false;
	# prints("set",property);
	if(currently_working.has(property)):
		return false;
	if(__reactive_props.has(property)):
		# print("_set called!!! " + var2str(property));
		if((typeof(__reactive_props[property]) == typeof(value))
				&& (__reactive_props[property] == value)):
			return true;
		
		__reactive_props[property] = value;
		_force_set_base_class_parameter_if_exists(property, value);
		update_dependencies(property);

		return true;
	return false;

# required for signal-connector
func set_inverse(value, property: String) -> void:
	set(property, value);
