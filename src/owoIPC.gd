extends Node
class_name OwoIPC

var version_received: bool = false;
var version_matches: bool = false;

enum owoEventType {
	INVALID_EVENT,

	GET_VERSION,
	VERSION_RECEIVED, # the version - index

	GET_TRACKERS_LEN,
	TRACKERS_LEN_RECEIVED, # number of trackers that exist - index

	GET_TRACKER, # tracker index - index
	TRACKER_RECEIVED, # tracker - tracker

	BYPASS_DELAY,

	SET_TRACKER_SETTING, # trackerSetting
	GET_TRACKER_SETTING,  # trackerSetting, v is nothing
	TRACKER_SETTING_RECEIVED, # trackerSetting

	CREATE_TRACKER, # trackerCreation
	TRACKER_CREATED, # new tracker index - index

	DESTROY_TRACKER # tracker index - index
}


enum owoTrackerSettingType {
	ANCHOR_DEVICE_ID,		# index

	OFFSET_GLOBAL,			# vector
	OFFSET_LOCAL_TO_DEVICE,	# vector
	OFFSET_LOCAL_TO_TRACKER,# vector

	OFFSET_ROT_GLOBAL, # vector
	OFFSET_ROT_LOCAL,  # vector
	
	YAW_VALUE,				# double_v

	PREDICT_POSITION,		# bool_v
	PREDICT_POSITION_STRENGTH, # double_v

	IS_CALIBRATING,			# bool_v
	IS_CONN_ALIVE			# bool_v, read only
}

signal on_message(msg);
signal connection_ready;
signal tracker_added(idx, port);

var _ipc: OwoIPCInterface = null;

func bypass_waiting() -> void:
	_ipc.bypass_delay();

const CLIENT_VERSION = 7;
var SERVER_VERSION = -1;


func spawn_tracker(port_no: int) -> int:
	_ipc.create_tracker(port_no);
	for i in range(100):
		var msg: Dictionary = yield(self, "on_message");
		if(msg["type"] != owoEventType.TRACKER_CREATED):
			continue;
		
		var idx: int = msg["data"]["new_idx"];
		if(idx > 5000):
			# failed
			return idx;
		
		emit_signal("tracker_added", idx, port_no);
		
	return 0;

func get_tracker_count() -> int:
	_ipc.request_trackers_len();
	for i in range(100):
		var msg: Dictionary = yield(self, "on_message");
		if(msg["type"] != owoEventType.TRACKERS_LEN_RECEIVED):
			continue;
		
		return msg["data"]["trackers_len"];
	return 0;

func get_tracker(idx: int) -> Dictionary:
	_ipc.request_tracker_data(idx);
	for i in range(100):
		var msg: Dictionary = yield(self, "on_message");
		if(msg["type"] != owoEventType.TRACKER_RECEIVED):
			continue;
		
		return msg["data"];
	return {};

func get_version_async():
	_ipc.request_version();
	for i in range(100):
		var msg: Dictionary = yield(self, "on_message");
		if(msg["type"] != owoEventType.VERSION_RECEIVED):
			continue;
		
		SERVER_VERSION = msg["data"]["version"];
		return SERVER_VERSION;

func get_tracker_setting_async(device_idx: int, setting: int):
	_ipc.request_tracker_setting(device_idx, setting);
	for i in range(100):
		var msg: Dictionary = yield(self, "on_message");
		if(msg["type"] != owoEventType.TRACKER_SETTING_RECEIVED):
			continue;
		
		if(msg["data"]["setting_type"] != setting):
			continue;
		
		if(msg["data"]["tracker_index"] != device_idx):
			continue;
			
		
		return msg["data"]["value"];
	printerr("After so many iterations nothing for " + str(setting));

func set_tracker_setting_async(device_idx: int, setting: int, val):
	_ipc.set_tracker_setting(device_idx, setting, val);
	# verify?

func _tick() -> void:
	var msg: Dictionary = _ipc.get_latest_message();
	if(msg["pending"] != true):
		return;
	
	emit_signal("on_message", msg);

