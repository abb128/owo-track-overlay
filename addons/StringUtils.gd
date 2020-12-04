extends Object
class_name StringUtils


static func get_string_between(a: String, open: String, close: String) \
	-> String:
	
	return a.split(open, true, 1)[1].split(close, true, 1)[0];


static func byte_is_alphanumeric(byte: int) -> bool:
	return (
		(byte >= 48) && (byte <= 57) || # is a number
		(byte >= 65) && (byte <= 90) || # is uppercase letter
		(byte >= 97) && (byte <= 122)   # is lowercase letter
	);

# String if eliminate_nonalphanumeric
# else bool (true if contains non alphanumeric chars)
static func nonalphanumeric_check(eliminate_nonalphanumeric: bool, txt: String):
	var all_bytes := txt.to_ascii();
	
	for byte in all_bytes:
		if(!byte_is_alphanumeric(byte)):
			if(eliminate_nonalphanumeric):
				txt = txt.replace(
					PoolByteArray([byte]).get_string_from_ascii(),
					""
				);
			else:
				return true;
	
	if(eliminate_nonalphanumeric):
		return txt;
	else:
		return false;

static func reverse_string(s: String) -> String:
	var new := "";
	var length: int = s.length();
	for i in range(length):
		new += s[length-i-1];
	
	return new;

static func concat_string_array(arr: Array, delim: String) -> String:
	var final = "";
	var size = arr.size();
	for i in range(size):
		final = final + arr[i];
		if((i+1) < size):
			final = final + delim;
	
	return final;

static func plural_fmt(n: int) -> String:
	return "s" if n != 1 else "";

static func escape_single(string: String, ptn: String) -> String:
	return string.replace(ptn, "\\" + ptn);

static func escape_for_regex(string: String) -> String:
	return escape_single(escape_single(escape_single(string, "("), ")"), ".");

# null if not found
# Array [int start, int end] if found
static func word_boundary(string: String, word: String):
	var regex := RegEx.new();
	word = escape_for_regex(word);
	if(word[0] == "\\" && word[1] == "." && word[word.length()-1] == "."):
		regex.compile("%s" % word);
	elif(word[word.length() - 1] == "("):
		regex.compile("\\b%s" % word);
	else:
		regex.compile("\\b%s\\b" % word);
	
	var result = regex.search(string);
	
	if(result == null):
		return null;
	elif((result.get_start() > string.length()) ||
			(result.get_end() > string.length())):
		
		return null;
	else:
		return [result.get_start(), result.get_end()];


static func split_and_strip(string: String, split: String) -> Array:
	var results := string.split(split);
	var results_stripped: Array = [];
	for result in results:
		results_stripped.append(result.strip_edges());
	
	return results_stripped;


# asdadasd asd(123(), 456) bsadsa
#             ^          ^
# -1 if not found
static func find_closing_parentheses(string: String, start_idx: int) -> int:
	start_idx = string.find("(", start_idx-1);
	
	var parentheses_counter := 0;
	
	var idx_of_ending_parenth := -1;
	
	for i in range(string.length() - start_idx):
		var idx: int = i + start_idx;
		var chr := string[idx];
		if(chr == "("):
			parentheses_counter += 1;
		if(chr == ")"):
			parentheses_counter -= 1;
		if(parentheses_counter == 0):
			idx_of_ending_parenth = idx;
			break;
	
	return idx_of_ending_parenth;

# hello(abc, hello(2, 3))
#       ^^^  ^^^^^^^^^^^^
#        1        2
static func split_by_commas_at_current_p_level(string: String, start_idx: int) \
	-> Array:
	
	start_idx = string.find("(", start_idx-1);
	
	var parentheses_counter := 0;
	
	var idx_of_ending_parenth := -1;
	
	var breaks := [];
	
	for i in range(string.length() - start_idx):
		var idx: int = i + start_idx;
		var chr := string[idx];
		if(chr == "("):
			parentheses_counter += 1;
		if(chr == ")"):
			parentheses_counter -= 1;
		if((chr == ",") && (parentheses_counter == 1)):
			breaks.append(idx);
		if(parentheses_counter == 0):
			idx_of_ending_parenth = idx;
			break;
	
	if(breaks.size() == 0):
		return [string.substr(start_idx+1, idx_of_ending_parenth-start_idx-1)];
	
	var result := [];
	for i in range(breaks.size()+1):
		var starting_idx: int;
		var ending_idx: int;
		if(i == 0):
			starting_idx = start_idx+1;
			ending_idx = breaks[i];
		elif(i == breaks.size()):
			starting_idx = breaks[i-1]+1;
			ending_idx = idx_of_ending_parenth;
		else:
			starting_idx = breaks[i-1]+1;
			ending_idx = breaks[i];
		
		result.append(
			string.substr(starting_idx, ending_idx-starting_idx).strip_edges());
	
	return result;

const STACK_LIMIT = 256;

# replaces all words `a` with `b`
static func replace_all_words(string: String, a: String, b: String) -> String:
	var n_times: int = 0;
	while(a in string):
		var bnds = word_boundary(string, a);
		if(bnds == null):
			break;
		
		string = string.substr(0, bnds[0]) + b + string.substr(bnds[1]);
		n_times += 1;
		
		if(n_times > STACK_LIMIT):
			printerr("recursive limit reached!");
			return "";
	
	return string;

