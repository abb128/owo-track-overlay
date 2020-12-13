# OpenVR dashboard overlay keyboard support for LineEdit and TextEdit

extends Control


func focus_entered_m() -> void:
	get_viewport().show_keyboard(self);

func focus_exited_m() -> void:
	get_viewport().hide_keyboard_if_still_showing(self);

func _exit_tree() -> void:
	get_viewport().hide_keyboard_if_still_showing(self);

func text_changed_m2() -> void:
	var obj: Node = get_node(".");
	if(obj.is_class("LineEdit")):
		obj.caret_position = obj.text.length();


func text_changed_m(a) -> void:
	call_deferred("text_changed_m2");

func _ready() -> void:
	connect("focus_entered", self, "focus_entered_m");
	connect("focus_exited", self, "focus_exited_m");
	connect("text_changed", self, "text_changed_m");
