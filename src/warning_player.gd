extends Node

const WARNING_BELL := preload("res://assets/warning_sounds/bell.wav");

const WARNING_VOICES := [
	preload("res://assets/warning_sounds/voice1.wav"),
	preload("res://assets/warning_sounds/voice2.wav"),
	preload("res://assets/warning_sounds/voice3.wav"),
	preload("res://assets/warning_sounds/voice4.wav"),
	preload("res://assets/warning_sounds/voice5.wav")
];


func _create_player(stream: AudioStream) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new();
	player.stream = stream;
	add_child(player);
	return player;


var warning_bell: AudioStreamPlayer = null;
var warning_voices := [];

func _ready():
	warning_bell = _create_player(WARNING_BELL);
	
	for VOICE in WARNING_VOICES:
		var voice := _create_player(VOICE);
		voice.volume_db = -6.0;
		
		warning_voices.append(voice);


func warn():
	warning_bell.play();
	yield(get_tree().create_timer(0.5), "timeout");
	var voice: AudioStreamPlayer \
		 = warning_voices[randi() % warning_voices.size()];
	
	voice.play(0);
