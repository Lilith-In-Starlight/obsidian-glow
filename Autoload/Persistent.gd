extends Node


var mask_textures := {
	"none": preload("res://Sprites/HUD/Masks/Place.png"),
	"survivor": preload("res://Sprites/HUD/Masks/Survivor.png"),
	"beauty": preload("res://Sprites/HUD/Masks/Beauty.png"),
	"maskmaker": preload("res://Sprites/HUD/Masks/Maskmaker.png"),
	"brittle": preload("res://Sprites/HUD/Masks/Brittle.png"),
}


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

var current_save := "user://savefile.and"
var save_name := ""

var masks := []
var masks_wearing := []
var faces := 2

var fullscreen := true

var met_the_gardeners := false

var jump_tutorial := false
var attack_tutorial := false
var heal_tutorial := false

var beat_the_gardeners := false


func _init():
	for i in notches:
		if notch_fillers.size() < notches:
			notch_fillers.append("")
		if notch_keys.size() < notches:
			notch_keys.append(-1)
	
	for i in faces:
		if masks_wearing.size() < faces:
			masks_wearing.append("none")

var near_bench := false

var killed := []


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	print("ready!")
	Env.background_mode = Environment.BG_CANVAS
	Env.adjustment_enabled = true
	WEnv.environment = Env
	add_child(WEnv)
	# Set up the timer for the scene changes
	add_child(SChangeTimer)
	SChangeTimer.wait_time = 0.35
	SChangeTimer.connect("timeout", self, "change_time")
	SChangeTimer.one_shot = true
	
	# Load the settings and the save
	var err_save := Savefile.load(current_save)
	var err_settings := Settings.load("user://settings.and")
	
	if err_save == OK:
		load_()
	
	
	if err_settings == OK:
		Env.adjustment_brightness = Settings.get_value("video", "brightness", 1.0)
		Env.adjustment_saturation = Settings.get_value("video", "saturation", 1.0)
		Env.adjustment_contrast = Settings.get_value("video", "contrast", 1.0)
		fullscreen = Settings.get_value("video", "fullscreen", true)
		
		Inputs.up_key = Settings.get_value("controls", "up", KEY_UP)
		Inputs.down_key = Settings.get_value("controls", "down", KEY_DOWN)
		Inputs.left_key = Settings.get_value("controls", "left", KEY_LEFT)
		Inputs.right_key = Settings.get_value("controls", "right", KEY_RIGHT)
		Inputs.jump_key = Settings.get_value("controls", "jump", KEY_Z)
		Inputs.attack_key = Settings.get_value("controls", "attack", KEY_X)
		Inputs.cancel_key = Settings.get_value("controls", "cancel", KEY_C)
		
		
		OS.window_fullscreen = fullscreen


# When the scene is ready to change
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
	masks = Savefile.get_value("player", "masks", []) as Array
	faces = Savefile.get_value("player", "faces", 2) as int
	masks_wearing = Savefile.get_value("player", "masks_wearing", ["none", "none"]) as Array
	
	notches = Savefile.get_value("abilities", "notches", 2) as int
	abilities = Savefile.get_value("abilities", "abilities", [""]) as Array
	notch_fillers = Savefile.get_value("abilities", "fillers", []) as Array
	notch_keys = Savefile.get_value("abilities", "keys", []) as Array
	
	abandoned_ticket = Savefile.get_value("subway", "abandoned", false) as bool
	
	outskirts_arena = Savefile.get_value("outskirts", "arena", false) as bool
	
	got_diary = Savefile.get_value("items", "diary", false) as bool
	
	diary = Savefile.get_value("diary", "diary", ["diary_opening"]) as Array
	diary_page = Savefile.get_value("diary", "current_page", 0) as int
	
	met_the_gardeners = Savefile.get_value("garden", "met_gardeners", false) as bool
	
	beat_the_gardeners = Savefile.get_value("garden", "completed_pit", false) as bool
	
	jump_tutorial = Savefile.get_value("tutorial", "jump", false)
	attack_tutorial = Savefile.get_value("tutorial", "attack", false)
	heal_tutorial = Savefile.get_value("tutorial", "heal", false)
	
	if abilities.has("dash") and not outskirts_arena:
		abilities = [""]
	
	
	for i in notches:
		if notch_fillers.size() < notches:
			notch_fillers.append("")
		if notch_keys.size() < notches:
			notch_keys.append([-1, 0])
	
	for i in faces:
		if masks_wearing.size() < faces:
			masks_wearing.append("none")
	
	
	Inputs.set_ability_actions()

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
	Savefile.set_value("player", "masks", masks)
	Savefile.set_value("player", "masks_wearing", masks_wearing)
	Savefile.set_value("player", "faces", faces)
	
	Savefile.set_value("abilities", "notches", notches)
	Savefile.set_value("abilities", "abilities", abilities)
	Savefile.set_value("abilities", "fillers", notch_fillers)
	Savefile.set_value("abilities", "keys", notch_keys)
	
	Savefile.set_value("subway", "abandoned", abandoned_ticket)
	
	Savefile.set_value("outskirts", "arena", outskirts_arena)
	
	Savefile.set_value("items", "diary", got_diary)
	
	Savefile.set_value("diary", "diary", diary)
	Savefile.set_value("diary", "current_page", diary_page)
	
	Savefile.set_value("garden", "met_gardeners", met_the_gardeners)
	Savefile.set_value("garden", "completed_pit", beat_the_gardeners)
	
	Savefile.set_value("tutorial", "jump", jump_tutorial)
	Savefile.set_value("tutorial", "attack", attack_tutorial)
	Savefile.set_value("tutorial", "heal", heal_tutorial)
	
	
	Savefile.save(current_save)
	
func save_settings():
	Settings.set_value("video", "brightness", Env.adjustment_brightness)
	Settings.set_value("video", "saturation", Env.adjustment_saturation)
	Settings.set_value("video", "contrast", Env.adjustment_contrast)
	Settings.set_value("video", "fullscreen", fullscreen)
	
	Settings.set_value("controls", "up", Inputs.up_key)
	Settings.set_value("controls", "down", Inputs.down_key)
	Settings.set_value("controls", "left", Inputs.left_key)
	Settings.set_value("controls", "right", Inputs.right_key)
	Settings.set_value("controls", "jump", Inputs.jump_key)
	Settings.set_value("controls", "attack", Inputs.attack_key)
	Settings.set_value("controls", "cancel", Inputs.cancel_key)
	Settings.save("user://settings.and")
