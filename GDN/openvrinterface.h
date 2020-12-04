#pragma once

#include "openvr.h"
#include <Godot.hpp>
#include <Reference.hpp>

using namespace godot;

class TrackedDevice : public Reference {
	GODOT_CLASS(TrackedDevice, Reference)
private:
	vr::TrackedDeviceIndex_t deviceIdx;

public:

	void _init();

	uint64_t get_id();
	void set_id(uint64_t idx);

	enum DeviceClass
	{
		TrackedDeviceClass_Invalid = 0,				// the ID was not valid.
		TrackedDeviceClass_HMD = 1,					// Head-Mounted Displays
		TrackedDeviceClass_Controller = 2,			// Tracked controllers
		TrackedDeviceClass_GenericTracker = 3,		// Generic trackers, similar to controllers
		TrackedDeviceClass_TrackingReference = 4,	// Camera and base stations that serve as tracking reference points
		TrackedDeviceClass_DisplayRedirect = 5,		// Accessories that aren't necessarily tracked themselves, but may redirect video output from other tracked devices

		TrackedDeviceClass_Max
	};
	enum DeviceProperty {
		Prop_Invalid = 0,

		// general properties that apply to all device classes
		Prop_TrackingSystemName_String = 1000,
		Prop_ModelNumber_String = 1001,
		Prop_SerialNumber_String = 1002,
		Prop_RenderModelName_String = 1003,
		Prop_WillDriftInYaw_Bool = 1004,
		Prop_ManufacturerName_String = 1005,
		Prop_TrackingFirmwareVersion_String = 1006,
		Prop_HardwareRevision_String = 1007,
		Prop_AllWirelessDongleDescriptions_String = 1008,
		Prop_ConnectedWirelessDongle_String = 1009,
		Prop_DeviceIsWireless_Bool = 1010,
		Prop_DeviceIsCharging_Bool = 1011,
		Prop_DeviceBatteryPercentage_Float = 1012, // 0 is empty, 1 is full
		Prop_StatusDisplayTransform_Matrix34 = 1013,
		Prop_Firmware_UpdateAvailable_Bool = 1014,
		Prop_Firmware_ManualUpdate_Bool = 1015,
		Prop_Firmware_ManualUpdateURL_String = 1016,
		Prop_HardwareRevision_Uint64 = 1017,
		Prop_FirmwareVersion_Uint64 = 1018,
		Prop_FPGAVersion_Uint64 = 1019,
		Prop_VRCVersion_Uint64 = 1020,
		Prop_RadioVersion_Uint64 = 1021,
		Prop_DongleVersion_Uint64 = 1022,
		Prop_BlockServerShutdown_Bool = 1023,
		Prop_CanUnifyCoordinateSystemWithHmd_Bool = 1024,
		Prop_ContainsProximitySensor_Bool = 1025,
		Prop_DeviceProvidesBatteryStatus_Bool = 1026,
		Prop_DeviceCanPowerOff_Bool = 1027,
		Prop_Firmware_ProgrammingTarget_String = 1028,
		Prop_DeviceClass_Int32 = 1029,
		Prop_HasCamera_Bool = 1030,
		Prop_DriverVersion_String = 1031,
		Prop_Firmware_ForceUpdateRequired_Bool = 1032,
		Prop_ViveSystemButtonFixRequired_Bool = 1033,
		Prop_ParentDriver_Uint64 = 1034,
		Prop_ResourceRoot_String = 1035,
		Prop_RegisteredDeviceType_String = 1036,
		Prop_InputProfilePath_String = 1037, // input profile to use for this device in the input system. Will default to tracking system name if this isn't provided
		Prop_NeverTracked_Bool = 1038, // Used for devices that will never have a valid pose by design
		Prop_NumCameras_Int32 = 1039,
		Prop_CameraFrameLayout_Int32 = 1040, // EVRTrackedCameraFrameLayout value
		Prop_CameraStreamFormat_Int32 = 1041, // ECameraVideoStreamFormat value
		Prop_AdditionalDeviceSettingsPath_String = 1042, // driver-relative path to additional device and global configuration settings
		Prop_Identifiable_Bool = 1043, // Whether device supports being identified from vrmonitor (e.g. blink LED, vibrate haptics, etc)
		Prop_BootloaderVersion_Uint64 = 1044,
		Prop_AdditionalSystemReportData_String = 1045, // additional string to include in system reports about a tracked device
		Prop_CompositeFirmwareVersion_String = 1046, // additional FW components from a device that gets propagated into reports
		Prop_Firmware_RemindUpdate_Bool = 1047,
		Prop_PeripheralApplicationVersion_Uint64 = 1048,
		Prop_ManufacturerSerialNumber_String = 1049,
		Prop_ComputedSerialNumber_String = 1050,
		Prop_EstimatedDeviceFirstUseTime_Int32 = 1051,

