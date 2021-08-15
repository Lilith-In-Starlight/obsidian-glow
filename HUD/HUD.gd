extends Control

enum MENUS {
	NONE,
	ABILITIES,
	DASH,
	DIARY,
	OPEN_DIARY,
	PAUSE,
	QUIT,
	MASKS,
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
	"dash" : preload("res://Sprites/HUD/Abilities/dashnotch.png"),
	"slash" : preload("res://Sprites/HUD/Abilities/slashnotch.png"),
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

onready var MaskNotificationImage := $MaskCollected

onready var Instructions := $Instructions
onready var InstructionJump := $Instructions/List/Jump
onready var InstructionAttack := $Instructions/List/Attack
onready var InstructionHeal := $Instructions/List/Heal

var c_menu = MENUS.NONE
var notch_mode = NOTCH_MODES.NONE
var selected_ability := 0

var center_notch := false # Is the center notch selected

var dialogue := []

var pause_menu_value := 0

var quitting := false

var top_row := false # In the notches screen, is the top row selected?
var selected_mask := 0 # What mask is selected?


func _init():
	visible = true

func _ready():
	if not (Persistent.jump_tutorial and Persistent.attack_tutorial and Persistent.heal_tutorial):
		Instructions.rect_position.x = 331
	$Darkness.value = Persistent.shadow
	Player.connect("health_change", self, "health_changed")
	for i in Persistent.notches:
		var new_notch := NOTCH.instance()
		new_notch.rect_position = CenterNotch.rect_position + Vector2(cos(i*TAU/Persistent.notches), sin(i*TAU/Persistent.notches)) * 60
		Abilities.add_child(new_notch)
		new_notch.name = "Notch" + str(i)
	if Persistent.health == 1:
		attacked_vignette = 0.35

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
	
	Attacked.get_material().set_shader_param("angry", Persistent.health == 1 and Persistent.masks_wearing.has("survivor"))
	
	if not (Persistent.jump_tutorial and Persistent.attack_tutorial and Persistent.heal_tutorial):
		Instructions.rect_position.x = lerp(Instructions.rect_position.x, 400-59, 0.1)
	else:
		Instructions.rect_position.x = lerp(Instructions.rect_position.x, 400, 0.1)
	
	InstructionJump.text = "[" + Inputs.custom_scancode_str(Inputs.jump_key) + "] Jump"
	InstructionAttack.text = "[" + Inputs.custom_scancode_str(Inputs.attack_key) + "] Attack"
	InstructionHeal.text = "[" + Inputs.custom_scancode_str(Inputs.down_key) + "] Heal"
	
	if Persistent.jump_tutorial:
		InstructionJump.modulate = Color("#ffbc00")
	if Persistent.attack_tutorial:
		InstructionAttack.modulate = Color("ffbc00")
	if Persistent.heal_tutorial:
		InstructionHeal.modulate = Color("ffbc00")
	
	if not quitting:
		if Persistent.health > 0:
			if Persistent.health > 1:
				attacked_vignette = move_toward(attacked_vignette, 0.0, 0.01)
			else:
				attacked_vignette = move_toward(attacked_vignette, 0.35, 0.01)
			match Persistent.player_cutscene:
				"leave_l", "leave_r", "door", "leave_v":
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
			$Masks.visible = false
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
			$Masks.visible = false
			$ObtainedDash.modulate.a = move_toward($ObtainedDash.modulate.a, 0.0, 0.05)
			$ObtainedDiary.modulate.a = move_toward($ObtainedDiary.modulate.a, 0.0, 0.05)
			if not center_notch:
				NotchSelector.rect_position = CenterNotch.rect_position + Vector2(cos(selected_notch*TAU/Persistent.notches), sin(selected_notch*TAU/Persistent.notches)) * 60 - Vector2(3,3)
			else:
				NotchSelector.rect_position = CenterNotch.rect_position - Vector2(3,3)
			for i in Persistent.notches:
				var NotchSprite:TextureRect = get_node_or_null("Abilities/Notch" + str(i))
				NotchSprite.texture = NotchDict[Persistent.notch_fillers[i]]
				NotchSprite.get_node("KeyLabel").text = Inputs.custom_scancode_str(Persistent.notch_keys[i])
				
			match notch_mode:
				NOTCH_MODES.NONE:
					NotchSelector.texture = SELECT_NOTCH_TXT
					if not center_notch:
						$Abilities/Label3.text = """[1] CHANGE ABILITY
							[2] CHANGE CONTROL
							[3] CENTER NOTCH
							[ESC] CLOSE""".replace("1", Inputs.custom_scancode_str(Inputs.jump_key)).replace("2", Inputs.custom_scancode_str(Inputs.attack_key)).replace("3", Inputs.custom_scancode_str(Inputs.up_key))
					else:
						$Abilities/Label3.text = """[1/2] INVENTORY
							[3] ABILITIES
							[ESC] CLOSE""".replace("1", Inputs.custom_scancode_str(Inputs.jump_key)).replace("2", Inputs.custom_scancode_str(Inputs.attack_key)).replace("3", Inputs.custom_scancode_str(Inputs.up_key))
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
		MENUS.MASKS:
			Abilities.visible = false
			$Masks.visible = true
			var c_mask
			if top_row:
				c_mask = $Masks/Using.get_children()[selected_mask]
			else:
				c_mask = $Masks/Collected.get_children()[selected_mask]
			
