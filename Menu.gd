extends Control

enum MENUS {
	MENU,
	OPTIONS,
	VIDEO,
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
					KEY_DOWN:
						menu_option = (menu_option + 1) % menu_list
					KEY_UP:
						menu_option = (menu_option - 1)
						if menu_option < 0:
							menu_option = menu_list - 1
					KEY_Z:
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
								pass
							3:
								get_tree().quit()
			MENUS.OPTIONS:
				match event.scancode:
					KEY_DOWN:
						menu_option = (menu_option + 1) % menu_list
					KEY_UP:
						menu_option = (menu_option - 1)
						if menu_option < 0:
							menu_option = menu_list - 1
					KEY_Z:
						match menu_option:
							0:
								current_menu = MENUS.VIDEO
								menu_option = 0
								menu_list = 4
							4:
								current_menu = MENUS.MENU
								menu_option = 1
								menu_list = 4
			MENUS.VIDEO:
				match event.scancode:
					KEY_DOWN:
						menu_option = (menu_option + 1) % menu_list
					KEY_UP:
						menu_option = (menu_option - 1)
						if menu_option < 0:
							menu_option = menu_list - 1
					KEY_LEFT:
						match menu_option:
							0:
								Persistent.Env.adjustment_brightness = max(Persistent.Env.adjustment_brightness - 0.25, 0.0)
							1:
								Persistent.Env.adjustment_contrast = max(Persistent.Env.adjustment_contrast - 0.25, 0.0)
							2:
								Persistent.Env.adjustment_saturation = max(Persistent.Env.adjustment_saturation - 0.25, 0.0)
					KEY_RIGHT:
						match menu_option:
							0:
								Persistent.Env.adjustment_brightness = min(Persistent.Env.adjustment_brightness + 0.25, 8.0)
							1:
								Persistent.Env.adjustment_contrast = min(Persistent.Env.adjustment_contrast + 0.25, 8.0)
							2:
								Persistent.Env.adjustment_saturation = min(Persistent.Env.adjustment_saturation + 0.25, 8.0)
					KEY_Z:
						match menu_option:
							3:
								current_menu = MENUS.OPTIONS
								menu_option = 0
								menu_list = 5
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
		MENUS.OPTIONS:
			labels_in_menu = Options.get_children()
			Menu.visible = false
			Options.visible = true
			VisualSettings.visible = false
		MENUS.VIDEO:
			labels_in_menu = VisualSettings.get_children()
			Menu.visible = false
			Options.visible = false
			VisualSettings.visible = true
			
			BrightnessLabel.text = "Brightness: " + str(Persistent.Env.adjustment_brightness)
			ContrastLabel.text = "Contrast: " + str(Persistent.Env.adjustment_contrast)
			SaturationLabel.text = "Saturation: " + str(Persistent.Env.adjustment_saturation)
	
	for i in menu_list:
		if i == menu_option:
			labels_in_menu[i].modulate = Color("#ffc070")
		else:
			labels_in_menu[i].modulate = Color("#ffffff")
	
	Persistent.save_settings()
