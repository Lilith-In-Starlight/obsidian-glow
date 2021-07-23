extends Control

const NOTCH := preload("res://HUD/AbilityNotch.tscn")

onready var Abilities := $Abilities
onready var CenterNotch := $Abilities/Center


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in Persistent.notches:
		var new_notch := NOTCH.instance()
		new_notch.rect_position = CenterNotch.rect_position + Vector2(cos(i*TAU/Persistent.notches), sin(i*TAU/Persistent.notches)) * 60
		Abilities.add_child(new_notch)
		new_notch.notch = i


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

