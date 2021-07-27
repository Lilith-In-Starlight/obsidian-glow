extends Sprite


onready var Player := $"../../Neptune"

func _process(delta):
	if Player.move_up and Player.position.distance_to(position) <  30:
		Persistent.player_pos = Player.position
		Persistent.save()
