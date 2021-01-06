#include "owoIPCinterface.h"

void OwoIPCInterface::_send_ev(owoEvent ev){
	IPCData data = {};
	data.buffer = &ev;
	data.data_length = sizeof(owoEvent);

	to_openvr.put_data(data);
}

void OwoIPCInterface::_init() {
	from_openvr.init();
	to_openvr.init();
}

#define reg_mtd(name) register_method(#name, &OwoIPCInterface::name)
void OwoIPCInterface::_register_methods(){
	reg_mtd(request_version);
	reg_mtd(request_trackers_len);
	reg_mtd(request_tracker_data);
	reg_mtd(request_tracker_setting);
	reg_mtd(bypass_delay);
	reg_mtd(set_tracker_setting);
	reg_mtd(create_tracker);
	reg_mtd(destroy_tracker);

	reg_mtd(get_latest_message);
}


#undef reg_mtd



inline Variant get_var_from_setting_event(owoEventTrackerSetting& ev) {
	switch (ev.type) {
	case ANCHOR_DEVICE_ID:
		return Variant(ev.index);

	case YAW_VALUE:
	case PREDICT_POSITION_STRENGTH:
		return Variant(ev.double_v);

	case PREDICT_POSITION:
	case IS_CALIBRATING:
	case IS_CONN_ALIVE:
		return Variant(ev.bool_v);

	case OFFSET_GLOBAL:
	case OFFSET_LOCAL_TO_DEVICE:
	case OFFSET_LOCAL_TO_TRACKER:
	case OFFSET_ROT_LOCAL:
	case OFFSET_ROT_GLOBAL:
		return Variant(Vector3(ev.vector.x, ev.vector.y, ev.vector.z));
	}
}


Dictionary OwoIPCInterface::construct_from_event(owoEvent ev){
	Dictionary data;
	switch (ev.type) {
		case VERSION_RECEIVED:
			data["version"] = ev.index;
			break;

		case TRACKERS_LEN_RECEIVED:
			data["trackers_len"] = ev.index;
			break;

		case TRACKER_RECEIVED: 
			data["exists"] = ev.tracker.exists;
			data["index"] = ev.tracker.ovrDeviceIdx;
			data["port"] = ev.tracker.port_no;
			break;
		
		case TRACKER_SETTING_RECEIVED:
			data["tracker_index"] = ev.trackerSetting.tracker_id;
			data["setting_type"] = ev.trackerSetting.type;
			data["value"] = get_var_from_setting_event(ev.trackerSetting);
			break;

		case TRACKER_CREATED:
			data["new_idx"] = ev.index;
			break;
	}

	return data;
}

Dictionary OwoIPCInterface::get_latest_message() {
	Dictionary result;
	result["pending"] = true;
	if (!from_openvr.is_data_waiting()) {
		result["pending"] = false;
		return result;
	}

	IPCData data = from_openvr.get_data();
	
	if (data.data_length != sizeof(owoEvent)) {
		Godot::print("Critical error mismatching size!");
		Godot::print(String::num_int64(data.data_length));
		Godot::print(String::num_int64(sizeof(owoEvent)));
		data.free();
		return result;
	}

	owoEvent ev;
	memcpy(&ev, data.buffer, data.data_length);
	data.free();

	result["type"] = ev.type;
	result["data"] = construct_from_event(ev);

	return result;
}



int OwoIPCInterface::request_version(){
	owoEvent ev = {};
	ev.type = GET_VERSION;
	
	_send_ev(ev);

	return ++incr;
}

int OwoIPCInterface::request_trackers_len(){
	owoEvent ev = {};
	ev.type = GET_TRACKERS_LEN;

	_send_ev(ev);

	return ++incr;
}

int OwoIPCInterface::request_tracker_data(int idx){
	owoEvent ev = {};
	ev.type = GET_TRACKER;
	ev.index = idx;

	_send_ev(ev);

	return ++incr;
}

int OwoIPCInterface::request_tracker_setting(int idx, int setting){
	owoEvent ev = {};
	ev.type = GET_TRACKER_SETTING;
	ev.trackerSetting = owoEventTrackerSetting{ (unsigned int)idx, (owoTrackerSettingType)setting, 0};

	_send_ev(ev);

	return ++incr;
}

void OwoIPCInterface::bypass_delay(){
	owoEvent ev = {};
	ev.type = BYPASS_DELAY;

	_send_ev(ev);
}

void OwoIPCInterface::set_tracker_setting(int idx, int setting, Variant val){
	owoEvent ev = {};
	ev.type = SET_TRACKER_SETTING;

	owoEventTrackerSetting set_ev = {};
	set_ev.tracker_id = idx;
	set_ev.type = (owoTrackerSettingType)setting;
	
	switch (setting) {
	case PREDICT_POSITION:
	case IS_CALIBRATING:
	case IS_CONN_ALIVE:
		set_ev.bool_v = (bool)val;
		break;

	case YAW_VALUE:
	case PREDICT_POSITION_STRENGTH:
		set_ev.double_v = (double)val;
		break;

	case ANCHOR_DEVICE_ID:
		set_ev.index = (int)val;
		break;

	case OFFSET_GLOBAL:
	case OFFSET_LOCAL_TO_DEVICE:
	case OFFSET_LOCAL_TO_TRACKER:
	case OFFSET_ROT_GLOBAL:
	case OFFSET_ROT_LOCAL:
	{
		Vector3 vec_g = (Vector3)val;
		owoEventVector vec_owo = { vec_g.x, vec_g.y, vec_g.z };

		set_ev.vector = vec_owo;
	}
	break;
	}

	ev.trackerSetting = set_ev;

	_send_ev(ev);
}

int OwoIPCInterface::create_tracker(int port_no){
	owoEvent ev = {};
	ev.type = CREATE_TRACKER;
	
	owoTrackerCreationData creation = { port_no };

	ev.trackerCreation = creation;

	_send_ev(ev);

	return ++incr;
}

void OwoIPCInterface::destroy_tracker(int idx){
	owoEvent ev = {};
	ev.type = DESTROY_TRACKER;
	ev.index = idx;

	_send_ev(ev);
}
