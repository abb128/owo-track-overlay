#include "openvrinterface.h"

#include <PoolArrays.hpp>

void TrackedDevice::_init(){}

uint64_t TrackedDevice::get_id() {
	return deviceIdx;
}

void TrackedDevice::set_id(uint64_t idx){
	if (idx >= vr::k_unMaxTrackedDeviceCount) {
		Godot::print("Idx is too large!");
	}
	deviceIdx = idx;
}

void TrackedDevice::_register_methods(){
	register_method("get_string_property", &TrackedDevice::get_string_property);
	register_method("get_float_property", &TrackedDevice::get_float_property);
	register_method("get_bool_property", &TrackedDevice::get_bool_property);

	register_method("get_device_class", &TrackedDevice::get_device_class);
	register_method("send_message", &TrackedDevice::send_message);

	register_method("is_initialized", &TrackedDevice::is_initialized);

	register_property<TrackedDevice, uint64_t>("id", &TrackedDevice::set_id, &TrackedDevice::get_id, (uint64_t)0);
}

#define NULL_CHECK(ptr, msg) if(ptr == NULL){ Godot::print(msg); return; }

#define NULL_CHECK_RET(ptr, msg, v) if(ptr == NULL){ Godot::print(msg); return v; }


TrackedDevice::DeviceClass TrackedDevice::get_device_class(){
	NULL_CHECK_RET(vr::VRSystem(), "get_device_class VRSystem missing", TrackedDeviceClass_Invalid);

	return (TrackedDevice::DeviceClass)vr::VRSystem()->GetTrackedDeviceClass(deviceIdx);
}

String TrackedDevice::get_string_property(uint64_t prop){
	NULL_CHECK_RET(vr::VRSystem(), "get_string_property VRSystem missing", "");

	char* storage = (char *)malloc(/*vr::k_unMaxPropertyStringSize*/2048);
	vr::ETrackedPropertyError err;

	auto len = vr::VRSystem()->GetStringTrackedDeviceProperty(deviceIdx, (vr::ETrackedDeviceProperty)prop, storage, 2048, &err);

	return String(storage);
}

bool TrackedDevice::get_bool_property(uint64_t prop){
	NULL_CHECK_RET(vr::VRSystem(), "get_bool_property VRSystem missing", false);

	vr::ETrackedPropertyError err;
	auto result = vr::VRSystem()->GetBoolTrackedDeviceProperty(deviceIdx, (vr::ETrackedDeviceProperty)prop, &err);
	return result;
}

real_t TrackedDevice::get_float_property(uint64_t prop){
	NULL_CHECK_RET(vr::VRSystem(), "get_float_property VRSystem missing", 0.0);


	vr::ETrackedPropertyError err;
	auto result = vr::VRSystem()->GetFloatTrackedDeviceProperty(deviceIdx, (vr::ETrackedDeviceProperty)prop, &err);
	return result;
}



PoolByteArray TrackedDevice::send_message(PoolByteArray input){
	NULL_CHECK_RET(vr::VRDebug(), "send_message VRDebug missing", PoolByteArray());

	// Godot::print("send_message");
	char* result = (char *)malloc(vr::k_unMaxDriverDebugResponseSize);

	auto len = vr::VRDebug()->DriverDebugRequest(deviceIdx, (const char *)(input.read().ptr()), result, vr::k_unMaxDriverDebugResponseSize);
	// Godot::print("Response: " + String::num_int64(len));
	//result.resize(len);

	

	PoolByteArray result_bytes;
	for (int i = 0; i < vr::k_unMaxDriverDebugResponseSize; i++) {
		if (result[i] == 0) break;
		result_bytes.append(result[i]);
	}

	std::free(result);

	return result_bytes;
}

bool TrackedDevice::is_initialized(){
	return (vr::VRApplications() != NULL)
		&& (vr::VRDebug() != NULL)
		&& (vr::VRSystem() != NULL);
}

void OpenVRInterface::_init() {

}


void OpenVRInterface::add_manifest(String full_path, bool temporary) {
	NULL_CHECK(vr::VRApplications(), "add_manifest VRApplications missing");

	char * manifest_path = full_path.alloc_c_string();
	auto err = vr::VRApplications()->AddApplicationManifest(manifest_path, temporary);
	if (err != vr::VRApplicationError_None) {
		Godot::print("AddApplicationManifest error " + String::num_int64(err));
	}
}

void OpenVRInterface::remove_manifest(String full_path) {
	NULL_CHECK(vr::VRApplications(), "remove_manifest VRApplications missing");

	char * manifest_path = full_path.alloc_c_string();
	auto err = vr::VRApplications()->RemoveApplicationManifest(manifest_path);
	if (err != vr::VRApplicationError_None) {
		Godot::print("RemoveApplicationManifest error " + String::num_int64(err));
	}
}

bool OpenVRInterface::is_installed(String key) {
	NULL_CHECK_RET(vr::VRApplications(), "is_installed VRApplications missing", false);

	char * key_c = key.alloc_c_string();
	bool is_installed_b = vr::VRApplications()->IsApplicationInstalled(key_c);
	return is_installed_b;
}


void OpenVRInterface::set_auto_launch(String key, bool v){
	NULL_CHECK(vr::VRApplications(), "set_auto_launch VRApplications missing");

	char* key_c = key.alloc_c_string();
	auto err = vr::VRApplications()->SetApplicationAutoLaunch(key_c, v);
	if (err != vr::VRApplicationError_None) {
		Godot::print("SetApplicationAutoLaunch error " + String::num_int64(err));
	}
}

bool OpenVRInterface::is_initialized(){
	return (vr::VRApplications() != NULL);
}

String OpenVRInterface::get_runtime_path(){
	char* path_buffer = (char *)malloc(512);
	uint32_t path_len;

	bool succ = vr::VR_GetRuntimePath(path_buffer, 512, &path_len);

	path_buffer[path_len] = 0;

	String result(path_buffer);

	std::free((void*)path_buffer);

	return result;
}

void OpenVRInterface::_register_methods() {
	register_method("add_manifest", &OpenVRInterface::add_manifest);
	register_method("remove_manifest", &OpenVRInterface::remove_manifest);
	register_method("is_installed", &OpenVRInterface::is_installed);
	register_method("set_auto_launch", &OpenVRInterface::set_auto_launch);

	register_method("is_initialized", &OpenVRInterface::is_initialized);

	register_method("get_runtime_path", &OpenVRInterface::get_runtime_path);
}