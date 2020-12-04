#include "openvroverlay.h"

#include <ViewportTexture.hpp>
#include <Image.hpp>
#include <PoolArrays.hpp>
#include <VisualServer.hpp>

#include <SceneTree.hpp>

#include <InputEvent.hpp>
#include <InputEventMouse.hpp>
#include <InputEventMouseMotion.hpp>
#include <InputEventMouseButton.hpp>

#include <VisualServer.hpp>

#include "texthelper.h"

#define CHEQUE(WTF) if (overlayError != vr::VROverlayError_None) Godot::print("OverlayError Failed to " #WTF ", error " + String::num_int64(overlayError));

String GetTrackedDeviceString(vr::IVRSystem* pHmd, vr::TrackedDeviceIndex_t unDevice, vr::TrackedDeviceProperty prop){
	char buf[128];
	vr::TrackedPropertyError err;
	pHmd->GetStringTrackedDeviceProperty(unDevice, prop, buf, sizeof(buf), &err);
	if (err != vr::TrackedProp_Success)
	{
		return String("Error Getting String: ") + pHmd->GetPropErrorNameFromEnum(err);
	}
	else
	{
		return buf;
	}
}

OpenVROverlay::OpenVROverlay() :  m_strVRDriver("Uninitialized Driver")
								, m_strVRDisplay("Uninitialized Display")
								, m_eLastHmdError(vr::VRInitError_None)
								, m_eCompositorError(vr::VRInitError_None)
								, m_eOverlayError(vr::VRInitError_None)
								, m_ulOverlayHandle(vr::k_ulOverlayHandleInvalid)
{}

void OpenVROverlay::_register_methods(){
	register_method("ConnectToVRRuntime", &OpenVROverlay::ConnectToVRRuntime);
	register_method("DisconnectFromVRRuntime", &OpenVROverlay::DisconnectFromVRRuntime);
	register_method("Init", &OpenVROverlay::Init);

	register_method("_ready", &OpenVROverlay::_ready);
	register_method("_exit_tree", &OpenVROverlay::_exit_tree);
	register_method("_process", &OpenVROverlay::_process);

	register_method("show_keyboard", &OpenVROverlay::show_keyboard);
	register_method("hide_keyboard_if_still_showing", &OpenVROverlay::hide_keyboard_if_still_showing);

	register_method("refresh_screen", &OpenVROverlay::refresh_screen);

	register_property<OpenVROverlay, String>("strVRDriver", &OpenVROverlay::m_strVRDriver, String("Uninitialized Driver"));
	register_property<OpenVROverlay, String>("strVRDisplay", &OpenVROverlay::m_strVRDisplay, String("Uninitialized Display"));

	register_property<OpenVROverlay, real_t>("base/widthInMeters", &OpenVROverlay::set_width, &OpenVROverlay::get_width, 1.5);
	register_property<OpenVROverlay, Rect2> ("base/textureBounds", &OpenVROverlay::set_UV_bounds, &OpenVROverlay::get_UV_bounds, Rect2());
}

void OpenVROverlay::_init(){
	Godot::print("OpenVROverlay init");
}

void OpenVROverlay::_exit_tree() {
	Shutdown();
}

void OpenVROverlay::_process(const real_t delta){
	if (!has_initialized)
		return;
	if (!vr::VRSystem())
		return;
	if (!vr::VROverlay()->IsActiveDashboardOverlay(m_ulOverlayHandle))
		return;


	consume_input();
}

void OpenVROverlay::_ready() {
	Godot::print("OpenVROverlay Ready");

	set_process(false);
	Init();
}




bool OpenVROverlay::ConnectToVRRuntime(){
	m_eLastHmdError = vr::VRInitError_None;
	vr::IVRSystem* pVRSystem = vr::VR_Init(&m_eLastHmdError, vr::VRApplication_Overlay);

	if (m_eLastHmdError != vr::VRInitError_None)
	{
		m_strVRDriver = "No Driver";
		m_strVRDisplay = "No Display";
		return false;
	}

	m_strVRDriver = GetTrackedDeviceString(pVRSystem, vr::k_unTrackedDeviceIndex_Hmd, vr::Prop_TrackingSystemName_String);
	m_strVRDisplay = GetTrackedDeviceString(pVRSystem, vr::k_unTrackedDeviceIndex_Hmd, vr::Prop_SerialNumber_String);

	return true;
}

void OpenVROverlay::DisconnectFromVRRuntime(){
	if (!has_initialized) return;

	vr::VROverlayError overlayError = vr::VROverlay()->DestroyOverlay(m_ulOverlayHandle);
	
	CHEQUE(destroy overlay);

	has_initialized = false;
}


