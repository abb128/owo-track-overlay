#pragma once

#include <Node.hpp>
#include <LineEdit.hpp>
#include <TextEdit.hpp>

using namespace godot;

inline bool is_multiline(Node* w) {
	auto line = Object::cast_to<LineEdit>(w);
	if (line) {
		return false;
	}

	auto textedit = Object::cast_to<TextEdit>(w);
	if (textedit) {
		return true;
	}
}

inline void set_text_to(Node* w, String to) {
	if (w->has_signal("text_changed"))
		w->emit_signal("text_changed", to);

	auto line = Object::cast_to<LineEdit>(w);
	if (line) {
		return line->set_text(to);
	}

	auto textedit = Object::cast_to<TextEdit>(w);
	if (textedit) {
		return textedit->set_text(to);
	}
}


inline String get_text_from(Node* w) {
	auto line = Object::cast_to<LineEdit>(w);
	if (line) {
		return line->get_text();
	}

	auto textedit = Object::cast_to<TextEdit>(w);
	if (textedit) {
		return textedit->get_text();
	}
}

inline uint64_t get_max_len(Node* w) {
	auto line = Object::cast_to<LineEdit>(w);
	if (line) {
		return line->get_max_length();
	}

	auto textedit = Object::cast_to<TextEdit>(w);
	if (textedit) {
		return -1;
	}
}