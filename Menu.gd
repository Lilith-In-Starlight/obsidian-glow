extends Control

enum MENUS {
	MENU,
	OPTIONS,
	VIDEO,
	CONTROLS,
	CREDITS,
	SELECT_SAVE,
}


onready var Fadeout := $Fadeout

onready var Menu := $Menu
onready var MenuStart := $Menu/StartLabel
onready var MenuOptions := $Menu/OptionsLabel
onready var MenuCredits := $Menu/CreditsLabel
onready var MenuExit := $Menu/ExitLabel

onready var Options := $Options

onready var VisualSettings := $VideoSettings
onready var BrightnessLabel := $VideoSettings/BrightnessLabel
onready var ContrastLabel := $VideoSettings/ContrastLabel
onready var SaturationLabel := $VideoSettings/SaturationLabel
onready var FullscreenLabel := $VideoSettings/FullscreenLabel

onready var Controls := $Controls
onready var ControlsLeft := $Controls/LeftLabel
onready var ControlsRight := $Controls/RightLabel
onready var ControlsUp := $Controls/UpLabel
onready var ControlsDown := $Controls/DownLabel
onready var ControlsJump := $Controls/JumpLabel
onready var ControlsAttack := $Controls/AttackLabel
onready var ControlsCancel := $Controls/CancelLabel

onready var Credits := $Credits
onready var CreditsAnimation := $Credits/CreditsAnimation

var change_controls := false
var control_change := 0


var menu_option := 0
var menu_list := 4 # Amount of elements in the current menu, starts at 1
# used in modulo operations

var current_menu = MENUS.MENU # State machine

var SceneTimer := Timer.new() # Adds some delay to the scene change

var go_to # Tells the game what scene it should go to when the game starts


func _ready():
	# Every time the player starts from the menu, it should be treated as
	# the first time loading the game
	Persistent.first_load = true
	get_tree().paused = false # If the player comes from the game pause menu
	# the tree will be paused, unpause it
	var err
	$HTTPRequest.request("https://itch.io/api/1/x/wharf/latest?game_id=1138381&channel_name=win")
	# Request to see the current version of the game on the itch.io page
	
	# Setup the timer that does the scene change delay
	SceneTimer.wait_time = 0.5
	SceneTimer.one_shot = true
	SceneTimer.connect("timeout", self, "scene_timer_timeout")
	add_child(SceneTimer)
	
	# The collected entries should only be kept during the game
	Persistent.killed = []
	Persistent.recently_collected = []
	
	# Update how the menu looks like to make it look less buggy
	visual_update()


func _process(delta):
	# If the player won't be going to any scene, the fadeout must be transparent
	if go_to == null:
		Fadeout.modulate.a = move_toward(Fadeout.modulate.a, 0.0, 0.05)
	else:
		Fadeout.modulate.a = move_toward(Fadeout.modulate.a, 1.0, 0.05)


func _input(event):
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if go_to == null:
			match current_menu: # State machine
				MENUS.MENU:
					if Input.is_action_just_pressed("escape"): # Resets the savefile and the game variables
						Persistent.Savefile = ConfigFile.new()
						Persistent.Savefile.save(Persistent.save_name)
						Persistent.load_()
						
					# Navigate the menu
					elif Input.is_action_just_pressed("down"): 
						menu_option = (menu_option + 1) % menu_list
					elif Input.is_action_just_pressed("up"):
						menu_option = (menu_option - 1)
						if menu_option < 0:
							menu_option = menu_list - 1
						# Selection
					elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack"):
						match menu_option:
							0: # Start game
