extends Node2D

const Near := preload("res://Sprites/Enemies/SpikeGuardian/idle-look_down.png")
const Normal := preload("res://Sprites/Enemies/SpikeGuardian/idle.png")

export var dialogue := ""
export var default_scale := 1

onready var Spr := $Sprite
onready var DiaObject := $DialogueObject

var Player

func _ready():
	Player = get_tree().get_nodes_in_group("player")[0]
	DiaObject.down_action = dialogue
	if dialogue == "":
		DiaObject.queue_free()

func _process(delta):
	if Player.position.distance_to(position) < 50:
		Spr.texture = Near
		if Player.position.x > position.x:
			Spr.scale.x = -1
		else:
			Spr.scale.x = 1
	else:
		Spr.texture = Normal
		Spr.scale.x = default_scale
