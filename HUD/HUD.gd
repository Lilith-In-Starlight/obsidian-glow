extends Control

enum MENUS {
	NONE,
	ABILITIES,
}

enum NOTCH_MODES {
	NONE,
	KEY,
	ABILITY,
}

const NOTCH := preload("res://HUD/AbilityNotch.tscn")
const SELECT_NOTCH_TXT := preload("res://Sprites/HUD/Abilities/notchselect.png")
const SELECTED_NOTCH_TXT := preload("res://Sprites/HUD/Abilities/notchselected.png")
const SELECTED_NOTCH_KEY_TXT := preload("res://Sprites/HUD/Abilities/notchselectedkey.png")

var NotchDict := {
	"" : preload("res://Sprites/HUD/Abilities/emptynotch.png"),
	"dash" : preload("res://Sprites/HUD/Abilities/dashnotch.png")
}

onready var CutsceneFade := $Cutscene

onready var Abilities := $Abilities
onready var CenterNotch := $Abilities/Center
onready var NotchSelector := $Abilities/Selector
var selected_notch := 0

var c_menu = MENUS.NONE
var notch_mode = NOTCH_MODES.NONE
var selected_ability := 0


func _ready():
	for i in Persistent.notches:
		var new_notch := NOTCH.instance()
		new_notch.rect_position = CenterNotch.rect_position + Vector2(cos(i*TAU/Persistent.notches), sin(i*TAU/Persistent.notches)) * 60
		Abilities.add_child(new_notch)
		new_notch.name = "Notch" + str(i)

func _process(delta):
	match Persistent.player_cutscene:
		"leave_l", "leave_r":
			CutsceneFade.modulate.a = move_toward(CutsceneFade.modulate.a, 1.0, 0.05)
		"train":
			CutsceneFade.modulate.a = move_toward(CutsceneFade.modulate.a, 1.0, 0.005)
		_:
			CutsceneFade.modulate.a = move_toward(CutsceneFade.modulate.a, 0.0, 0.05)
	
	match c_menu:
		MENUS.NONE:
			Abilities.visible = false
			get_tree().paused = false
		MENUS.ABILITIES:
			get_tree().paused = true
			Abilities.visible = true
			NotchSelector.rect_position = CenterNotch.rect_position + Vector2(cos(selected_notch*TAU/Persistent.notches), sin(selected_notch*TAU/Persistent.notches)) * 60 - Vector2(3,3)
			for i in Persistent.notches:
				var NotchSprite:TextureRect = get_node_or_null("Abilities/Notch" + str(i))
				NotchSprite.texture = NotchDict[Persistent.notch_fillers[i]]
				NotchSprite.get_node("KeyLabel").text = custom_scancode_str(Persistent.notch_keys[i])
				
			match notch_mode:
				NOTCH_MODES.NONE:
					NotchSelector.texture = SELECT_NOTCH_TXT
				NOTCH_MODES.ABILITY:
					NotchSelector.texture = SELECTED_NOTCH_TXT
				NOTCH_MODES.KEY:
					NotchSelector.texture = SELECTED_NOTCH_KEY_TXT

func _input(event):
	if event is InputEventKey and not event.is_echo() and event.is_pressed():
		match c_menu:
			MENUS.NONE:
				match event.scancode:
					KEY_I:
						c_menu = MENUS.ABILITIES
			MENUS.ABILITIES:
				match notch_mode:
					NOTCH_MODES.NONE:
						match event.scancode:
							KEY_ESCAPE:
								c_menu = MENUS.NONE
							KEY_LEFT:
								selected_notch = (selected_notch + 1) % Persistent.notches
							KEY_RIGHT:
								selected_notch = selected_notch - 1
								if selected_notch < 0:
									selected_notch = Persistent.notches - 1
							KEY_Z:
								if Persistent.player_cutscene == "no":
									notch_mode = NOTCH_MODES.ABILITY
							KEY_X:
								if Persistent.player_cutscene == "no":
									notch_mode = NOTCH_MODES.KEY
					NOTCH_MODES.ABILITY:
						match event.scancode:
							KEY_Z:
								notch_mode = NOTCH_MODES.NONE
							KEY_LEFT:
								selected_ability = (selected_ability + 1) % Persistent.abilities.size()
							KEY_RIGHT:
								selected_ability = (selected_ability - 1)
								if selected_ability < 0:
									selected_ability = Persistent.abilities.size() - 1
							KEY_X:
								notch_mode = NOTCH_MODES.KEY
						Persistent.notch_fillers[selected_notch] = Persistent.abilities[selected_ability]
					NOTCH_MODES.KEY:
						var key := -1
						if event.scancode != KEY_ESCAPE:
							key = event.scancode
						Persistent.notch_keys[selected_notch] = key
						notch_mode = NOTCH_MODES.NONE



func custom_scancode_str(code:int):
	if code == -1:
		return ""
	return OS.get_scancode_string(code)
