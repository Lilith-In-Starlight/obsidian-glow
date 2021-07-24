extends Area2D

enum DIRS {
	LEFT,
	RIGHT,
}

export var newScene:String
export(DIRS) var enter_dir = DIRS.LEFT
onready var Player := $"../Neptune"
var scene
var can_enter := true


func _ready():
	scene = load("res://Areas/" + newScene + ".tscn")
	if newScene == Persistent.entered_from:
		can_enter = false
		Player.position = position
		match enter_dir:
			DIRS.LEFT:
				Persistent.player_cutscene = "enter_r"
			DIRS.RIGHT:
				Persistent.player_cutscene = "enter_l"


func _on_body_entered(body):
	if body.name == "Neptune" and can_enter:
		Persistent.entered_from = get_tree().current_scene.filename.replace("res://Areas/", "").replace(".tscn", "")
		print(Persistent.entered_from)
		Persistent.next_scene = scene
		Persistent.SChangeTimer.start()
		match enter_dir:
			DIRS.LEFT:
				Persistent.player_cutscene = "leave_l"
			DIRS.RIGHT:
				Persistent.player_cutscene = "leave_r"


func _on_body_exited(body):
	if body.name == "Neptune":
		can_enter = true
		Persistent.player_cutscene = "no"
