extends Control

enum MENUS {
	NONE,
	ABILITIES,
	DASH,
	DIARY,
	OPEN_DIARY,
}

enum NOTCH_MODES {
	NONE,
	KEY,
	ABILITY,
}

const FLASK := preload("res://HUD/HealthFlask.tscn")
const NOTCH := preload("res://HUD/AbilityNotch.tscn")
const SELECT_NOTCH_TXT := preload("res://Sprites/HUD/Abilities/notchselect.png")
const SELECTED_NOTCH_TXT := preload("res://Sprites/HUD/Abilities/notchselected.png")
const SELECTED_NOTCH_KEY_TXT := preload("res://Sprites/HUD/Abilities/notchselectedkey.png")

var NotchDict := {
	"" : preload("res://Sprites/HUD/Abilities/emptynotch.png"),
	"dash" : preload("res://Sprites/HUD/Abilities/dashnotch.png")
}

onready var DialogueNode := $Dialogue
onready var DialogueText := $Dialogue/Text

onready var Player := $"../../Neptune"
onready var Attacked := $Attacked
var attacked_vignette := 0.0

onready var CutsceneFade := $Cutscene

onready var Abilities := $Abilities
onready var CenterNotch := $Abilities/Center
onready var NotchSelector := $Abilities/Selector
var selected_notch := 0

var c_menu = MENUS.NONE
var notch_mode = NOTCH_MODES.NONE
var selected_ability := 0

var dialogue := []

func _init():
	visible = true

func _ready():
	$Darkness.value = Persistent.shadow
	Player.connect("health_change", self, "health_changed")
	for i in Persistent.notches:
		var new_notch := NOTCH.instance()
		new_notch.rect_position = CenterNotch.rect_position + Vector2(cos(i*TAU/Persistent.notches), sin(i*TAU/Persistent.notches)) * 60
		Abilities.add_child(new_notch)
		new_notch.name = "Notch" + str(i)

func _process(delta):
	$Darkness.value = move_toward($Darkness.value, Persistent.shadow, 1)
	$PersandAmount.text = str(Persistent.persands)
	if Persistent.shadow > 12:
		Persistent.shadow = 12
	var HealthThere := $Health.get_children().size()
	while HealthThere < Persistent.health and Persistent.health >= 0:
		var NewFlask := FLASK.instance()
		$Health.add_child(NewFlask)
		HealthThere += 1
	while HealthThere > Persistent.health and Persistent.health >= 0:
		$Health.remove_child($Health.get_children()[0])
		HealthThere -= 1
		
	var aa = Attacked.get_material().get_shader_param("rest")
	attacked_vignette = move_toward(attacked_vignette, 0.0, 0.01)
	if Persistent.health > 0:
		if Persistent.health > 1:
			attacked_vignette = move_toward(attacked_vignette, 0.0, 0.01)
		else:
			attacked_vignette = move_toward(attacked_vignette, 0.35, 0.01)
		match Persistent.player_cutscene:
			"leave_l", "leave_r", "door":
				CutsceneFade.modulate.a = move_toward(CutsceneFade.modulate.a, 1.0, 0.05)
			"train":
				CutsceneFade.modulate.a = move_toward(CutsceneFade.modulate.a, 1.0, 0.005)
			_:
				CutsceneFade.modulate.a = move_toward(CutsceneFade.modulate.a, 0.0, 0.05)
	else:
		attacked_vignette = move_toward(attacked_vignette, 1.0, 0.01)
		CutsceneFade.modulate.a = move_toward(CutsceneFade.modulate.a, 1.0, 0.005)
	
	Attacked.get_material().set_shader_param("rest", lerp(aa, attacked_vignette, 0.1))
	match c_menu:
		MENUS.NONE:
			Abilities.visible = false
			get_tree().paused = false
			$ObtainedDash.modulate.a = move_toward($ObtainedDash.modulate.a, 0.0, 0.05)
			$ObtainedDiary.modulate.a = move_toward($ObtainedDiary.modulate.a, 0.0, 0.05)
			
			if not dialogue.empty():
				Persistent.player_cutscene = "nomove"
				DialogueNode.modulate.a = move_toward(DialogueNode.modulate.a, 1.0, 0.08)
				DialogueText.text = dialogue[0]
				DialogueText.visible_characters = move_toward(DialogueText.visible_characters, DialogueText.text.length(), 1)
			else:
				DialogueNode.modulate.a = move_toward(DialogueNode.modulate.a, 0.0, 0.08)
		MENUS.ABILITIES:
			get_tree().paused = true
			Abilities.visible = true
			$ObtainedDash.modulate.a = move_toward($ObtainedDash.modulate.a, 0.0, 0.05)
			$ObtainedDiary.modulate.a = move_toward($ObtainedDiary.modulate.a, 0.0, 0.05)
			NotchSelector.rect_position = CenterNotch.rect_position + Vector2(cos(selected_notch*TAU/Persistent.notches), sin(selected_notch*TAU/Persistent.notches)) * 60 - Vector2(3,3)
			for i in Persistent.notches:
				var NotchSprite:TextureRect = get_node_or_null("Abilities/Notch" + str(i))
				NotchSprite.texture = NotchDict[Persistent.notch_fillers[i]]
				NotchSprite.get_node("KeyLabel").text = Inputs.custom_scancode_str(Persistent.notch_keys[i])
				
			match notch_mode:
				NOTCH_MODES.NONE:
					NotchSelector.texture = SELECT_NOTCH_TXT
					$Abilities/Label3.text = """[1] CHANGE ABILITY
						[2] CHANGE CONTROL
						[ESC] CLOSE""".replace("1", Inputs.custom_scancode_str(Inputs.jump_key)).replace("2", Inputs.custom_scancode_str(Inputs.attack_key))
				NOTCH_MODES.ABILITY:
					NotchSelector.texture = SELECTED_NOTCH_TXT
					$Abilities/Label3.text = """[1][2] CHANGE ABILITY
						[3] SELECT
						[4] CHANGE CONTROL""".replace("1", Inputs.custom_scancode_str(Inputs.left_key)).replace("2", Inputs.custom_scancode_str(Inputs.right_key)).replace("3", Inputs.custom_scancode_str(Inputs.jump_key)).replace("4", Inputs.custom_scancode_str(Inputs.attack_key))
				NOTCH_MODES.KEY:
					NotchSelector.texture = SELECTED_NOTCH_KEY_TXT
					NotchSelector.texture = SELECTED_NOTCH_TXT
					$Abilities/Label3.text = """PRESS ANY KEY
					[ESC] NO KEY"""
		MENUS.DASH:
			get_tree().paused = true
			$ObtainedDash.modulate.a = move_toward($ObtainedDash.modulate.a, 1.0, 0.01)
			$ObtainedDiary.modulate.a = move_toward($ObtainedDiary.modulate.a, 0.0, 0.05)
		MENUS.DIARY:
			get_tree().paused = true
			$ObtainedDash.modulate.a = move_toward($ObtainedDash.modulate.a, 0.0, 0.05)
			$ObtainedDiary.modulate.a = move_toward($ObtainedDiary.modulate.a, 1.0, 0.01)
			

