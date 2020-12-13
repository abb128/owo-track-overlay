extends Reference
class_name GDMLCompiler

const NODE_TYPE = 0;
const RESOURCE_TYPE = 1;


var content: String;

var parser: XMLParser;

var static_expression_parser: GDMLStaticExpressionParser;

func _init(content_v: String) -> void:
	self.content = content_v;
	parser = XMLParser.new();
	parser.open_buffer(content_v.to_utf8());
	
	static_expression_parser = GDMLStaticExpressionParser.new();

const RESERVED_KEYS = [
	"script",
	"signal-connector",
	"reactive-data",
	"scene",
	"resource",
	"scene-alias"
];

var future_junctions := [];

var reactive_props := [];
var datablocks := [];
var element_IDs := {}; 

var scene_aliases := {};


const BINDS_LOOKUP = {
	"LineEdit": ["text", "text_changed"],
	"BaseButton": ["pressed", "toggled"],
#	"TextEdit": ["text", "text_changed"], #text_changed() does not have text parameter
	"Range": ["value", "value_changed"]
}
func _bind_element(node: Node, expression: String) -> void:
	var class_tgt := node.get_class();
	if(!BINDS_LOOKUP.has(class_tgt)):
		for key in BINDS_LOOKUP.keys():
			if(ClassDB.is_parent_class(class_tgt, key)):
				class_tgt = key;
				break;
	
	if(!BINDS_LOOKUP.has(class_tgt)):
		printerr("Class " + class_tgt + " is not supported for binding!");
		return;
	
	var data: Array = BINDS_LOOKUP[class_tgt];
	_add_reactive_property(node, data[0], expression);
	
	var connector := GDMLSignalConnector.new();
	connector.from = data[1];
	connector.fun = "set_inverse";
	connector.binds = [expression.split("${", 1)[1].split(".", 1)[1].split("}", 1)[0]];
	connector.override_args = false;
	
	var to_name: String = expression.split("${", 1)[1].split(".", 1)[0];
	_set_node_property(connector, "signal-connector", "to", "#" + to_name);
	
	_add_node_to(connector, node);


func _stp(s: String, n: Node):
	return static_expression_parser.parse(s, n);

func _handle_special_element(cname: String) -> Node:
	match(cname):
		"script":
			return current_node;
		"signal-connector":
			var connector = GDMLSignalConnector.new();
			_add_node(connector);
			return connector
		"reactive-data":
			var block = GDMLReactiveDatablock.new();
			block.name = "ReactiveDataBlock";
			_add_node(block);
			return block;
		"scene":
			var val = parser.get_named_attribute_value_safe("src");
			if(val == null):
				printerr("Scene with no src.. impossible..");
				return null;
			
			val = _stp(val, current_node);
			
			var packedScene: PackedScene = load(val);
			
			var instance: Node = packedScene.instance();
			
			_add_node(instance);
			
			return instance;
		"scene-alias":
			var src = parser.get_named_attribute_value_safe("src");
			var _as = parser.get_named_attribute_value_safe("as");
			if((src == null) || (_as == null)):
				printerr("Improper scene-alias");
				return null;
				
			src = _stp(src, null);
			_as = _stp(_as, null);
			
			var packedScene = 0;
			scene_aliases[_as] = [src, packedScene];

			return null;
		"resource":
			var src = parser.get_named_attribute_value_safe("src");
			if(src == null):
				printerr("Resource with no src...");
				return null;
			src = _stp(src, null);
			
			var id = parser.get_named_attribute_value_safe("id");
			if(id == null):
				printerr("Resource with no ID...");
				return null;
			id = _stp(id, null);
			
			# included files may have tons of resource
			# resort to loding it only upon request
			# var resource = load(src);
			var resource = 0;
			element_IDs[id] = [RESOURCE_TYPE, resource, src];
			return null;
		_:
			printerr("%s is not yet supported" % cname);
			return Node.new();

func _add_control_override(node: Control, nm: String, type: String, val) -> void:
	node.call("add_" + type + "_override", nm, val);

func _add_reactive_property(node: Node, prop: String, val: String) -> void:
	var prop_obj = GDMLReactiveProperty.new();
	prop_obj.name = "ReactiveProperty";
	_add_node_to(prop_obj, node);
	prop_obj._set_all(node, prop, val);
	reactive_props.append(prop_obj);
	if(node is GDMLReactiveDatablock):
		node.force_set(prop, val);
	return;

func _set_node_property(node: Node, cname: String, prop: String, val):
	if(val is String && val.begins_with("#")):
		future_junctions.append([val.substr(1), node, prop, cname]);
		return;
	elif(val is String && val.begins_with("${") && val.ends_with("}") && prop != "g-bind"):
		_add_reactive_property(node, prop, val);
	
	if(cname == "script" && prop == "src"):
		node.set_script(load(val));
	elif(cname == "signal-connector" && prop == "to"):
		node.to = val;
		node.do_connect();
	elif(prop == "g-id"):
		if(node.get_class() in node.name):
			node.name = val;
		if(element_IDs.has(val)):
			printerr("Found more than 1 element with ID %s" % val);
			return;
		element_IDs[val] = [NODE_TYPE, node];
	elif(prop == "g-bind"):
		_bind_element(node, val);
	elif(prop.begins_with("g-override-")):
		var stuff = prop.split("-");
		var override_type = stuff[2];
		var override_name = stuff[3];
		_add_control_override(node, override_name, override_type, val)
	elif(node is GDMLReactiveDatablock):
		node.force_set(prop, val);
	else:
		node.set(prop, val);

