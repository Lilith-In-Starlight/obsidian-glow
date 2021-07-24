extends Sprite


onready var Player := $"../../Neptune"

func _process(delta):
	if Player.move_up:
		Persistent.player_pos = Player.position
		Persistent.save()