func _input(event):
	if event is InputEventKey and not event.is_echo() and event.is_pressed():
		match c_menu:
			MENUS.NONE:
				match event.scancode:
					KEY_I:
						c_menu = MENUS.ABILITIES
					KEY_Z:
						if !dialogue.empty():
							dialogue.pop_front()
							DialogueText.visible_characters = 0
							
						if dialogue.empty():
							Player.NoMoveTimer.start()
			MENUS.ABILITIES:
				match notch_mode:
					NOTCH_MODES.NONE:
						match event.scancode:
							KEY_ESCAPE:
								c_menu = MENUS.NONE
							Inputs.left_key:
								selected_notch = (selected_notch + 1) % Persistent.notches
							Inputs.right_key:
								selected_notch = selected_notch - 1
								if selected_notch < 0:
									selected_notch = Persistent.notches - 1
							Inputs.jump_key:
								if Persistent.player_cutscene == "no" and Persistent.near_bench:
									notch_mode = NOTCH_MODES.ABILITY
							Inputs.attack_key:
								if Persistent.player_cutscene == "no":
									notch_mode = NOTCH_MODES.KEY
					NOTCH_MODES.ABILITY:
						match event.scancode:
							Inputs.jump_key:
								notch_mode = NOTCH_MODES.NONE
							Inputs.left_key:
								selected_ability = (selected_ability + 1) % Persistent.abilities.size()
							Inputs.right_key:
								selected_ability = (selected_ability - 1)
								if selected_ability < 0:
									selected_ability = Persistent.abilities.size() - 1
							Inputs.attack_key:
								notch_mode = NOTCH_MODES.KEY
						Persistent.notch_fillers[selected_notch] = Persistent.abilities[selected_ability]
					NOTCH_MODES.KEY:
						var key := -1
						if event.scancode != KEY_ESCAPE:
							key = event.scancode
						Persistent.notch_keys[selected_notch] = key
						notch_mode = NOTCH_MODES.NONE
						
			MENUS.DASH, MENUS.DIARY:
				if event.scancode == Inputs.attack_key or event.scancode == Inputs.jump_key:
					c_menu = MENUS.NONE
					Player.NoMoveTimer.start()

func health_changed(change):
	if change < 0:
		attacked_vignette = 0.5 + 0.2*abs(change)
