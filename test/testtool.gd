tool
extends EditorScript

var small: bool;
var expression: Expression;
const command := "lerp(10, 20, int(small))";

func exec():
	var result = expression.execute([], self, true);
	if not expression.has_execute_failed():
		return result;
	
	printerr(expression.get_error_text());

func _run():
	expression = Expression.new();
	var error = expression.parse(command, []);
	if error != OK:
		printerr(expression.get_error_text());
		return;
	
	small = false;
	prints(exec(), "should be 10");
	small = true;
	prints(exec(), "should be 20");
