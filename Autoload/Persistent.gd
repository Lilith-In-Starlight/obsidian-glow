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
var Settings := ConfigFile.new()

var player_pos := Vector2(0, 0)

var first_load := true

var loaded_scene := ""

var max_health := 6
var health := 6
var shadow := 0.0


var Env := Environment.new()
var WEnv := WorldEnvironment.new()

func _init():
	for i in notches:
		notch_fillers.append("")
		notch_keys.append(-1)


func _ready():
	Env.background_mode = Environment.BG_CANVAS
	Env.adjustment_enabled = true
	WEnv.environment = Env
	add_child(WEnv)
	# Set up the timer for the scene changes
	SChangeTimer.wait_time = 0.35
	SChangeTimer.connect("timeout", self, "change_time")
	SChangeTimer.one_shot = true
	add_child(SChangeTimer)
	var err_save := Savefile.load("user://savefile.and")
	var err_settings := Settings.load("user://settings.and")
	
	if err_save == OK:
		loaded_scene = Savefile.get_value("player", "current_scene", "") as String
		player_pos = Savefile.get_value("player", "position", Vector2(0, 0)) as Vector2
		notches = Savefile.get_value("abilities", "notches", 2) as int
		
		abilities = Savefile.get_value("abilities", "abilities", [""]) as Array
		notch_fillers = Savefile.get_value("abilities", "fillers", []) as Array
		notch_keys = Savefile.get_value("abilities", "keys", []) as Array
		
		abandoned_ticket = Savefile.get_value("subway", "abandoned", false) as bool
	
	if err_settings == OK:
		Env.adjustment_brightness = Settings.get_value("video", "brigthess", 1.0)
		Env.adjustment_saturation = Settings.get_value("video", "saturation", 1.0)
		Env.adjustment_contrast =  Settings.get_value("video", "contrast", 1.0)


func change_time():
	get_tree().change_scene_to(next_scene)


func save():
	loaded_scene = get_tree().current_scene.filename
	Savefile.set_value("player", "current_scene", get_tree().current_scene.filename)
	Savefile.set_value("player", "position", player_pos)
	
	Savefile.set_value("abilities", "notches", notches)
	Savefile.set_value("abilities", "abilities", abilities)
	Savefile.set_value("abilities", "fil lers", notch_fillers)
	Savefile.set_value("abilities", "keys", notch_keys)
	
	Savefile.set_value("subway", "abandoned", abandoned_ticket)
	Savefile.save("user://savefile.and")
	
func save_settings():
	Settings.set_value("video", "brigthess", Env.adjustment_brightness)
	Settings.set_value("video", "saturation", Env.adjustment_saturation)
	Settings.set_value("video", "contrast", Env.adjustment_contrast)
	Settings.save("user://settings.and")