		// Properties that are unique to TrackedDeviceClass_HMD
		Prop_ReportsTimeSinceVSync_Bool = 2000,
		Prop_SecondsFromVsyncToPhotons_Float = 2001,
		Prop_DisplayFrequency_Float = 2002,
		Prop_UserIpdMeters_Float = 2003,
		Prop_CurrentUniverseId_Uint64 = 2004,
		Prop_PreviousUniverseId_Uint64 = 2005,
		Prop_DisplayFirmwareVersion_Uint64 = 2006,
		Prop_IsOnDesktop_Bool = 2007,
		Prop_DisplayMCType_Int32 = 2008,
		Prop_DisplayMCOffset_Float = 2009,
		Prop_DisplayMCScale_Float = 2010,
		Prop_EdidVendorID_Int32 = 2011,
		Prop_DisplayMCImageLeft_String = 2012,
		Prop_DisplayMCImageRight_String = 2013,
		Prop_DisplayGCBlackClamp_Float = 2014,
		Prop_EdidProductID_Int32 = 2015,
		Prop_CameraToHeadTransform_Matrix34 = 2016,
		Prop_DisplayGCType_Int32 = 2017,
		Prop_DisplayGCOffset_Float = 2018,
		Prop_DisplayGCScale_Float = 2019,
		Prop_DisplayGCPrescale_Float = 2020,
		Prop_DisplayGCImage_String = 2021,
		Prop_LensCenterLeftU_Float = 2022,
		Prop_LensCenterLeftV_Float = 2023,
		Prop_LensCenterRightU_Float = 2024,
		Prop_LensCenterRightV_Float = 2025,
		Prop_UserHeadToEyeDepthMeters_Float = 2026,
		Prop_CameraFirmwareVersion_Uint64 = 2027,
		Prop_CameraFirmwareDescription_String = 2028,
		Prop_DisplayFPGAVersion_Uint64 = 2029,
		Prop_DisplayBootloaderVersion_Uint64 = 2030,
		Prop_DisplayHardwareVersion_Uint64 = 2031,
		Prop_AudioFirmwareVersion_Uint64 = 2032,
		Prop_CameraCompatibilityMode_Int32 = 2033,
		Prop_ScreenshotHorizontalFieldOfViewDegrees_Float = 2034,
		Prop_ScreenshotVerticalFieldOfViewDegrees_Float = 2035,
		Prop_DisplaySuppressed_Bool = 2036,
		Prop_DisplayAllowNightMode_Bool = 2037,
		Prop_DisplayMCImageWidth_Int32 = 2038,
		Prop_DisplayMCImageHeight_Int32 = 2039,
		Prop_DisplayMCImageNumChannels_Int32 = 2040,
		Prop_DisplayMCImageData_Binary = 2041,
		Prop_SecondsFromPhotonsToVblank_Float = 2042,
		Prop_DriverDirectModeSendsVsyncEvents_Bool = 2043,
		Prop_DisplayDebugMode_Bool = 2044,
		Prop_GraphicsAdapterLuid_Uint64 = 2045,
		Prop_DriverProvidedChaperonePath_String = 2048,
		Prop_ExpectedTrackingReferenceCount_Int32 = 2049, // expected number of sensors or basestations to reserve UI space for
		Prop_ExpectedControllerCount_Int32 = 2050, // expected number of tracked controllers to reserve UI space for
		Prop_NamedIconPathControllerLeftDeviceOff_String = 2051, // placeholder icon for "left" controller if not yet detected/loaded
		Prop_NamedIconPathControllerRightDeviceOff_String = 2052, // placeholder icon for "right" controller if not yet detected/loaded
		Prop_NamedIconPathTrackingReferenceDeviceOff_String = 2053, // placeholder icon for sensor/base if not yet detected/loaded
		Prop_DoNotApplyPrediction_Bool = 2054, // currently no effect. was used to disable HMD pose prediction on MR, which is now done by MR driver setting velocity=0
		Prop_CameraToHeadTransforms_Matrix34_Array = 2055,
		Prop_DistortionMeshResolution_Int32 = 2056, // custom resolution of compositor calls to IVRSystem::ComputeDistortion
		Prop_DriverIsDrawingControllers_Bool = 2057,
		Prop_DriverRequestsApplicationPause_Bool = 2058,
		Prop_DriverRequestsReducedRendering_Bool = 2059,
		Prop_MinimumIpdStepMeters_Float = 2060,
		Prop_AudioBridgeFirmwareVersion_Uint64 = 2061,
		Prop_ImageBridgeFirmwareVersion_Uint64 = 2062,
		Prop_ImuToHeadTransform_Matrix34 = 2063,
		Prop_ImuFactoryGyroBias_Vector3 = 2064,
		Prop_ImuFactoryGyroScale_Vector3 = 2065,
		Prop_ImuFactoryAccelerometerBias_Vector3 = 2066,
		Prop_ImuFactoryAccelerometerScale_Vector3 = 2067,
		// reserved 2068
		Prop_ConfigurationIncludesLighthouse20Features_Bool = 2069,
		Prop_AdditionalRadioFeatures_Uint64 = 2070,
		Prop_CameraWhiteBalance_Vector4_Array = 2071, // Prop_NumCameras_Int32-sized array of float[4] RGBG white balance calibration data (max size is vr::k_unMaxCameras)
		Prop_CameraDistortionFunction_Int32_Array = 2072, // Prop_NumCameras_Int32-sized array of vr::EVRDistortionFunctionType values (max size is vr::k_unMaxCameras)
		Prop_CameraDistortionCoefficients_Float_Array = 2073, // Prop_NumCameras_Int32-sized array of double[vr::k_unMaxDistortionFunctionParameters] (max size is vr::k_unMaxCameras)
		Prop_ExpectedControllerType_String = 2074,
		Prop_HmdTrackingStyle_Int32 = 2075, // one of EHmdTrackingStyle
		Prop_DriverProvidedChaperoneVisibility_Bool = 2076,
		Prop_HmdColumnCorrectionSettingPrefix_String = 2077,
		Prop_CameraSupportsCompatibilityModes_Bool = 2078,
		Prop_SupportsRoomViewDepthProjection_Bool = 2079,
		Prop_DisplayAvailableFrameRates_Float_Array = 2080, // populated by compositor from actual EDID list when available from GPU driver
		Prop_DisplaySupportsMultipleFramerates_Bool = 2081, // if this is true but Prop_DisplayAvailableFrameRates_Float_Array is empty, explain to user
		Prop_DisplayColorMultLeft_Vector3 = 2082,
		Prop_DisplayColorMultRight_Vector3 = 2083,
		Prop_DisplaySupportsRuntimeFramerateChange_Bool = 2084,
		Prop_DisplaySupportsAnalogGain_Bool = 2085,
		Prop_DisplayMinAnalogGain_Float = 2086,
		Prop_DisplayMaxAnalogGain_Float = 2087,

