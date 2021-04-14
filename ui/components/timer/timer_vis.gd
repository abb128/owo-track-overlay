extends ColorRect


export var disabled: bool setget set_disabled;

var orig_material: ShaderMaterial = preload("res://ui/components/timer/timer_mat.tres");
var copied_material: ShaderMaterial;

onready var txt = get_child(0);

signal ended;

func set_disabled(to: bool) -> void:
	disabled = to;
	var col: float = 0.6 if to else 1.0;
	modulate = Color(1.0, 1.0, 1.0, col);
	set_process(!to);
	
	txt.text = "-";
	
	if(disabled && (copied_material != null)):
		copied_material = null;
		material = orig_material;
	elif((!disabled) && (copied_material == null)):
		copied_material = orig_material.duplicate();
		material = copied_material;

var timing_start: int;
var timing_length: int;
var length_f: float;

func start_timer(length: float) -> void:
	timing_start = OS.get_ticks_msec();
	timing_length = length * 1000.0;
	length_f = length;
	set_disabled(false);

const lim = 0.1;

func _process(delta: float) -> void:
	var time: int = OS.get_ticks_msec();
	if((timing_start + timing_length) <= time):
		set_disabled(true);
		emit_signal("ended");
		return;
	
	var time_passed: int = time - timing_start;
	var time_magnitude: float = float(time_passed) / float(timing_length);
	
	var mvmt = fmod(time_magnitude * length_f, 1.0);
	
	copied_material.set_shader_param("movement", mvmt);
	
	var extra = clamp(mvmt, 1.0 - lim, 1.0) - (1.0 - lim);
	copied_material.set_shader_param("extra", extra / lim);
	
	txt.text = str(1 + (timing_length - time_passed)/1000);
