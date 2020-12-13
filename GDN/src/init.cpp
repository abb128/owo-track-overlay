#include <Godot.hpp>
#include <Reference.hpp>

#include "openvroverlay.h"
#include "../openvrinterface.h"
#include "../IPC/owoIPCinterface.h"

using namespace godot;

/** GDNative Initialize **/
extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *o) {
    godot::Godot::gdnative_init(o);
}

/** GDNative Terminate **/
extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *o) {
    godot::Godot::gdnative_terminate(o);
}


/** NativeScript Initialize **/
extern "C" void GDN_EXPORT godot_nativescript_init(void *handle) {
    godot::Godot::nativescript_init(handle);

    godot::register_class<OpenVROverlay>();
    godot::register_class<OpenVRInterface>();
    godot::register_class<TrackedDevice>();
    godot::register_class<OwoIPCInterface>();
}