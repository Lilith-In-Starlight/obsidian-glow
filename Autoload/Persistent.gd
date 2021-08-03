extends Node


var entered_from := "Field/Feld.tscn" # Where the player came from in a scene transition

# Subway tickets
var abandoned_ticket := false 

# Abilities
var notches := 2
var abilities := [""]
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
var death_load := false

var loaded_scene := ""

var max_health := 6
var health := 6
var shadow := 0.0
var persands := 0

var outskirts_arena := false

var Env := Environment.new()
var WEnv := WorldEnvironment.new()

var got_diary := false

var ident := 0
var diary_page := 0

var diary := ["diary_opening"]
var recently_collected := []

func _init():
	for i in notches:
		notch_fillers.append("")
		notch_keys.append(-1)

var near_bench := false


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	print("ready!")
	Env.background_mode = Environment.BG_CANVAS
	Env.adjustment_enabled = true
	WEnv.environment = Env
	add_child(WEnv)
	# Set up the timer for the scene changes
	SChangeTimer.wait_time = 0.35
	SChangeTimer.connect("timeout", self, "change_time")
	SChangeTimer.one_shot = true
	add_child(SChangeTimer)
	
	# Load the settings and the save
	var err_save := Savefile.load("user://savefile.and")
	var err_settings := Settings.load("user://settings.and")
	
	if err_save == OK:
		load_()
	
	if err_settings == OK:
		Env.adjustment_brightness = Settings.get_value("video", "brigthess", 1.0)
		Env.adjustment_saturation = Settings.get_value("video", "saturation", 1.0)
		Env.adjustment_contrast =  Settings.get_value("video", "contrast", 1.0)


#  When the scene is ready to change
func change_time():
	get_tree().change_scene_to(next_scene)


# Load the files
func load_():
	entered_from = "Field/Feld.tscn"
	loaded_scene = Savefile.get_value("player", "current_scene", "") as String
	player_pos = Savefile.get_value("player", "position", Vector2(0, 0)) as Vector2
	persands = Savefile.get_value("player", "persands", 0) as int
	max_health = Savefile.get_value("player", "max_health", 6) as int
	shadow = Savefile.get_value("player", "shadow", 0.0) as float
	
	notches = Savefile.get_value("abilities", "notches", 2) as int
	abilities = Savefile.get_value("abilities", "abilities", [""]) as Array
	notch_fillers = Savefile.get_value("abilities", "fillers", []) as Array
	notch_keys = Savefile.get_value("abilities", "keys", []) as Array
	
	abandoned_ticket = Savefile.get_value("subway", "abandoned", false) as bool
	
	outskirts_arena = Savefile.get_value("outskirts", "arena", false) as bool
	
	got_diary = Savefile.get_value("items", "diary", false) as bool
	
	diary = Savefile.get_value("diary", "diary", ["diary_opening"]) as Array
	diary_page = Savefile.get_value("diary", "current_page", 0) as int
	
	if abilities.has("dash") and not outskirts_arena:
		abilities = [""]
	
	for i in notches:
		notch_fillers.append("")
		notch_keys.append(-1)

func save(game:bool = true):
	loaded_scene = get_tree().current_scene.filename
	if game:
		Savefile.set_value("player", "current_scene", get_tree().current_scene.filename)
	else:
		Savefile.set_value("player", "current_scene", "")
	Savefile.set_value("player", "position", player_pos)
	Savefile.set_value("player", "persands", persands)
	Savefile.set_value("player", "max_health", max_health)
	Savefile.set_value("player", "shadow", shadow)
	
	Savefile.set_value("abilities", "notches", notches)
	Savefile.set_value("abilities", "abilities", abilities)
	Savefile.set_value("abilities", "fil lers", notch_fillers)
	Savefile.set_value("abilities", "keys", notch_keys)
	
	Savefile.set_value("subway", "abandoned", abandoned_ticket)
	
	Savefile.set_value("outskirts", "arena", outskirts_arena)
	
	Savefile.set_value("items", "diary", got_diary)
	
	Savefile.set_value("diary", "diary", diary)
	Savefile.set_value("diary", "current_page", diary_page)
	
	Savefile.save("user://savefile.and")
	
func save_settings():
	Settings.set_value("video", "brigthess", Env.adjustment_brightness)
	Settings.set_value("video", "saturation", Env.adjustment_saturation)
	Settings.set_value("video", "contrast", Env.adjustment_contrast)
	Settings.save("user://settings.and")