		// Prop_DashboardLayoutPathName_String 		= 2090, // DELETED
		Prop_DashboardScale_Float = 2091,
		Prop_IpdUIRangeMinMeters_Float = 2100,
		Prop_IpdUIRangeMaxMeters_Float = 2101,

		// Driver requested mura correction properties
		Prop_DriverRequestedMuraCorrectionMode_Int32 = 2200,
		Prop_DriverRequestedMuraFeather_InnerLeft_Int32 = 2201,
		Prop_DriverRequestedMuraFeather_InnerRight_Int32 = 2202,
		Prop_DriverRequestedMuraFeather_InnerTop_Int32 = 2203,
		Prop_DriverRequestedMuraFeather_InnerBottom_Int32 = 2204,
		Prop_DriverRequestedMuraFeather_OuterLeft_Int32 = 2205,
		Prop_DriverRequestedMuraFeather_OuterRight_Int32 = 2206,
		Prop_DriverRequestedMuraFeather_OuterTop_Int32 = 2207,
		Prop_DriverRequestedMuraFeather_OuterBottom_Int32 = 2208,

		Prop_Audio_DefaultPlaybackDeviceId_String = 2300,
		Prop_Audio_DefaultRecordingDeviceId_String = 2301,
		Prop_Audio_DefaultPlaybackDeviceVolume_Float = 2302,
		Prop_Audio_SupportsDualSpeakerAndJackOutput_Bool = 2303,

		// Properties that are unique to TrackedDeviceClass_Controller
		Prop_AttachedDeviceId_String = 3000,
		Prop_SupportedButtons_Uint64 = 3001,
		Prop_Axis0Type_Int32 = 3002, // Return value is of type EVRControllerAxisType
		Prop_Axis1Type_Int32 = 3003, // Return value is of type EVRControllerAxisType
		Prop_Axis2Type_Int32 = 3004, // Return value is of type EVRControllerAxisType
		Prop_Axis3Type_Int32 = 3005, // Return value is of type EVRControllerAxisType
		Prop_Axis4Type_Int32 = 3006, // Return value is of type EVRControllerAxisType
		Prop_ControllerRoleHint_Int32 = 3007, // Return value is of type ETrackedControllerRole

