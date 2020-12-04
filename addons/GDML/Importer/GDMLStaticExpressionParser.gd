extends Reference
class_name GDMLStaticExpressionParser

var ex: Expression;
func _init() -> void:
	ex = Expression.new();

func parse(s: String, node: Node):
	if(s.length() < 1):
		return "";
	
	if((s[0] != "@") || (s[1] != "{") || !s.ends_with("}")):
		return s;
	
	s = s.substr(2, s.length()-3);
	
	var err = ex.parse(s);
	if(err != OK):
		printerr("Failed parsing expression `%s`: %s" % [
			s, ex.get_error_text()]);
		return;
	
	var exec = ex.execute([], node);
	if(ex.has_execute_failed()):
		printerr("Failed executing expression `%s`: %s" % [
			s, ex.get_error_text()]);
		
		return;
	
	return exec;
