#pragma once

#include <Godot.hpp>
#include <Reference.hpp>
#include "owoIPC.h"

using namespace godot;


#include "win32ipc.h"

#include <map>
#include <openvr.h>

class OwoIPCInterface: public Reference {
	GODOT_CLASS(OwoIPCInterface, Reference)
	private:
		Win32IPC from_openvr = Win32IPC(true, "\\\\.\\mailslot\\owoTrack-driver-pipe-to-overlay");
		Win32IPC to_openvr = Win32IPC(false, "\\\\.\\mailslot\\owoTrack-driver-pipe-from-overlay");

		void _send_ev(owoEvent ev);

		unsigned int incr = 0;
		
		Dictionary construct_from_event(owoEvent ev);



		vr::VRActionHandle_t m_actionAnalongInput = vr::k_ulInvalidActionHandle;
		vr::VRActionHandle_t m_actionsetDemo = vr::k_ulInvalidActionHandle;
		vr::VRActionHandle_t m_actionPose = vr::k_ulInvalidActionHandle;


		time_t last_joystick_send = 0;

	public:
		void _init();
		static void _register_methods();

		Dictionary get_latest_message();

		// returns a number that can later be used to request data
		int request_version();
		int request_trackers_len();
		int request_tracker_data(int idx);
		int request_tracker_setting(int idx, int setting);

		void set_tracker_setting(int idx, int setting, Variant val);
		
		int create_tracker(int port_no); // returns tracker index
		void destroy_tracker(int idx);
		
		void init_hipmove();
		void tick_hipmove(int idx);

		int get_last_joystick_time();
};