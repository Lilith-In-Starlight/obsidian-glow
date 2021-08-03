extends Control

enum MENUS {
	NONE,
	ABILITIES,
	DASH,
	DIARY,
	OPEN_DIARY,
	PAUSE,
	QUIT,
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

onready var Diary := $Diary
onready var DiaryOdd := $Diary/Pages/Oddpage
onready var DiaryEven := $Diary/Pages/Evenpage

var c_menu = MENUS.NONE
var notch_mode = NOTCH_MODES.NONE
var selected_ability := 0

var dialogue := []

var pause_menu_value := 0

var quitting := false

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
	if not quitting:
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
	else:
		CutsceneFade.modulate.a = move_toward(CutsceneFade.modulate.a, 1.0, 0.05)
	Attacked.get_material().set_shader_param("rest", lerp(aa, attacked_vignette, 0.1))
	match c_menu:
		MENUS.NONE:
			Diary.visible = false
			Abilities.visible = false
			get_tree().paused = false
			$ObtainedDash.modulate.a = move_toward($ObtainedDash.modulate.a, 0.0, 0.05)
			$ObtainedDiary.modulate.a = move_toward($ObtainedDiary.modulate.a, 0.0, 0.05)
			$Pause.visible = false
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
			$Pause.visible = false
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
			$Pause.visible = false
			get_tree().paused = true
			$ObtainedDash.modulate.a = move_toward($ObtainedDash.modulate.a, 1.0, 0.01)
			$ObtainedDiary.modulate.a = move_toward($ObtainedDiary.modulate.a, 0.0, 0.05)
		MENUS.DIARY:
			$Pause.visible = false
			get_tree().paused = true
			$ObtainedDash.modulate.a = move_toward($ObtainedDash.modulate.a, 0.0, 0.05)
			$ObtainedDiary.modulate.a = move_toward($ObtainedDiary.modulate.a, 1.0, 0.01)
		MENUS.PAUSE, MENUS.QUIT:
			get_tree().paused = true
			var children
			$Pause.visible = true
			if c_menu == MENUS.PAUSE:
				$Pause/Pause.visible = true
				$Pause/Quit.visible = false
				children = $Pause/Pause.get_children()
			else:
				$Pause/Pause.visible = false
				$Pause/Quit.visible = true
				children = $Pause/Quit/Options.get_children()
			
			for i in range(children.size()):
				if i == pause_menu_value:
					children[i].modulate = Color("#ffc070")
				else:
					children[i].modulate = Color("#ffffff")
					
		MENUS.OPEN_DIARY:
			Diary.visible = true
			Abilities.visible = false
			get_tree().paused = true
			
			if Persistent.diary.size() > Persistent.diary_page * 2:
				DiaryOdd.text = Language.line(Persistent.diary[Persistent.diary_page * 2])
			else:
				DiaryOdd.text = ""
			if Persistent.diary.size() > Persistent.diary_page * 2 + 1:
				DiaryEven.text = Language.line(Persistent.diary[Persistent.diary_page * 2 + 1])
			else:
				DiaryEven.text = ""

func _input(event):
	# Player can only interact with the HUD if they're not quitting the game
	if event is InputEventKey and not event.is_echo() and event.is_pressed() and not quitting:
		match c_menu:
			MENUS.NONE: # No menu
				match event.scancode:
					KEY_I:
						# Open the abilities menu
						c_menu = MENUS.ABILITIES
					Inputs.jump_key:
						# Advance the dialogue
						var changed := false # Only start the nomovetimer
						# if the dialogue has been started
						if !dialogue.empty():
							changed = true
							dialogue.pop_front()
							DialogueText.visible_characters = 0
							
						if changed and dialogue.empty():
							Player.NoMoveTimer.start()
					KEY_ESCAPE:
						# Pause the game
						c_menu = MENUS.PAUSE
					KEY_TAB:
						# Open the diary
						if Persistent.got_diary:
							c_menu = MENUS.OPEN_DIARY
			
			MENUS.ABILITIES:
				match notch_mode:
					NOTCH_MODES.NONE:
						match event.scancode:
							# Close menu
							KEY_ESCAPE:
								c_menu = MENUS.NONE
							
