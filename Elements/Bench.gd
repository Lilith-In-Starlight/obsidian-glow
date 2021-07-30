extends Sprite


onready var Player := $"../../Neptune"

func _process(delta):
	if Player.position.distance_to(position) < 30:
		Persistent.near_bench = true
		Player.last_safe_pos = Player.position
		if Player.move_up:
			Persistent.health = 6
			Persistent.player_pos = Player.position
			Persistent.save()
	else:
		Persistent.near_bench = false
