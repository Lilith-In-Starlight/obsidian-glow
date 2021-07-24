extends Node


var entered_from := "Field/Feld.tscn"

var abandoned_ticket := false

var notches := 2
var abilities := ["", "dash"]
var notch_fillers := []
var notch_keys := []

var player_cutscene := "no"

var SChangeTimer := Timer.new()
var next_scene

func _init():
	for i in notches:
		notch_fillers.append("")
		notch_keys.append(-1)

func _ready():
	SChangeTimer.wait_time = 0.35
	SChangeTimer.connect("timeout", self, "change_time")
	SChangeTimer.one_shot = true
	add_child(SChangeTimer)

func change_time():
	get_tree().change_scene_to(next_scene)
