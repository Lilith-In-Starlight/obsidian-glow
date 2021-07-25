extends Control

onready var Fadeout := $Fadeout

onready var Menu := $Menu
onready var MenuStart := $Menu/StartLabel
onready var MenuOptions := $Menu/OptionsLabel
onready var MenuCredits := $Menu/CreditsLabel
onready var MenuExit := $Menu/ExitLabel

var menu_option := 0
var menu_list := 4

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
	match menu_option:
		0:
			MenuStart.modulate = Color("#ffc070")
			MenuOptions.modulate = Color("#ffffff")
			MenuCredits.modulate = Color("#ffffff")
			MenuExit.modulate = Color("#ffffff")
		1:
			MenuStart.modulate = Color("#ffffff")
			MenuOptions.modulate = Color("#ffc070")
			MenuCredits.modulate = Color("#ffffff")
			MenuExit.modulate = Color("#ffffff")
		2:
			MenuStart.modulate = Color("#ffffff")
			MenuOptions.modulate = Color("#ffffff")
			MenuCredits.modulate = Color("#ffc070")
			MenuExit.modulate = Color("#ffffff")
		3:
			MenuStart.modulate = Color("#ffffff")
			MenuOptions.modulate = Color("#ffffff")
			MenuCredits.modulate = Color("#ffffff")
			MenuExit.modulate = Color("#ffc070")


func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and go_to == null:
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
						pass
					2:
						pass
					3:
						get_tree().quit()
	match menu_option:
		0:
			MenuStart.modulate = Color("#ffc070")
			MenuOptions.modulate = Color("#ffffff")
			MenuCredits.modulate = Color("#ffffff")
			MenuExit.modulate = Color("#ffffff")
		1:
			MenuStart.modulate = Color("#ffffff")
			MenuOptions.modulate = Color("#ffc070")
			MenuCredits.modulate = Color("#ffffff")
			MenuExit.modulate = Color("#ffffff")
		2:
			MenuStart.modulate = Color("#ffffff")
			MenuOptions.modulate = Color("#ffffff")
			MenuCredits.modulate = Color("#ffc070")
			MenuExit.modulate = Color("#ffffff")
		3:
			MenuStart.modulate = Color("#ffffff")
			MenuOptions.modulate = Color("#ffffff")
			MenuCredits.modulate = Color("#ffffff")
			MenuExit.modulate = Color("#ffc070")

func scene_timer_timeout():
	get_tree().change_scene_to(go_to)