#								current_menu = MENUS.SELECT_SAVE
#								menu_option = 0
#								menu_list = 5
								
								# If there's a scene in the save file,
								# go to that one
								if Persistent.loaded_scene != "":
									go_to = load(Persistent.loaded_scene)
								else:
									# if not, go to the start of the game
									go_to = load("res://Areas/Field/Field.tscn")
								SceneTimer.start()
								# Start the timer that changes the scene
							1:
								# Take the player to the options
								current_menu = MENUS.OPTIONS
								menu_option = 0
								menu_list = 5
								print("went")
							2:
								# Take the player to the credits
								current_menu = MENUS.CREDITS
								menu_option = 0
								menu_list = 1
								CreditsAnimation.play("Up")
								# Restart the credits animation
							3: # Quit the game
								get_tree().quit()
				
				MENUS.OPTIONS:
					if Input.is_action_just_pressed("down"):
						menu_option = (menu_option + 1) % menu_list
					elif Input.is_action_just_pressed("up"):
						menu_option = (menu_option - 1)
						if menu_option < 0:
							menu_option = menu_list - 1
						# Select an option
					elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack"):
						match menu_option:
							0: # Video settings
								current_menu = MENUS.VIDEO
								menu_option = 0
								menu_list = 5
							3: # Control settings
								current_menu = MENUS.CONTROLS
								menu_option = 0
								menu_list = 10
							4: # Back to the menu
								current_menu = MENUS.MENU
								menu_option = 1
								menu_list = 4
						# Take the player one level back
					if Input.is_action_just_pressed("cancel"):
						current_menu = MENUS.MENU
						menu_option = 1
						menu_list = 4
				
				MENUS.VIDEO: # Video settings
					if Input.is_action_just_pressed("down"):
						menu_option = (menu_option + 1) % menu_list
					elif Input.is_action_just_pressed("up"):
						menu_option = (menu_option - 1)
						if menu_option < 0:
							menu_option = menu_list - 1
					# Settings are controlled with the left and right keys
					elif Input.is_action_just_pressed("left"):
						match menu_option:
							0:
								Persistent.Env.adjustment_brightness = max(Persistent.Env.adjustment_brightness - 0.25, 0.0)
							1:
								Persistent.Env.adjustment_contrast = max(Persistent.Env.adjustment_contrast - 0.25, 0.0)
							2:
								Persistent.Env.adjustment_saturation = max(Persistent.Env.adjustment_saturation - 0.25, 0.0)
							3:
								Persistent.fullscreen = !Persistent.fullscreen
					elif Input.is_action_just_pressed("right"):
						match menu_option:
							0:
								Persistent.Env.adjustment_brightness = min(Persistent.Env.adjustment_brightness + 0.25, 8.0)
							1:
								Persistent.Env.adjustment_contrast = min(Persistent.Env.adjustment_contrast + 0.25, 8.0)
							2:
								Persistent.Env.adjustment_saturation = min(Persistent.Env.adjustment_saturation + 0.25, 8.0)
							3:
								Persistent.fullscreen = !Persistent.fullscreen
						# Select an option
					elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack"):
						match menu_option:
							3:
								Persistent.fullscreen = !Persistent.fullscreen
							4:
								current_menu = MENUS.OPTIONS
								menu_option = 0
								menu_list = 5
					# Go one level back
					elif Input.is_action_just_pressed("cancel"):
						current_menu = MENUS.OPTIONS
						menu_option = 0
						menu_list = 5
				
				MENUS.CONTROLS: # Control settings
					if not change_controls: # If the player isn't currently
						# rebinding a key
						
						# Menu navigation
						if Input.is_action_just_pressed("down"):
							menu_option = (menu_option + 1) % menu_list
						elif Input.is_action_just_pressed("up"):
							menu_option = (menu_option - 1)
							if menu_option < 0:
								menu_option = menu_list - 1
							# Select an option
						elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack"):
							# The only option that doesn't make you
							# rebind keys is the Back option
							if menu_option != 9:
								control_change = menu_option
								change_controls = true
							else:
								current_menu = MENUS.OPTIONS
								menu_option = 3
								menu_list = 5
						# Go one level back
						elif Input.is_action_just_pressed("cancel"):
							current_menu = MENUS.OPTIONS
							menu_option = 3
							menu_list = 5
					elif not Input.is_action_just_released("jump") and not Input.is_action_just_released("attack") and not event is InputEventJoypadMotion: # If the player is rebinding a key
						change_controls = false
						# _input() is called whenever a key is pressed,
						# so if they press a key and are rebinding it,
						# they won't be rebinding it anymore
						match control_change: # What control is being changed?
							0:
								Inputs.left_key = Inputs.input_to_array(event)
							1:
								Inputs.right_key = Inputs.input_to_array(event)
							2:
								Inputs.up_key = Inputs.input_to_array(event)
							3:
								Inputs.down_key = Inputs.input_to_array(event)
							4:
								Inputs.jump_key = Inputs.input_to_array(event)
							5:
								Inputs.attack_key = Inputs.input_to_array(event)
							6:
								Inputs.cancel_key = Inputs.input_to_array(event)
							7:
								Inputs.inventory_key = Inputs.input_to_array(event)
							8:
								Inputs.diary_key = Inputs.input_to_array(event)
						Inputs.set_actions()
				MENUS.CREDITS:
					# Credits only has one option, and it just takes you
					# One level back
					if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("cancel"):
						current_menu = MENUS.MENU
						menu_option = 2
						menu_list = 4
						CreditsAnimation.stop(true)