		// Properties that are unique to TrackedDeviceClass_TrackingReference
		Prop_FieldOfViewLeftDegrees_Float = 4000,
		Prop_FieldOfViewRightDegrees_Float = 4001,
		Prop_FieldOfViewTopDegrees_Float = 4002,
		Prop_FieldOfViewBottomDegrees_Float = 4003,
		Prop_TrackingRangeMinimumMeters_Float = 4004,
		Prop_TrackingRangeMaximumMeters_Float = 4005,
		Prop_ModeLabel_String = 4006,
		Prop_CanWirelessIdentify_Bool = 4007, // volatile, based on radio presence and fw discovery
		Prop_Nonce_Int32 = 4008,

		// Properties that are used for user interface like icons names
		Prop_IconPathName_String = 5000, // DEPRECATED. Value not referenced. Now expected to be part of icon path properties.
		Prop_NamedIconPathDeviceOff_String = 5001, // {driver}/icons/icon_filename - PNG for static icon, or GIF for animation, 50x32 for headsets and 32x32 for others
		Prop_NamedIconPathDeviceSearching_String = 5002, // {driver}/icons/icon_filename - PNG for static icon, or GIF for animation, 50x32 for headsets and 32x32 for others
		Prop_NamedIconPathDeviceSearchingAlert_String = 5003, // {driver}/icons/icon_filename - PNG for static icon, or GIF for animation, 50x32 for headsets and 32x32 for others
		Prop_NamedIconPathDeviceReady_String = 5004, // {driver}/icons/icon_filename - PNG for static icon, or GIF for animation, 50x32 for headsets and 32x32 for others
		Prop_NamedIconPathDeviceReadyAlert_String = 5005, // {driver}/icons/icon_filename - PNG for static icon, or GIF for animation, 50x32 for headsets and 32x32 for others
		Prop_NamedIconPathDeviceNotReady_String = 5006, // {driver}/icons/icon_filename - PNG for static icon, or GIF for animation, 50x32 for headsets and 32x32 for others
		Prop_NamedIconPathDeviceStandby_String = 5007, // {driver}/icons/icon_filename - PNG for static icon, or GIF for animation, 50x32 for headsets and 32x32 for others
		Prop_NamedIconPathDeviceAlertLow_String = 5008, // {driver}/icons/icon_filename - PNG for static icon, or GIF for animation, 50x32 for headsets and 32x32 for others
		Prop_NamedIconPathDeviceStandbyAlert_String = 5009, // {driver}/icons/icon_filename - PNG for static icon, or GIF for animation, 50x32 for headsets and 32x32 for others

		// Properties that are used by helpers, but are opaque to applications
		Prop_DisplayHiddenArea_Binary_Start = 5100,
		Prop_DisplayHiddenArea_Binary_End = 5150,
		Prop_ParentContainer = 5151,
		Prop_OverrideContainer_Uint64 = 5152,

		// Properties that are unique to drivers
		Prop_UserConfigPath_String = 6000,
		Prop_InstallPath_String = 6001,
		Prop_HasDisplayComponent_Bool = 6002,
		Prop_HasControllerComponent_Bool = 6003,
		Prop_HasCameraComponent_Bool = 6004,
		Prop_HasDriverDirectModeComponent_Bool = 6005,
		Prop_HasVirtualDisplayComponent_Bool = 6006,
		Prop_HasSpatialAnchorsSupport_Bool = 6007,

		// Properties that are set internally based on other information provided by drivers
		Prop_ControllerType_String = 7000,
		//Prop_LegacyInputProfile_String				= 7001, // This is no longer used. See "legacy_binding" in the input profile instead.
		Prop_ControllerHandSelectionPriority_Int32 = 7002, // Allows hand assignments to prefer some controllers over others. High numbers are selected over low numbers

		// Vendors are free to expose private debug data in this reserved region
		Prop_VendorSpecific_Reserved_Start = 10000,
		Prop_VendorSpecific_Reserved_End = 10999,

		Prop_TrackedDeviceProperty_Max = 1000000,
	};


	static void _register_methods();

	DeviceClass get_device_class();

	String get_string_property(uint64_t prop);
	bool get_bool_property(uint64_t prop);
	real_t get_float_property(uint64_t prop);

	PoolByteArray send_message(PoolByteArray input);

	bool is_initialized();
};

class OpenVRInterface : public Reference {
	GODOT_CLASS(OpenVRInterface, Reference)
private:
public:
	void _init();
	void add_manifest(String full_path, bool temporary);
	void remove_manifest(String full_path);
	bool is_installed(String key);
	void set_auto_launch(String key, bool v);
	bool is_initialized();

	String get_runtime_path();

	static void _register_methods();

};