							# Navigate menu
							Inputs.left_key:
								selected_notch = (selected_notch + 1) % Persistent.notches
							Inputs.right_key:
								selected_notch = selected_notch - 1
								if selected_notch < 0:
									selected_notch = Persistent.notches - 1
							
							# Change ability
							Inputs.jump_key:
								if Persistent.player_cutscene == "no" and Persistent.near_bench:
									notch_mode = NOTCH_MODES.ABILITY
							
							# Rebind notch
							Inputs.attack_key:
								if Persistent.player_cutscene == "no":
									notch_mode = NOTCH_MODES.KEY
					
					NOTCH_MODES.ABILITY:
						match event.scancode:
							# Ability has been selected
							Inputs.jump_key:
								notch_mode = NOTCH_MODES.NONE
							
							# Menu navigation
							Inputs.left_key:
								selected_ability = (selected_ability + 1) % Persistent.abilities.size()
							Inputs.right_key:
								selected_ability = (selected_ability - 1)
								if selected_ability < 0:
									selected_ability = Persistent.abilities.size() - 1
							
							# Rebind notch
							Inputs.attack_key:
								notch_mode = NOTCH_MODES.KEY
						
						# Update the current notch's ability
						Persistent.notch_fillers[selected_notch] = Persistent.abilities[selected_ability]
					
					NOTCH_MODES.KEY:
						# -1 means no key
						var key := -1
						# You can press escape to remove the key
						if event.scancode != KEY_ESCAPE:
							key = event.scancode
							
						# Update notch key
						Persistent.notch_keys[selected_notch] = key
						
						# Exit the rebind mode
						notch_mode = NOTCH_MODES.NONE
						
			MENUS.DASH, MENUS.DIARY:
				# Both of these are just screens you can exit by pressing a key
				if event.scancode == Inputs.attack_key or event.scancode == Inputs.jump_key:
					c_menu = MENUS.NONE
					Player.NoMoveTimer.start()
			
			MENUS.PAUSE:
				match event.scancode:
					# Unpause
					KEY_ESCAPE, Inputs.cancel_key:
						c_menu = MENUS.NONE
					
					# Menu navigation
					Inputs.down_key:
						pause_menu_value = (pause_menu_value + 1) % 2
					Inputs.up_key:
						pause_menu_value = pause_menu_value - 1 
						if pause_menu_value < 0:
							pause_menu_value = 1
					
					# Select an option
					Inputs.jump_key, Inputs.attack_key:
						match pause_menu_value:
							0: # Resume, unpause
								c_menu = MENUS.NONE
							1: # Quit
								c_menu = MENUS.QUIT
								pause_menu_value = 1
			
			MENUS.QUIT:
				match event.scancode:
					# Back to pause menu
					KEY_ESCAPE, Inputs.cancel_key:
						c_menu = MENUS.PAUSE
						pause_menu_value = 1
					
					# Menu navigation (this one's horizontal)
					Inputs.right_key:
						pause_menu_value = (pause_menu_value + 1) % 2
					Inputs.left_key:
						pause_menu_value = pause_menu_value - 1 
						if pause_menu_value < 0:
							pause_menu_value = 1
					
					# Select an option
					Inputs.jump_key, Inputs.attack_key:
						match pause_menu_value:
							0: # Go to menu
								Persistent.next_scene = load("res://Menu.tscn")
								Persistent.SChangeTimer.start()
								quitting = true
								# Reload the file
								Persistent.load_()
							1:
								# Back to pause menu
								c_menu = MENUS.PAUSE
								pause_menu_value = 1
			
			MENUS.OPEN_DIARY:
				match event.scancode:
					# Diary navigation
					Inputs.left_key:
						Persistent.diary_page = max(Persistent.diary_page - 1, 0)
					Inputs.right_key:
						Persistent.diary_page = min(Persistent.diary_page + 1, Persistent.diary.size() - 1)
					KEY_TAB, KEY_ESCAPE, Inputs.cancel_key:
						c_menu = MENUS.NONE

# If the player's health lowers, make the attack vignette appear
func health_changed(change):
	if change < 0:
		attacked_vignette = 0.5 + 0.2*abs(change)

func diary_updated():
	$DiaryUpdated/Animation.play("Update")
