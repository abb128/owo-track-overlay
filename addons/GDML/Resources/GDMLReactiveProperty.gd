tool
extends Node
class_name GDMLReactiveProperty

export var node: NodePath;
export var property_name: String;
export var expression_str: String;
export(Array, NodePath) var values: Array;
export var names: PoolStringArray;

var values_private;

var expression: Expression;

var has_parsed: bool = false;

func _init() -> void:
	expression = Expression.new();


func _set_all(node_v: Node, pname: String, ex: String) -> void:
	node = get_path_to(node_v);
	property_name = pname;
	
	expression_str = ex.substr(2, ex.length()-3);

func parse() -> void:
	var err = expression.parse(expression_str, names);
	if(err != OK):
		printerr("Failed parsing `%s`: %s", expression_str,
				expression.get_error_text());
		return;
	has_parsed = true;

func add_values(nams: PoolStringArray, val: Array) -> void:
	values = [];
	names = PoolStringArray();
	
	for i in range(nams.size()):
		var name_ := nams[i];
		if(
			(name_ in expression_str)
			&& StringUtils.word_boundary(expression_str, name_) != null):
				names.append(nams[i]);
				values.append(get_path_to(val[i]));

func gen_values_private() -> void:
	values_private = [];
	for path in values:
		values_private.append(get_node(path));

func set_result(node: Node, result) -> void:
	# avoid setting if its already the same
	if(
		(typeof(node.get(property_name)) == typeof(result))
		&& (node.get(property_name) == result)):
		return;
	
	node.set(property_name, result);

func execute() -> void:
	if(!has_parsed):
		parse();
	if(!has_parsed):
		printerr("Parsing failed for some reason");
		return;
	if(values_private == null):
		gen_values_private();
	
	var result = expression.execute(values_private, get_node(node));
	if(expression.has_execute_failed()):
		printerr("Failed executing `%s`: %s" % [expression_str,
				expression.get_error_text()]);
		return;
	
	set_result(get_node(node), result);
