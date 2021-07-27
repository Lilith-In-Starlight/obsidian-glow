extends Control

enum MENUS {
	MENU,
	OPTIONS,
	VIDEO,
	CONTROLS,
	CREDITS,
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
var menu_list := 4

var current_menu = MENUS.MENU

var SceneTimer := Timer.new()

var go_to


func _process(delta):
	if go_to == null:
		Fadeout.modulate.a = move_toward(Fadeout.modulate.a, 0.0, 0.05)
	else:
		Fadeout.modulate.a = move_toward(Fadeout.modulate.a, 1.0, 0.05)


func _ready():
	var err
	for i in 6:
		$HTTPRequest.request("https://ampersandia.net/ampersandiaver.txt")
		if err == OK:
			break;
	SceneTimer.wait_time = 0.5
	SceneTimer.one_shot = true
	SceneTimer.connect("timeout", self, "scene_timer_timeout")
	add_child(SceneTimer)
	visual_update()


func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and go_to == null:
		match current_menu:
			MENUS.MENU:
				match event.scancode:
					Inputs.down_key:
						menu_option = (menu_option + 1) % menu_list
					Inputs.up_key:
						menu_option = (menu_option - 1)
						if menu_option < 0:
							menu_option = menu_list - 1
					Inputs.jump_key, Inputs.attack_key:
						match menu_option:
							0:
								if Persistent.loaded_scene != "":
									go_to = load(Persistent.loaded_scene)
								else:
									go_to = load("res://Areas/Field/Field.tscn")
								SceneTimer.start()
							1:
								current_menu = MENUS.OPTIONS
								menu_option = 0
								menu_list = 5
							2:
								current_menu = MENUS.CREDITS
								menu_option = 0
								menu_list = 1
								CreditsAnimation.play("Up")
							3:
								get_tree().quit()
			MENUS.OPTIONS:
				match event.scancode:
					Inputs.down_key:
						menu_option = (menu_option + 1) % menu_list
					Inputs.up_key:
						menu_option = (menu_option - 1)
						if menu_option < 0:
							menu_option = menu_list - 1
					Inputs.jump_key, Inputs.attack_key:
						match menu_option:
							0:
								current_menu = MENUS.VIDEO
								menu_option = 0
								menu_list = 4
							3:
								current_menu = MENUS.CONTROLS
								menu_option = 0
								menu_list = 8
							4:
								current_menu = MENUS.MENU
								menu_option = 1
								menu_list = 4
					Inputs.cancel_key:
						current_menu = MENUS.MENU
						menu_option = 1
						menu_list = 4
			MENUS.VIDEO:
				match event.scancode:
					Inputs.down_key:
						menu_option = (menu_option + 1) % menu_list
					Inputs.up_key:
						menu_option = (menu_option - 1)
						if menu_option < 0:
							menu_option = menu_list - 1
					Inputs.left_key:
						match menu_option:
							0:
								Persistent.Env.adjustment_brightness = max(Persistent.Env.adjustment_brightness - 0.25, 0.0)
							1:
								Persistent.Env.adjustment_contrast = max(Persistent.Env.adjustment_contrast - 0.25, 0.0)
							2:
								Persistent.Env.adjustment_saturation = max(Persistent.Env.adjustment_saturation - 0.25, 0.0)
					Inputs.right_key:
						match menu_option:
							0:
								Persistent.Env.adjustment_brightness = min(Persistent.Env.adjustment_brightness + 0.25, 8.0)
							1:
								Persistent.Env.adjustment_contrast = min(Persistent.Env.adjustment_contrast + 0.25, 8.0)
							2:
								Persistent.Env.adjustment_saturation = min(Persistent.Env.adjustment_saturation + 0.25, 8.0)
					Inputs.jump_key, Inputs.attack_key:
						match menu_option:
							3:
								current_menu = MENUS.OPTIONS
								menu_option = 0
								menu_list = 5
					Inputs.cancel_key:
						current_menu = MENUS.OPTIONS
						menu_option = 0
						menu_list = 5
			MENUS.CONTROLS:
				if not change_controls:
					match event.scancode:
						Inputs.down_key:
							menu_option = (menu_option + 1) % menu_list
						Inputs.up_key:
							menu_option = (menu_option - 1)
							if menu_option < 0:
								menu_option = menu_list - 1
						Inputs.jump_key, Inputs.attack_key:
							if menu_option != 7:
								control_change = menu_option
								change_controls = true
							else:
								current_menu = MENUS.OPTIONS
								menu_option = 3
								menu_list = 5
						Inputs.cancel_key:
							current_menu = MENUS.OPTIONS
							menu_option = 3
							menu_list = 5
				else:
					change_controls = false
					match control_change:
						0:
							Inputs.left_key = event.scancode
						1:
							Inputs.right_key = event.scancode
						2:
							Inputs.up_key = event.scancode
						3:
							Inputs.down_key = event.scancode
						4:
							Inputs.jump_key = event.scancode
						5:
							Inputs.attack_key = event.scancode
						6:
							Inputs.cancel_key = event.scancode
			MENUS.CREDITS:
				match event.scancode:
					Inputs.jump_key, Inputs.attack_key, Inputs.cancel_key:
						current_menu = MENUS.MENU
						menu_option = 2
						menu_list = 4
						CreditsAnimation.stop(true)
	visual_update()


func scene_timer_timeout():
	get_tree().change_scene_to(go_to)


func visual_update():
	var labels_in_menu
	match current_menu:
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
			
			BrightnessLabel.text = "Brightness: " + str(Persistent.Env.adjustment_brightness)
			ContrastLabel.text = "Contrast: " + str(Persistent.Env.adjustment_contrast)
			SaturationLabel.text = "Saturation: " + str(Persistent.Env.adjustment_saturation)
		MENUS.CONTROLS:
			labels_in_menu = Controls.get_children()
			Menu.visible = false
			Options.visible = false
			VisualSettings.visible = false
			Controls.visible = true
			Credits.visible = false
			
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
	for i in menu_list:
		if i == menu_option:
			labels_in_menu[i].modulate = Color("#ffc070")
		else:
			labels_in_menu[i].modulate = Color("#ffffff")
	
	Persistent.save_settings()


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if body.get_string_from_ascii() != $VersionLabel.text:
		$VersionWarning.visible = true