void OpenVROverlay::Init() {
	Godot::print("OpenVROverlay Initialization");


	bool bSuccess = true;

	bSuccess = ConnectToVRRuntime();
	bSuccess = bSuccess && vr::VRCompositor() != NULL;

	if (vr::VROverlay()) {
		String sKey = String("sample.") + get_name();
		vr::VROverlayError overlayError = vr::VROverlay()->CreateDashboardOverlay(sKey.alloc_c_string(), get_name().alloc_c_string(), &m_ulOverlayHandle, &m_ulOverlayThumbnailHandle);
		bSuccess = bSuccess && overlayError == vr::VROverlayError_None;
		CHEQUE(create dashboard overlay);

		overlayError = vr::VROverlay()->SetOverlayFlag(m_ulOverlayHandle, vr::VROverlayFlags_SendVRSmoothScrollEvents, true);
		CHEQUE(enable scroll events);
	}

	if (bSuccess) {
		vr::VROverlay()->SetOverlayWidthInMeters(m_ulOverlayHandle, 1.5f);
		vr::VROverlay()->SetOverlayInputMethod(m_ulOverlayHandle, vr::VROverlayInputMethod_Mouse);
	}

	if (!bSuccess) {
		Godot::print("Initialization failed ...");
	}

	set_process(bSuccess);
	has_initialized = bSuccess;

	if (bSuccess) {
		VisualServer::get_singleton()->connect("frame_post_draw", this, "refresh_screen");
	}
}

void OpenVROverlay::Shutdown() {
	DisconnectFromVRRuntime();
}

void OpenVROverlay::set_width(real_t v){
	if (!has_initialized) return;
	auto overlayError = vr::VROverlay()->SetOverlayWidthInMeters(m_ulOverlayHandle, v);
	CHEQUE(set overlay width);
}

real_t OpenVROverlay::get_width() const {
	if (!has_initialized) return 0.0;

	float val;
	auto overlayError = vr::VROverlay()->GetOverlayWidthInMeters(m_ulOverlayHandle, &val);
	CHEQUE(get overlay width);
	return val;
}

void OpenVROverlay::set_UV_bounds(Rect2 v){
	if (!has_initialized) return;
	vr::VRTextureBounds_t bounds;
	bounds.uMin = v.position.x;
	bounds.vMin = v.position.y;

	bounds.uMax = v.position.x + v.size.x;
	bounds.vMax = v.position.y + v.size.y;

	auto overlayError = vr::VROverlay()->SetOverlayTextureBounds(m_ulOverlayHandle, &bounds);

	CHEQUE(set UV bounds);

}

Rect2 OpenVROverlay::get_UV_bounds() const {
	if (!has_initialized) return Rect2();

	vr::VRTextureBounds_t bounds;
	auto overlayError = vr::VROverlay()->GetOverlayTextureBounds(m_ulOverlayHandle, &bounds);

	CHEQUE(get UV bounds);

	Rect2 result(Vector2(bounds.uMin, bounds.vMin), Vector2(bounds.uMax - bounds.uMin, bounds.vMax - bounds.vMin));

	return result;
}

#define MAX_KB_LEN 1024

void OpenVROverlay::show_keyboard(Node *tgt_n){
	if (!has_initialized) return;

	if (tgt_n == 0) {
		Godot::print("Null pointer passed to show_keyboard");
		return;
	}

	uint64_t max_len = get_max_len(tgt_n);
	if (max_len < 1)
		max_len = MAX_KB_LEN;

	Control* cont = Object::cast_to<Control>(tgt_n);
	if (!cont)
		return;

	auto overlayError = vr::VROverlay()->ShowKeyboardForOverlay(m_ulOverlayHandle,
		vr::k_EGamepadTextInputModeSubmit,
		is_multiline(tgt_n) ? vr::k_EGamepadTextInputLineModeMultipleLines : vr::k_EGamepadTextInputLineModeSingleLine,
		vr::KeyboardFlag_Modal,

		tgt_n->get_name().alloc_c_string(), // description??
		max_len,		// max chars
		get_text_from(tgt_n).alloc_c_string(),			// curr text
		0			// wtf
	);
	CHEQUE(show the keyboard);


	auto rect = cont->get_global_rect();

	vr::HmdRect2_t ovr_rect;
	ovr_rect.vTopLeft = { rect.position.x / get_size().x , rect.position.y / get_size().y };
	ovr_rect.vBottomRight = { (rect.size.x + rect.position.x) / get_size().x , (rect.size.y + rect.position.y) / get_size().y };

	vr::VROverlay()->SetKeyboardPositionForOverlay(m_ulOverlayHandle, ovr_rect);

	// TODO: clear the old one so as to not take over
	current_keyboard_target = tgt_n;
}


void OpenVROverlay::hide_keyboard_if_still_showing(Node* tgt_n) {
	if (!has_initialized) return;

	if (tgt_n == current_keyboard_target) {
		current_keyboard_target = 0;
		vr::VROverlay()->HideKeyboard();
		return;
	}
}