			$Masks/Selector.rect_position = c_mask.rect_global_position
			
			for i in $Masks/Using.get_child_count():
				$Masks/Using.get_children()[i].mask_hud = Persistent.masks_wearing[i]
				if top_row and selected_mask == i:
					$Masks/Using.get_children()[i].modulate = Color("#ff8c8c")
				else:
					$Masks/Using.get_children()[i].modulate = Color("#ffffff")
			
			for i in $Masks/Collected.get_child_count():
				if not top_row and selected_mask == i:
					$Masks/Collected.get_children()[i].modulate = Color("#ff8c8c")
				else:
					$Masks/Collected.get_children()[i].modulate = Color("#ffffff")
			
			if Persistent.masks.has(c_mask.mask_hud):
				$Masks/Text.text = Language.line("desc_mask_%s" % c_mask.mask_hud)
			else:
				$Masks/Text.text = ""
func _input(event):
	# Player can only interact with the HUD if they're not quitting the game
	if (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or event is InputEventJoypadMotion) and not quitting:
		match c_menu:
			MENUS.NONE: # No menu
				if Input.is_action_just_pressed("inventory"):
					# Open the abilities menu
					c_menu = MENUS.ABILITIES
				elif Input.is_action_just_pressed("jump"):
					# Advance the dialogue
					var changed := false # Only start the nomovetimer
					# if the dialogue has been started
					if !dialogue.empty():
						if DialogueText.visible_characters >= DialogueText.text.length() - 1:
							changed = true
							dialogue.pop_front()
							DialogueText.visible_characters = 0
						else:
							DialogueText.visible_characters = DialogueText.text.length()
						
					if changed and dialogue.empty():
						Player.NoMoveTimer.start()
				elif Input.is_action_just_pressed("pause"):
					# Pause the game
					c_menu = MENUS.PAUSE
				elif Input.is_action_just_pressed("diary"):
					# Open the diary
					if Persistent.got_diary:
						c_menu = MENUS.OPEN_DIARY
			
			MENUS.ABILITIES:
				match notch_mode:
					NOTCH_MODES.NONE:
							# Close menu
						if Input.is_action_just_pressed("pause"):
							c_menu = MENUS.NONE
							
							# Navigate menu
						elif Input.is_action_just_pressed("left"):
							selected_notch = (selected_notch + 1) % Persistent.notches
						elif Input.is_action_just_pressed("right"):
							selected_notch = selected_notch - 1
							if selected_notch < 0:
								selected_notch = Persistent.notches - 1
						
							# Change ability
						elif Input.is_action_just_pressed("jump"):
							if not center_notch:
								if Persistent.player_cutscene == "no" and Persistent.near_bench:
									notch_mode = NOTCH_MODES.ABILITY
									selected_ability = Persistent.abilities.find(Persistent.notch_fillers[selected_notch])
									# This makes sure that when the player is going to select an ability
									# the first one in their list is the one in the current notch, if any
									if selected_ability < 0:
										selected_ability = 0
							else:
								c_menu = MENUS.MASKS
						
							# Rebind notch
						elif Input.is_action_just_pressed("attack"):
							if not center_notch:
								if Persistent.player_cutscene == "no":
									notch_mode = NOTCH_MODES.KEY
							else:
								c_menu = MENUS.MASKS
							
						elif Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down"):
							center_notch = !center_notch
					
					NOTCH_MODES.ABILITY:
							# Ability has been selected
						if Input.is_action_just_pressed("jump"):
							notch_mode = NOTCH_MODES.NONE
							
							# Menu navigation
						elif Input.is_action_just_pressed("left"):
							selected_ability = (selected_ability + 1) % Persistent.abilities.size()
						elif Input.is_action_just_pressed("right"):
							selected_ability = (selected_ability - 1)
							if selected_ability < 0:
								selected_ability = Persistent.abilities.size() - 1
							
						# Rebind notch
						elif Input.is_action_just_pressed("attack"):
							notch_mode = NOTCH_MODES.KEY
						
						# Update the current notch's ability
						Persistent.notch_fillers[selected_notch] = Persistent.abilities[selected_ability]
					
