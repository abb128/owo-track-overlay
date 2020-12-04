extends Node
class_name GDMLSignalConnector

export var from: String;

export var to: NodePath;
var to_actual: Node;

export var fun: String;

export var override_args: bool = false;

export var binds: Array = [];

# connect
func do_connect():
	var par: Node = get_parent();
	var par_c := par.get_class();
	to_actual = get_node(to);
	
	if(!ClassDB.class_has_signal(par_c, from)):
		printerr("Class %s has no signal %s??" % [par_c, from]);
		return;
	
	if(!override_args):
		par.connect(from, to_actual, fun, binds, 2);
	else:
		var sig = ClassDB.class_get_signal(par_c, from);
		var num_args: int = sig.get("args").size();
		if(num_args < 6):
			get_parent().connect(from, self, "passthrough_%d" % num_args,
					[], 2);
		else:
			printerr("Too many args " + var2str(self));

# hacky workaround
func passthrough_0():
	get_node(to).callv(fun, binds);

func passthrough_1(a):
	passthrough_0();
func passthrough_2(a, b):
	passthrough_0();
func passthrough_3(a, b, c):
	passthrough_0();
func passthrough_4(a, b, c, d):
	passthrough_0();
func passthrough_5(a, b, c, d, e):
	passthrough_0();
