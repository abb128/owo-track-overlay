extends Resource
class_name GDMLPreProcessor

var regex_exp: RegEx;
var const_defines: Dictionary;
var const_funcs: Dictionary;

var non_processed_lines: Array;

var content: String;

static func _erase_comments(content: String) -> String:
	var result := content;
	while("<!--" in result):
		var comment_start := result.split("<!--", true, 1);
		var before_comment := comment_start[0];
		var comment_end := comment_start[1].split("-->", true, 1);
		var after_comment := comment_end[1];
		
		result = before_comment + " " + after_comment;
	
	return result;

func _init(cont: String) -> void:
	self.content = cont;
	self.const_defines = {};
	self.const_funcs = {};
	self.non_processed_lines = cont.split("\n",false);
	self.regex_exp = RegEx.new();
	regex_exp.compile("^#\\s*(?P<command>\\w+)(\\s+(?P<name>[^\\(\\s\\)\\n]+)(\\((?P<params>[^\\)]*)\\))?(\\s+(?P<eval_to>.*))?)?$");

func add_defines_dict(dict: Dictionary):
	for key in dict.keys():
		const_defines[key] = dict[key];

static func _get_file_contents(path: String) -> String:
	var file := File.new();
	var err := file.open(path, File.READ);
	if(err):
		printerr("Failed to open file %s: %d" % [path, err]);
		return "";
	var content := file.get_as_text()
	file.close();
	
	return content;


# returns if anything new found
func scan_preprocess() -> bool:
	var new_found := false;
	var new_lines := [];
	for line in non_processed_lines:
		line = line.strip_edges();
		var result = regex_exp.search(line);
		if(result):
			new_found = true;
			var cmd     = result.get_string("command");
			var _name    = result.get_string("name");
			var params  = result.get_string("params");
			var eval_to = result.get_string("eval_to");
			eval_to = eval_to.replace("%\\n", "\n");
			match cmd:
				"define":
					if(params.length() > 0):
						const_funcs[_name] = [
							StringUtils.split_and_strip(params, ","),
							eval_to
						];
					else:
						const_defines[_name] = eval_to;
				"include":
					var f_name := StringUtils.get_string_between(
						_name, '"', '"'
					);
					var content := _get_file_contents(f_name);
					new_lines += Array(content.split("\n", false));
				var unknown:
					printerr("Unknown preprocessor directive " + unknown);
		else:
			new_lines += Array(line.split("\n", false));
	
	if(self.non_processed_lines.size() != new_lines.size()):
		new_found = true;
	
	self.non_processed_lines = new_lines;
	
	return new_found;

# returns if anything changed
func preprocess_step() -> bool:
	var has_changed: bool = scan_preprocess();
	var new_lines := [];
	for line in non_processed_lines:
		var pline: String = line;
		
		# error formatting
		if(pline == ""):
			continue;
		
		for define in const_defines.keys():
			pline = StringUtils.replace_all_words(pline, define, \
					const_defines[define]);
			
		for define in const_funcs.keys():
			pline = StringUtils.replace_func_words(pline, define, \
					const_funcs[define][0], const_funcs[define][1]);
		
		# find error
		if(pline == ""):
			printerr("Failed processing line: %s" % line);
		
		if(pline.length() > 5000):
			printerr("Reached limit for preprocessor line length!");
			return false;
		
		if(line != pline):
			has_changed = true;
		
		new_lines.append(pline);
	
	self.non_processed_lines = new_lines;
	
	return has_changed;


func convert_to_string():
	var final_str := "";
	for line in non_processed_lines:
		final_str += line  + "\n";
	
	return final_str;