					NOTCH_MODES.KEY:
						if not Input.is_action_just_released("attack") and not event is InputEventJoypadMotion:
							# -1 means no key
							var key := [-1, 0]
							# You can press escape to remove the key
							if not Input.is_action_just_pressed("pause"):
								key = Inputs.input_to_array(event)
								
							# Update notch key
							Persistent.notch_keys[selected_notch] = key
							
							# Exit the rebind mode
							notch_mode = NOTCH_MODES.NONE
							Inputs.set_ability_actions()
						
			MENUS.DASH, MENUS.DIARY:
				# Both of these are just screens you can exit by pressing a key
				if ($ObtainedDash.modulate.a > 0.8 or $ObtainedDiary.modulate.a > 0.8) and (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack")):
					c_menu = MENUS.NONE
					Player.NoMoveTimer.start()
			
			MENUS.PAUSE:
					# Unpause
				if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("cancel"):
					c_menu = MENUS.NONE
				
				# Menu navigation
				elif Input.is_action_just_pressed("down"):
					pause_menu_value = (pause_menu_value + 1) % 2
				elif Input.is_action_just_pressed("up"):
					pause_menu_value = pause_menu_value - 1 
					if pause_menu_value < 0:
						pause_menu_value = 1
				
				# Select an option
				elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack"):
					match pause_menu_value:
						0: # Resume, unpause
							c_menu = MENUS.NONE
						1: # Quit
							c_menu = MENUS.QUIT
							pause_menu_value = 1
			
			MENUS.QUIT:
				# Back to pause menu
				if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("cancel"):
					c_menu = MENUS.PAUSE
					pause_menu_value = 1
				
				# Menu navigation (this one's horizontal)
				elif Input.is_action_just_pressed("right"):
					pause_menu_value = (pause_menu_value + 1) % 2
				elif Input.is_action_just_pressed("left"):
					pause_menu_value = pause_menu_value - 1 
					if pause_menu_value < 0:
						pause_menu_value = 1
				
				# Select an option
				elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack"):
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
				# Diary navigation
				if Input.is_action_just_pressed("left"):
					Persistent.diary_page = max(Persistent.diary_page - 1, 0)
				elif Input.is_action_just_pressed("right"):
					Persistent.diary_page = min(Persistent.diary_page + 1, Persistent.diary.size() - 1)
				elif Input.is_action_just_pressed("diary") or Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("cancel"):
					c_menu = MENUS.NONE
			
			MENUS.MASKS:
				if Input.is_action_just_pressed("up"):
					if not top_row:
						if selected_mask < 6:
							top_row = true
							selected_mask = min($Masks/Using.get_child_count()-1, selected_mask)
						else:
							selected_mask -= 6
					
					selected_mask = min($Masks/Collected.get_child_count()-1, selected_mask)
					
				elif Input.is_action_just_pressed("down"):
					if not top_row:
						selected_mask += 6
					else:
						top_row = false
					selected_mask = min($Masks/Collected.get_child_count()-1, selected_mask)
					
				elif Input.is_action_just_pressed("left"):
					var limit_min := int(selected_mask / 6.0) * 6
					selected_mask -= 1
					if selected_mask < limit_min:
						selected_mask = limit_min
					elif selected_mask > limit_min + 6:
						selected_mask = limit_min + 6
					
					if top_row:
						selected_mask = min($Masks/Using.get_child_count()-1, selected_mask)
					else:
						selected_mask = min($Masks/Collected.get_child_count()-1, selected_mask)
					
				elif Input.is_action_just_pressed("right"):
					var limit_min := int(selected_mask / 6.0) * 6
					selected_mask += 1
					if selected_mask < limit_min:
						selected_mask = limit_min
					elif selected_mask > limit_min + 6:
						selected_mask = limit_min + 6
					
					
					if top_row:
						selected_mask = min($Masks/Using.get_child_count()-1, selected_mask)
					else:
						selected_mask = min($Masks/Collected.get_child_count()-1, selected_mask)
					
				elif Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("jump"):
					if Persistent.near_bench:
						if top_row:
							Persistent.masks_wearing[selected_mask] = "none"
						else:
							var c_mask = $Masks/Collected.get_children()[selected_mask]
							var find = Persistent.masks_wearing.find(c_mask.mask_hud)
							if find != -1:
								Persistent.masks_wearing[find] = "none"
							else:
								find = Persistent.masks_wearing.find("none")
								if find != -1 and Persistent.masks.has(c_mask.mask_hud):
									Persistent.masks_wearing[find] = c_mask.mask_hud
				
				elif Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("cancel"):
					c_menu = MENUS.ABILITIES

# If the player's health lowers, make the attack vignette appear
func health_changed(change):
	if change < 0:
		attacked_vignette = 0.5 + 0.2*abs(change)

func diary_updated():
	$DiaryUpdated/Animation.play("Update")

func mask_collected():
	$MaskCollected/Animation.play("Update")
