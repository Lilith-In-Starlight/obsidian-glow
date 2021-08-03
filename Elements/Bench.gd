extends Sprite


onready var Player := $"../../Neptune"

var HUD


func _ready():
	HUD = get_tree().get_nodes_in_group("hud")[0]


func _process(delta):
	if Player.position.distance_to(position) < 30:
		Persistent.near_bench = true
		Player.last_safe_pos = Player.position
		if Player.move_up:
			Persistent.health = 6
			Persistent.player_pos = Player.position
			Persistent.save()
			if Persistent.got_diary and not Persistent.recently_collected.empty():
				Persistent.diary.append_array(Persistent.recently_collected)
				print(Persistent.recently_collected, " ", Persistent.diary)
				Persistent.recently_collected = []
				HUD.call("diary_updated")
	else:
		Persistent.near_bench = false
