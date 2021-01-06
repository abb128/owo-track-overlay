#pragma once

#include "openvr.h"
#include <Godot.hpp>
#include <Viewport.hpp>

using namespace godot;

namespace godot {
	class LineEdit;
}

class OpenVROverlay : public Viewport {
	GODOT_CLASS(OpenVROverlay, Viewport);
public:
	OpenVROverlay();

	static void _register_methods();
	void _init();
	void _ready();
	void _exit_tree();
	void _process(const real_t delta);

	void Init();
	void Shutdown();

	void set_width(real_t v);
	real_t get_width() const;

	void set_UV_bounds(Rect2 v);
	Rect2 get_UV_bounds() const;

	void show_keyboard(Node *tgt);
	void hide_keyboard_if_still_showing(Node *tgt);

	void refresh_screen();

private:
	bool ConnectToVRRuntime();
	void DisconnectFromVRRuntime();

	void consume_input();
	void perform_scroll(const uint64_t& idx, const real_t& amount);
	vr::TrackedDevicePose_t m_rTrackedDevicePose[vr::k_unMaxTrackedDeviceCount];
	String m_strVRDriver;
	String m_strVRDisplay;

	vr::HmdError m_eLastHmdError;

	Node *current_keyboard_target;

	Vector2 last_mouse_position;
	bool is_mouse_button_pressed[10];

private:
	vr::HmdError m_eCompositorError;
	vr::HmdError m_eOverlayError;
	vr::VROverlayHandle_t m_ulOverlayHandle;
	vr::VROverlayHandle_t m_ulOverlayThumbnailHandle;

	bool has_initialized = false;

	float scroll_accumulator = 0.0;
};
