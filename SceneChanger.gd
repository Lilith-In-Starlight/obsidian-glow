extends Area2D

export var newScene:String
onready var Player := $"../Neptune"
var scene
var can_enter := true


func _ready():
	scene = load("res://Areas/" + newScene + ".tscn")
	if newScene == Persistent.entered_from:
		can_enter = false
		Player.position = position


func _on_body_entered(body):
	if body.name == "Neptune" and can_enter:
		Persistent.entered_from = get_tree().current_scene.filename.replace("res://Areas/", "").replace(".tscn", "")
		print(Persistent.entered_from)
		get_tree().change_scene_to(scene)


func _on_body_exited(body):
	if body.name == "Neptune":
		can_enter = true
