# owo-track-overlay

Full builds of app, overlay and driver combined are available at https://mega.nz/folder/HRADQKLC#VKc-SFI6H2twCIQaBeE3EA

## Custom Godot build

In order for the overlay to work in SteamVR when the window is minimized on desktop, a custom build of Godot needs to be used. You need to use Godot 3.2.3 with this line https://github.com/godotengine/godot/blob/3.2.3-stable/platform/windows/os_windows.cpp#L272 replaced with `return true;`. This relates to https://github.com/godotengine/godot-proposals/issues/1931


## GDN and GDN_bin

GDN is the name of a GDNative library this project uses to interface with OpenVR and make it work as a dashboard overlay. It also contains some IPC stuff. You need to populate GDN/openvr_lib with the binaries from https://github.com/ValveSoftware/openvr/tree/master/lib and then build the project in Visual Studio. The output should be at GDN_bin/GDN.dll. GDN_bin/openvr_api.dll should also exist



## Godot build optimizations

You may use this custom.py to build a more optimized version of Godot that I use for release.
```py
platform = "windows"
tools = "no"
disable_3d = "yes"
optimize = "size"
deprecated = "no"
minizip = "no"
module_arkit_enabled = "no"
module_bmp_enabled = "no"
module_bullet_enabled = "no"
module_camera_enabled = "no"
module_csg_enabled = "no"
module_dds_enabled = "no"
module_enet_enabled = "no"
module_etc_enabled = "no"
module_gdnavigation_enabled = "no"
module_gridmap_enabled = "no"
module_hdr_enabled = "no"
module_jpg_enabled = "no"
module_jsonrpc_enabled = "no"
module_mbedtls_enabled = "no"
module_mobile_vr_enabled = "no"
module_ogg_enabled = "yes"
module_opensimplex_enabled = "no"
module_opus_enabled = "yes"
module_regex_enabled = "yes"
module_stb_vorbis_enabled = "no"
module_tga_enabled = "no"
module_theora_enabled = "no"
module_tinyexr_enabled = "no"
module_upnp_enabled = "no"
module_visual_script_enabled = "no"
module_vorbis_enabled = "yes"
module_webm_enabled = "yes"
module_webp_enabled = "no"
```



## Folder structure


```
│   manifest.vrmanifest
│   openvr_api.dll
│   owoTrackOverlay.exe
│   owoTrackOverlay.pck
│
├───driver
│   │   driver.vrdrivermanifest
│   │
│   ├───bin
│   │   ├───win32
│   │   │       driver_owoTrack.dll
│   │   │
│   │   └───win64
│   │           driver_owoTrack.dll
│   │
│   └───resources
│       │   driver.vrresources
│       │
│       └───input
│               remote_profile.json
│
└───GDN_bin
        GDN.dll
```

driver.vrdrivermanifest and the files in the resources folder are obtained from https://github.com/abb128/owo-track-driver/tree/main/extras

owoTrackOverlay.exe and owoTrackOverlay.pck are exported from Godot.

openvr_api.dll is obtained from https://github.com/ValveSoftware/openvr/blob/master/bin/win64/openvr_api.dll

GDN_bin/GDN.dll must match the one you built. By default, Godot will export the .dll to the root of the folder, but you need to move it to a folder called GDN_bin

Files in driver/bin are built from https://github.com/abb128/owo-track-driver