func _process(delta: float) -> void:
	_tick();
	
	if(SERVER_VERSION == -1):
		get_version_async();
	elif(!version_received):
		version_received = true;
		version_matches = SERVER_VERSION == CLIENT_VERSION;
		emit_signal("connection_ready");


func _do_tracker(idx: int) -> void:
	var data = yield(get_tracker(idx), "completed");
	if(!data.has("port")):
		return;
	emit_signal("tracker_added", idx, data["port"]);

func _add_existing_trackers() -> void:
	var trackers_count = yield(get_tracker_count(), "completed");
	for i in range(trackers_count):
		_do_tracker(i);

func _init():
	_ipc = OwoIPCInterface.new();
	set_process(true);
	connect("connection_ready", self, "_add_existing_trackers");



# helper functions to make it easier
func get_yaw(device_idx: int):
	return get_tracker_setting_async(device_idx, owoTrackerSettingType.YAW_VALUE);
func set_yaw(device_idx: int, to: float) -> void:
	set_tracker_setting_async(device_idx, owoTrackerSettingType.YAW_VALUE, to);

func get_predict(device_idx: int):
	return get_tracker_setting_async(device_idx, owoTrackerSettingType.PREDICT_POSITION);
func set_predict(device_idx: int, to: bool) -> void:
	set_tracker_setting_async(device_idx, owoTrackerSettingType.PREDICT_POSITION, to);

func get_predict_strength(device_idx: int):
	return get_tracker_setting_async(device_idx, owoTrackerSettingType.PREDICT_POSITION_STRENGTH);
func set_predict_strength(device_idx: int, to: float) -> void:
	set_tracker_setting_async(device_idx, owoTrackerSettingType.PREDICT_POSITION_STRENGTH, to);

func get_calibrating(device_idx: int):
	return get_tracker_setting_async(device_idx, owoTrackerSettingType.IS_CALIBRATING);
func set_calibrating(device_idx: int, to: bool) -> void:
	set_tracker_setting_async(device_idx, owoTrackerSettingType.IS_CALIBRATING, to);

func is_alive(device_idx: int):
	return get_tracker_setting_async(device_idx, owoTrackerSettingType.IS_CONN_ALIVE);


func get_offset_global(device_idx: int):
	return get_tracker_setting_async(device_idx, owoTrackerSettingType.OFFSET_GLOBAL);
func set_offset_global(device_idx: int, to: Vector3) -> void:
	set_tracker_setting_async(device_idx, owoTrackerSettingType.OFFSET_GLOBAL, to);

func get_offset_local_d(device_idx: int):
	return get_tracker_setting_async(device_idx, owoTrackerSettingType.OFFSET_LOCAL_TO_DEVICE);
func set_offset_local_d(device_idx: int, to: Vector3) -> void:
	set_tracker_setting_async(device_idx, owoTrackerSettingType.OFFSET_LOCAL_TO_DEVICE, to);

func get_offset_local_t(device_idx: int):
	return get_tracker_setting_async(device_idx, owoTrackerSettingType.OFFSET_LOCAL_TO_TRACKER);
func set_offset_local_t(device_idx: int, to: Vector3) -> void:
	set_tracker_setting_async(device_idx, owoTrackerSettingType.OFFSET_LOCAL_TO_TRACKER, to);

func get_rot_offset_local(device_idx: int):
	return get_tracker_setting_async(device_idx, owoTrackerSettingType.OFFSET_ROT_LOCAL);
func set_rot_offset_local(device_idx: int, to: Vector3) -> void:
	set_tracker_setting_async(device_idx, owoTrackerSettingType.OFFSET_ROT_LOCAL, to);

func get_rot_offset_global(device_idx: int):
	return get_tracker_setting_async(device_idx, owoTrackerSettingType.OFFSET_ROT_GLOBAL);
func set_rot_offset_global(device_idx: int, to: Vector3) -> void:
	set_tracker_setting_async(device_idx, owoTrackerSettingType.OFFSET_ROT_GLOBAL, to);