void OpenVROverlay::refresh_screen() {
	if (!has_initialized) return;

	RID render_target = get_viewport_rid();

	if (!render_target.is_valid()) {
		Godot::print("RENDER TARGET IS NOT VALID!");
	}

	vr::TextureID_t texidov = (vr::TextureID_t)godot::VisualServer::get_singleton()->texture_get_texid(
		godot::VisualServer::get_singleton()->viewport_get_texture(render_target)
	);

	vr::Texture_t texture = { (void*)(uintptr_t)texidov, vr::TextureType_OpenGL, vr::ColorSpace_Auto };

	auto overlayError = vr::VROverlay()->SetOverlayTexture(m_ulOverlayHandle, &texture);
	CHEQUE(set overlay texture);
}

void OpenVROverlay::consume_input() {
	if (!has_initialized) return;

	vr::VREvent_t vrEvent;
	while (vr::VROverlay()->PollNextOverlayEvent(m_ulOverlayHandle, &vrEvent, sizeof(vrEvent)))
	{
		switch (vrEvent.eventType)
		{
		case vr::VREvent_MouseMove:
		{
			InputEventMouseMotion *ev = InputEventMouseMotion::_new();
			last_mouse_position = Vector2(vrEvent.data.mouse.x, vrEvent.data.mouse.y) * get_size();
			ev->set_position(last_mouse_position);


			get_tree()->input_event(ev);
		}
		break;

		case vr::VREvent_MouseButtonDown:
		{
			InputEventMouseButton* ev = InputEventMouseButton::_new();
			last_mouse_position = Vector2(vrEvent.data.mouse.x, vrEvent.data.mouse.y) * get_size();
			ev->set_position(last_mouse_position);

			if (vrEvent.data.mouse.button & vr::VRMouseButton_Left) {
				ev->set_button_index(1);
			} else if (vrEvent.data.mouse.button & vr::VRMouseButton_Right) {
				ev->set_button_index(2);
			} else if (vrEvent.data.mouse.button & vr::VRMouseButton_Middle) {
				ev->set_button_index(3);
			}

			ev->set_button_mask(vrEvent.data.mouse.button);

			ev->set_pressed(true);

			get_tree()->input_event(ev);
		}
		break;

		case vr::VREvent_MouseButtonUp:
		{
			InputEventMouseButton* ev = InputEventMouseButton::_new();
			ev->set_position(Vector2(vrEvent.data.mouse.x, vrEvent.data.mouse.y) * get_size());


			if (vrEvent.data.mouse.button & vr::VRMouseButton_Left) {
				ev->set_button_index(1);
			}else if (vrEvent.data.mouse.button & vr::VRMouseButton_Right) {
				ev->set_button_index(2);
			}else if (vrEvent.data.mouse.button & vr::VRMouseButton_Middle) {
				ev->set_button_index(3);
			}

			ev->set_button_mask(vrEvent.data.mouse.button);

			ev->set_pressed(false);

			get_tree()->input_event(ev);
		}
		break;

		case vr::VREvent_ScrollSmooth:
		{

			auto x_scroll = vrEvent.data.scroll.xdelta;
			auto y_scroll = vrEvent.data.scroll.ydelta;

			Godot::print("Scrolling " + String::num_real(x_scroll) + " , " + String::num_real(y_scroll));

			perform_scroll((y_scroll > 0) ? 4 : 5, abs(y_scroll));
			perform_scroll((x_scroll > 0) ? 6 : 7, abs(x_scroll));

		}

		case vr::VREvent_KeyboardCharInput:
		case vr::VREvent_KeyboardDone:
		{
			char* txt = (char *)malloc(MAX_KB_LEN);
			auto len = vr::VROverlay()->GetKeyboardText(txt, MAX_KB_LEN);
			String text(txt);

			if (current_keyboard_target) {
				set_text_to(current_keyboard_target, text);
			}
			
			std::free(txt);
		}
		break;

		
		case vr::VREvent_Quit:
			get_tree()->quit();
			break;

		}
	}

	// undo scroll
	for (int i = 0; i < 10; i++) {
		if (is_mouse_button_pressed[i]) {
			InputEventMouseButton* ev = InputEventMouseButton::_new();
			ev->set_position(last_mouse_position);
			ev->set_button_index(i);
			ev->set_factor(0.0);
			ev->set_pressed(false);
			get_tree()->input_event(ev);

			is_mouse_button_pressed[i] = false;
		}
	}

}

void OpenVROverlay::perform_scroll(const uint64_t& idx, const real_t& amount){
	InputEventMouseButton* ev = InputEventMouseButton::_new();
	ev->set_position(last_mouse_position);
	ev->set_button_index(idx);
	ev->set_factor(amount);
	ev->set_pressed(true);
	get_tree()->input_event(ev);
	is_mouse_button_pressed[idx] = true;
}


#undef CHEQUE(WTF)
#undef CHEQUE