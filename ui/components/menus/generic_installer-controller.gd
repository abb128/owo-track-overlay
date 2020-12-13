extends Node

export var db_path: NodePath;
onready var db = get_node(db_path);

export var installer_path: NodePath;
onready var installer = get_node(installer_path);

export var install_uninstall_container: NodePath;
onready var iucont = get_node(install_uninstall_container);

export var mismatch_version_path: NodePath;
onready var mismatch_version = get_node(mismatch_version_path);


onready var owoIPC: OwoIPC = get_node("/root/owoIPCSingleton");

func install() -> void:
	print("Install");
	installer.install();
	pass;

func uninstall() -> void:
	print("Uninstall");
	installer.uninstall();
	pass;

func _process(_d: float) -> void:
	db.driver_active = owoIPC.version_received;
	db.driver_version_matches = owoIPC.version_matches;
	
	if(db.driver_active && !db.driver_version_matches):
		mismatch_version.srv_version = owoIPC.SERVER_VERSION;
		mismatch_version.cli_version = owoIPC.CLIENT_VERSION;
	


func initialize() -> void:
	db.driver_installed = installer.is_driver_installed();
	set_process(db.driver_installed);

func make_connections() -> void:
	iucont.get_node("install").get_child(0).connect("pressed", self, "install");
	iucont.get_node("uninstall").get_child(0).connect("pressed", self, "uninstall");

func _ready() -> void:
	make_connections();
	initialize();
