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

var Savefile := ConfigFile.new()

var player_pos := Vector2(0, 0)

var first_load := true

var loaded_scene := ""


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
	var err := Savefile.load("user://savefile.and")
	
	if err == OK:
		loaded_scene = Savefile.get_value("player", "current_scene", "") as String
		player_pos = Savefile.get_value("player", "position", Vector2(0, 0)) as Vector2
		notches = Savefile.get_value("abilities", "notches", 2) as int
		
		abilities = Savefile.get_value("abilities", "abilities", [""]) as Array
		notch_fillers = Savefile.get_value("abilities", "fillers", []) as Array
		notch_keys = Savefile.get_value("abilities", "keys", []) as Array
		
		abandoned_ticket = Savefile.get_value("subway", "abandoned", false) as bool


func change_time():
	get_tree().change_scene_to(next_scene)


func save():
	Savefile.set_value("player", "current_scene", get_tree().current_scene.filename)
	Savefile.set_value("player", "position", player_pos)
	
	Savefile.set_value("abilities", "notches", notches)
	Savefile.set_value("abilities", "abilities", abilities)
	Savefile.set_value("abilities", "fil lers", notch_fillers)
	Savefile.set_value("abilities", "keys", notch_keys)
	
	Savefile.set_value("subway", "abandoned", abandoned_ticket) 
	Savefile.save("user://savefile.and")
