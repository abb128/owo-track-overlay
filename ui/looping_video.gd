extends VideoPlayer

func start_playing():
	stream_position = 0.0;
	if(is_visible_in_tree()):
		play();
	else:
		stop();

func on_vis_change():
	start_playing();

func _ready():
	start_playing();
	connect("finished", self, "start_playing");
	connect("visibility_changed", self, "on_vis_change");
