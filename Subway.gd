extends AnimatedSprite

enum AREAS {
	FIELD,
	OUTSKIRTS,
}

export var destination := ""
export(AREAS) var area := AREAS.FIELD
onready var Player := $"../Neptune"
var scenedest

func _ready():
	scenedest = load("res://Areas/" + destination + ".tscn")
	if destination == Persistent.entered_from:
		Player.position = position + Vector2(5,20)

func _process(delta):
	if Player.position.distance_to(position) < 30 and Player.speed.length() < 2:
		match area:
			AREAS.FIELD, AREAS.OUTSKIRTS:
				if Persistent.abandoned_ticket and Player.move_up:
					playb("open")
					Player.cutscene = "nomove"

func playb(anim:String):
	if animation != anim:
		play(anim)


func _on_animation_finished():
	match animation:
		"open":
			Player.position = position + Vector2(5,20)
			Player.cutscene = "train"
			playb("close")
		"close":
			playb("weka")
		"weka":
			Persistent.entered_from = get_tree().current_scene.filename.replace("res://Areas/", "").replace(".tscn", "")
			get_tree().change_scene_to(scenedest)
