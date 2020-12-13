extends Button

export var TRANSITION_SPEED: float;

export var normal_style: StyleBoxFlat;
export var pressed_style: StyleBoxFlat;
export var hovering_style: StyleBoxFlat;

var is_focused := false setget focused_m;
var is_hovering := false setget mouse_move_m;
var is_pressed := false setget pressed_m;


var tgt_pressed_weight: float = 0.0;
var tgt_hovering_weight: float = 0.0;

func _visibility_changed() -> void:
	is_focused = false;
	is_hovering = false;
	is_pressed = false;
	update_values();

func update_values() -> void:
	tgt_pressed_weight = 1.0 if is_pressed else 0.0;
	tgt_hovering_weight = 1.0 if is_hovering else 0.0;
	set_process(true);

func focused_m(b: bool) -> void:
	is_focused = b;
	update_values();

func mouse_move_m(b: bool) -> void:
	is_hovering = b;
	update_values();

func pressed_m(b: bool) -> void:
	is_pressed = b;
	update_values();

func _ready() -> void:
	connect("mouse_entered", self, "mouse_move_m", [true]);
	connect("mouse_exited", self, "mouse_move_m", [false]);
	connect("focus_entered", self, "focused_m", [true]);
	connect("focus_exited", self, "focused_m", [false]);
	connect("button_down", self, "pressed_m", [true]);
	connect("button_up", self, "pressed_m", [false]);
	
	connect("visibility_changed", self, "_visibility_changed");


var custom_style: StyleBoxFlat;

var pressed_weight: float = 0.0;
var hovering_weight: float = 0.0;


func set_lerp_value(key: String) -> void:
	custom_style.set(key,
		normal_style.get(key).linear_interpolate(
			hovering_style.get(key), hovering_weight
		).linear_interpolate(
			pressed_style.get(key), pressed_weight
		)
	);

func set_lerp_value_real(key: String) -> void:
	custom_style.set(key,
		lerp(
			lerp(
				normal_style.get(key), hovering_style.get(key),
				hovering_weight
			),
			pressed_style.get(key), pressed_weight
		)
	);


func _process(delta: float) -> void:
	pressed_weight = lerp(pressed_weight, tgt_pressed_weight, delta * TRANSITION_SPEED);
	hovering_weight = lerp(hovering_weight, tgt_hovering_weight, delta * TRANSITION_SPEED);
	
	if((pressed_weight > 0.01) || (hovering_weight > 0.01)):
		if(custom_style == null):
			custom_style = normal_style.duplicate();
			add_stylebox_override("disabled", custom_style);
			add_stylebox_override("pressed", custom_style);
			add_stylebox_override("normal", custom_style);
			add_stylebox_override("hover", custom_style);
			add_stylebox_override("focus", custom_style);
		
		set_lerp_value("bg_color");
		set_lerp_value("shadow_color");
		set_lerp_value("shadow_offset");
		set_lerp_value_real("shadow_size");
	else:
		if(custom_style != null):
			add_stylebox_override("disabled", normal_style);
			add_stylebox_override("pressed", normal_style);
			add_stylebox_override("normal", normal_style);
			add_stylebox_override("hover", normal_style);
			add_stylebox_override("focus", normal_style);
			custom_style = null;
	
	if(is_equal_approx(pressed_weight, tgt_pressed_weight) && 
		is_equal_approx(hovering_weight, tgt_hovering_weight)):
			
		set_process(false);
