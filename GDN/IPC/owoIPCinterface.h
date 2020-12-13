#pragma once

#include <Godot.hpp>
#include <Reference.hpp>
#include "owoIPC.h"

using namespace godot;


#include "win32ipc.h"

#include <map>

/*
struct OwoSetting {
	owoTrackerSettingType setting_type;
	Variant value;
	int last_updated = -1;
};

class OwoTrackedDevice : public Reference {
	GODOT_CLASS(OwoTrackedDevice, Reference);
private:
	OwoIPCInterface ipc;

	OwoSetting anchor_device_id = { ANCHOR_DEVICE_ID, -1 };

	OwoSetting offset_global = { OFFSET_GLOBAL, Vector3() };
	OwoSetting offset_local_device = { OFFSET_LOCAL_TO_DEVICE, Vector3() };
	OwoSetting offset_local_tracker = { OFFSET_LOCAL_TO_TRACKER, Vector3() };

	OwoSetting yaw_value = { YAW_VALUE, 0.0 };

	OwoSetting predict_position = { PREDICT_POSITION, false };
	OwoSetting predict_position_strength = { PREDICT_POSITION_STRENGTH, 0.0 };

	OwoSetting calibrating = { IS_CALIBRATING, false };

public:
	int id = -1;

	void _init();
	static void _register_methods();

	void set_calibrating(bool to);
};*/


class OwoIPCInterface: public Reference {
	GODOT_CLASS(OwoIPCInterface, Reference)
	private:
		Win32IPC from_openvr = Win32IPC(true, "\\\\.\\mailslot\\owoTrack-driver-pipe-to-overlay");
		Win32IPC to_openvr = Win32IPC(false, "\\\\.\\mailslot\\owoTrack-driver-pipe-from-overlay");

		void _send_ev(owoEvent ev);

		unsigned int incr = 0;
		
		Dictionary construct_from_event(owoEvent ev);

	public:
		void _init();
		static void _register_methods();

		Dictionary get_latest_message();

		// returns a number that can later be used to request data
		int request_version();
		int request_trackers_len();
		int request_tracker_data(int idx);
		int request_tracker_setting(int idx, int setting);

		void bypass_delay();

		void set_tracker_setting(int idx, int setting, Variant val);
		
		int create_tracker(int port_no); // returns tracker index
		void destroy_tracker(int idx);
		
};