#				MENUS.SELECT_SAVE:
#
		
		visual_update() # Update how the menu looks like


func scene_timer_timeout():
	# Called when the scene change timer goes off
	get_tree().change_scene_to(go_to)


func visual_update():
	# Called to update the GUI
	var labels_in_menu # Variable that contains all the options of the
	# current menu
	match current_menu: # State machine
		MENUS.MENU:
			labels_in_menu = Menu.get_children()
			Menu.visible = true
			Options.visible = false
			VisualSettings.visible = false
			Controls.visible = false
			Credits.visible = false
		MENUS.OPTIONS:
			labels_in_menu = Options.get_children()
			Menu.visible = false
			Options.visible = true
			VisualSettings.visible = false
			Controls.visible = false
			Credits.visible = false
		MENUS.VIDEO:
			labels_in_menu = VisualSettings.get_children()
			Menu.visible = false
			Options.visible = false
			VisualSettings.visible = true
			Controls.visible = false
			Credits.visible = false
			
			# Only update these with their values when the player can see them
			BrightnessLabel.text = "Brightness: " + str(Persistent.Env.adjustment_brightness)
			ContrastLabel.text = "Contrast: " + str(Persistent.Env.adjustment_contrast)
			SaturationLabel.text = "Saturation: " + str(Persistent.Env.adjustment_saturation)
			if Persistent.fullscreen:
				FullscreenLabel.text = "Fullscreen: On"
			else:
				FullscreenLabel.text = "Fullscreen: Off"
		MENUS.CONTROLS:
			labels_in_menu = Controls.get_children()
			Menu.visible = false
			Options.visible = false
			VisualSettings.visible = false
			Controls.visible = true
			Credits.visible = false
			
			# Only update these with their values when the player can see them
			ControlsLeft.text = "Left: " + Inputs.custom_scancode_str(Inputs.left_key)
			ControlsRight.text = "Right: " + Inputs.custom_scancode_str(Inputs.right_key)
			ControlsUp.text = "Up: " + Inputs.custom_scancode_str(Inputs.up_key)
			ControlsDown.text = "Down: " + Inputs.custom_scancode_str(Inputs.down_key)
			ControlsJump.text = "Jump/Confirm 1: " + Inputs.custom_scancode_str(Inputs.jump_key)
			ControlsAttack.text = "Attack/Confirm 2: " + Inputs.custom_scancode_str(Inputs.attack_key)
			ControlsCancel.text = "Cancel: " + Inputs.custom_scancode_str(Inputs.cancel_key)
		
		MENUS.CREDITS:
			labels_in_menu = Credits.get_children()
			Menu.visible = false
			Options.visible = false
			VisualSettings.visible = false
			Controls.visible = false
			Credits.visible = true
	
	# Go through all of the options in the GUI
	for i in menu_list:
		# If one of them matches the current option in the menu, color it
		if i == menu_option:
			labels_in_menu[i].modulate = Color("#ffc070")
		else:
			labels_in_menu[i].modulate = Color("#ffffff")
	
	# Constantly save the settings
	Persistent.save_settings()
	OS.window_fullscreen = Persistent.fullscreen


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print(body.get_string_from_ascii(), " ", $VersionLabel.text)
	if body.get_string_from_ascii().find($VersionLabel.text) == -1:
		$VersionWarning.visible = true