# replaces all words `a(...)`
static func replace_func_words(
	string: String, # string containing `a(...)`
	f_name: String, # `a`
	f_params: Array, # `["b", "c"]`
	evaluates_to: String
) -> String:
	var n_times := 0;
	while(f_name in string):
		var bnds = word_boundary(string, f_name + "(");
		if(bnds == null):
			break;
		
		bnds[1] -= 1;
		
		if(string[bnds[1]] != "("):
			# this is not a macro...
			print("not macro");
			return string;
		
		var starting_parentheses: int = bnds[1];
		
		var idx_of_ending_parenth := find_closing_parentheses(string, \
			starting_parentheses);
		
		if(idx_of_ending_parenth == -1):
			printerr("Could not find closing parentheses for %s" % f_name);
			return "";
		
		var curr_params_str := string.substr(bnds[1]+1,
			idx_of_ending_parenth-bnds[1]-1);
		
		var curr_params := split_by_commas_at_current_p_level(
			string, bnds[1]
		);
		# a(48, 96)
		# curr_params := ["48", "96"]
		
		var has_ellipsoids: bool = ("..." in f_params) || ("...." in f_params);
		
		if((f_params.size() != curr_params.size()) && !has_ellipsoids):
			printerr("%s: expects %s arguments, got %s" \
					% [f_name, str(f_params.size()), var2str(curr_params)]);
			return "";
		
		var final_evaluation := evaluates_to;
		var curr_param_idx: int = 0;
		for i in range(f_params.size()):
			var next_param_idx := curr_param_idx + 1;
			var concat_str := "";
			
			if(f_params[i] == "..."):
				concat_str = " ";
				next_param_idx = curr_params.size() + (1 - f_params.size()) + 1;
			elif(f_params[i] == "...."):
				concat_str = ",";
				next_param_idx = curr_params.size() + (1 - f_params.size()) + 1;
			
			final_evaluation = \
				replace_all_words(
					final_evaluation,
					f_params[i],
					concat_string_array(
						curr_params.slice(curr_param_idx, next_param_idx-1),
						concat_str)
				);
			
			curr_param_idx = next_param_idx;
		
		string = string.substr(0, bnds[0]) + final_evaluation \
				+ string.substr(idx_of_ending_parenth+1);
		n_times += 1;
		
		if(n_times > STACK_LIMIT):
			printerr("recursive limit reached!");
			return "";
	return string;

## password helpers
static func count_numbers_or_letters(s: String, numbers_mode: bool) -> int:
	var count: int = 0;
	for c in s:
		if(c.is_valid_integer() == numbers_mode):
			count += 1;
	
	return count;
static func count_unique_characters(s: String) -> int:
	var char_histogram: Dictionary = {};
	var ascii_bytes = s.to_ascii();
	for byte in ascii_bytes:
		char_histogram[byte] = char_histogram.get(byte, 0) + 1;
	
	return char_histogram.keys().size();
static func keymash_probability(s: String) -> float:
	var prev_byte: int;
	var curr_byte: int;
	
	var prev_char: String;
	var curr_char: String;
	
	var current_streak_sum: int = 0;
	
	var kbdist: float;
	
	var ascii_bytes := s.to_ascii();
	
	for i in range(ascii_bytes.size()):
		if(i == 0):
			continue
		
		prev_byte = ascii_bytes[i-1];
		curr_byte = ascii_bytes[i];
		
		prev_char = s[i-1];
		curr_char = s[i];
		
		kbdist = calculate_kb_dist_between_letters(
			prev_char, curr_char);
		
		if((abs(curr_byte - prev_byte) < 2) || (kbdist < 3.0)):
			current_streak_sum += 2;
		else:
			current_streak_sum -= 1;
	
	return (current_streak_sum*0.5) / (s.length()*1.0);

const QWERTY_Keyboard := [
	[	"`1234567890-=",
		"qwertyuiop[]\\",
		"asdfghjkl;'",
		"zxcvbnm,./"],
	
	[	"~!@#$%^&*()_+",
		"QWERTYUIOP{}|",
		"ASDFGHJKL:\"",
		"ZXCVBNM<>?"]
];

# X: x position
# Y: y position
# Z: 0 lowercase, 1 uppercase
static func find_position_in_kb_array(letter: String, kb_a: Array) -> Vector3:
	var idx_of: int = -1;
	for z in range(kb_a.size()):
		for y in range(kb_a[z].size()):
			idx_of = kb_a[z][y].find(letter);
			if(idx_of != -1):
				return Vector3(idx_of, y, z);
	
	return Vector3(99999, 99999, 99999);

static func calculate_kb_dist_between_letters(a: String, b: String) -> float:
	var pos_a: Vector3 = find_position_in_kb_array(a, QWERTY_Keyboard);
	var pos_b: Vector3 = find_position_in_kb_array(b, QWERTY_Keyboard);
	
	return (pos_a - pos_b).length();
