extends Node


var entered_from := "Field/Feld.tscn" # Where the player came from in a scene transition

# Subway tickets
var abandoned_ticket := false 

# Abilities
var notches := 2
var abilities := ["", "dash"]
var notch_fillers := []
var notch_keys := []

# The animation the player is doing that removes control from the player
var player_cutscene := "no"

var SChangeTimer := Timer.new() # Takes time to change the scene
var next_scene # Where is the player going

func _init():
	for i in notches:
		notch_fillers.append("")
		notch_keys.append(-1)

func _ready():
	# Set up the timer for the scene changes
	SChangeTimer.wait_time = 0.35
	SChangeTimer.connect("timeout", self, "change_time")
	SChangeTimer.one_shot = true
	add_child(SChangeTimer)

func change_time():
	get_tree().change_scene_to(next_scene)