func _ensure_name(node: Node) -> void:
	if(node.name.length() < 1):
		node.name = node.get_class();

func _add_node_to(node: Node, par: Node) -> void:
	_ensure_name(node);
	par.add_child(node);
	node.owner = main_node;
	
	if(node is GDMLReactiveDatablock):
		datablocks.append(node);


func _add_node(node: Node) -> void:
	_add_node_to(node, current_node);

var main_node: Node;
var current_node: Node;

func _set_node_attributes(node: Node, cname: String) -> void:
	for i in range(parser.get_attribute_count()):
		var name := parser.get_attribute_name(i);
		var val = parser.get_attribute_value(i);
		val = _stp(val, node);
		
		
		_set_node_property(node, cname, name, val);

func _handle_element(end: bool) -> int:
	var className = parser.get_node_name();
	
	if(className in RESERVED_KEYS):
		var node = _handle_special_element(className);
		if(node != null):
			_set_node_attributes(node, className);
		return 0;
	
	if(!end):
		var node;
		if(scene_aliases.has(className)):
			
			# why??
			#scene_aliases[className][1] = load(scene_aliases[className][0]);
			#assert(scene_aliases[className][1] is PackedScene);
			node = load(scene_aliases[className][0]).instance().duplicate(7);
		else:
			if(!ClassDB.class_exists(className)):
				printerr("Class does not exist %s" % className);
				return 1;
			if(!ClassDB.can_instance(className)):
				printerr("Cant instance %s" % className);
				return 1;
			
			node = ClassDB.instance(className);
		
		if(!node is Node):
			printerr("Class does not inherit Node %s" % className);
			return 1;
		
		if(main_node == null):
			_ensure_name(node);
			main_node = node;
			current_node = node;
			main_node.set_script(GDMLReactiveDatablock);
			datablocks.append(main_node);
		else:
			_add_node(node);
			if(!parser.is_empty()):
				current_node = node;
		
		_set_node_attributes(node, className);
	else:
		if(current_node == main_node):
			prints("Finished scanning!");
			return 0;
		current_node = current_node.get_parent();
		if(current_node == null):
			printerr("what")
			return 1;
	
	return 0;


func _read_loop() -> int:
	match(parser.get_node_type()):
		XMLParser.NODE_NONE:
			printerr("Node 0??");
			return 1;
		XMLParser.NODE_ELEMENT:
			_handle_element(false);
			return 0;
		XMLParser.NODE_ELEMENT_END:
			_handle_element(true);
			return 0;
	
	print(parser.get_node_type());
	
	return 2;



func compile() -> int:
	print("Compiler started");
	while(parser.read() == 0):
		var result := _read_loop();
		if(result != OK):
			printerr("Failed reading");
			return result;
	#prints("### BEFORE", datablocks.size());
	#for block in datablocks:
	#	if(block.__reactive_props.has("text")):
	#		prints("ELE:",block.name, block.text);
	
	_perform_reactive_props();
	_link_junctions();
	
	#prints("### AFTER", datablocks.size());
	#for block in datablocks:
	#	if(block.__reactive_props.has("text")):
	#		prints("ELE:",block.name, block.text);
	
	print("Compiler ended");
	return 0;

var reactive_data_names: PoolStringArray;
var reactive_data_values: Array;

func _set_all_datablocks(is_watching: bool, prop_watching) -> void:
	for datablock in reactive_data_values:
		datablock = datablock as GDMLReactiveDatablock;
		
		datablock.watcher_mode = is_watching;
		datablock.prop_watching = prop_watching;

func _perform_reactive_props() -> void:
	reactive_data_names = PoolStringArray();
	for id in element_IDs.keys():
		if(
			(element_IDs[id][0] == NODE_TYPE) && 
			(element_IDs[id][1] is GDMLReactiveDatablock)
		):
			reactive_data_names.append(id);
			reactive_data_values.append(element_IDs[id][1]);
	
	prints("names:",var2str(reactive_data_names));
	
	for prop in reactive_props:
		prop = prop as GDMLReactiveProperty;
		prop.add_values(reactive_data_names, reactive_data_values);
		
		_set_all_datablocks(true, prop);
		prop.execute();
		_set_all_datablocks(false, null);

func _link_junctions() -> void:
	for junc in future_junctions:
		var id = junc[0];
		var node: Node = junc[1];
		var prop = junc[2];
		
		if(!element_IDs.has(id)):
			printerr("Not found ID: %s" % id);
			continue;
		
		var id_type = element_IDs[id][0];
		if(id_type == NODE_TYPE):
			var tgt_node: Node = element_IDs[id][1];
			_set_node_property(node, junc[3], prop, node.get_path_to(tgt_node));
		elif(id_type == RESOURCE_TYPE):
			if(element_IDs[id][1] is int):
				# load the resource
				element_IDs[id][1] = load(element_IDs[id][2]);
			_set_node_property(node, junc[3], prop, element_IDs[id][1]);
