extends Sprite

enum TYPES {
	REGULAR,
	SPIKE,
}

onready var Player := $"../../Neptune"

export(TYPES) var bench_place

var HUD


func _ready():
	HUD = get_tree().get_nodes_in_group("hud")[0]
	match bench_place:
		TYPES.SPIKE:
			texture = preload("res://Sprites/Elements/SpikeBench.png")


func _process(delta):
	if Player.position.distance_to(position) < 30:
		Persistent.near_bench = true
		Player.last_safe_pos = Player.position
		if Player.move_up:
			Persistent.health = 6
			Persistent.player_pos = Player.position
			Persistent.save()
			Persistent.killed = []
			if Persistent.got_diary and not Persistent.recently_collected.empty():
				Persistent.diary.append_array(Persistent.recently_collected)
				print(Persistent.recently_collected, " ", Persistent.diary)
				Persistent.recently_collected = []
				HUD.call("diary_updated")
	else:
		Persistent.near_bench = false
