tool
extends Position2D

enum OPTIONS {
	NONE,
	TEXT,
	CUTSCENE,
	SCENE_CHANGE,
	DIALOGUE,
}

enum DIRS {
	LEFT,
	RIGHT
}

export var speed := 0.3

var Player
var HUD
onready var Text := $Label
onready var Buttons := $Buttons
onready var ButtonDown := $Buttons/ButtonDown
onready var ButtonUp := $Buttons/ButtonUp

var font := DynamicFont.new()
var show_text := false
var vischar := 0.0


export(OPTIONS) var down_button = OPTIONS.TEXT
export var down_action := ""
export var down_text := "READ"
export(DIRS) var down_exit_side := DIRS.RIGHT
export(OPTIONS) var up_button = OPTIONS.NONE
export var up_action := ""
export var up_text := "ENTER"
export(DIRS) var up_exit_side := DIRS.RIGHT

var scene_enter := "u"

var down_scene
var up_scene


func _ready():
	Player = get_tree().get_nodes_in_group("player")[0]
	HUD = get_tree().get_nodes_in_group("hud")[0]
	ButtonDown.visible = down_button != OPTIONS.NONE
	ButtonUp.visible = up_button != OPTIONS.NONE
		
	if not Engine.editor_hint:
		Text.modulate.a = 0.0
		Buttons.modulate.a = 0.0
		if down_button == OPTIONS.SCENE_CHANGE:
			down_scene = load("res://Areas/" + down_action + ".tscn")
		if up_button == OPTIONS.SCENE_CHANGE:
			up_scene = load("res://Areas/" + up_action + ".tscn")
		if down_action == Persistent.entered_from or up_action == Persistent.entered_from:
			Player.position = global_position
			Persistent.player_cutscene = "no"


func _process(delta):
	if not Engine.editor_hint:
		update()
		if Player.position.x < global_position.x:
			Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - global_position)*0.5 + Vector2(0,10), 0.1)
		else:
			Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - global_position)*0.5 + Vector2(-64,10), 0.1)
		if Player.position.distance_to(global_position) < 23 and HUD.dialogue.empty():
			if not show_text:
				Buttons.modulate.a = move_toward(Buttons.modulate.a, 1.0, 0.08)
			else:
				Text.modulate.a = move_toward(Text.modulate.a, 1.0, 0.05)
				Buttons.modulate.a = move_toward(Buttons.modulate.a, 0.0, 0.08)
			if Player.move_down and down_button != OPTIONS.NONE:
				match down_button:
					OPTIONS.TEXT:
						Text.text = down_action
						if not show_text:
							Text.visible_characters = 0
							vischar = 0.0
							show_text = true
					OPTIONS.SCENE_CHANGE:
						Player.call("enter_door", global_position.x)
						Persistent.entered_from = get_tree().current_scene.filename.replace("res://Areas/", "").replace(".tscn", "")
						Persistent.next_scene = down_scene
						Persistent.SChangeTimer.start()
					OPTIONS.DIALOGUE:
						HUD.dialogue = Language.line(down_action).duplicate()
			if Player.move_up and up_button != OPTIONS.NONE:
				match up_button:
					OPTIONS.TEXT:
						Text.text = up_action
						if not show_text:
							Text.visible_characters = 0
							vischar = 0.0
							show_text = true
					OPTIONS.SCENE_CHANGE:
						Player.call("enter_door", global_position.x)
						Persistent.next_scene = up_scene
						Persistent.entered_from = get_tree().current_scene.filename.replace("res://Areas/", "").replace(".tscn", "")
						Persistent.SChangeTimer.start()
					OPTIONS.DIALOGUE:
						HUD.dialogue = Language.line(up_action)
		else:
			Buttons.modulate.a = move_toward(Buttons.modulate.a, 0.0, 0.08)
			if show_text:
				Text.modulate.a = move_toward(Text.modulate.a, 0.0, 0.05)
				if Text.modulate.a < 0.001 and Buttons.modulate.a < 0.001:
					show_text = false
		
		if show_text:
			vischar = move_toward(vischar, Text.text.length(), speed)
			Text.visible_characters = int(vischar)
	else:
		$Buttons/ButtonDown.visible = down_button != OPTIONS.NONE
		$Buttons/ButtonDown.text = "[DOWN] " + down_text
		$Buttons/ButtonUp.visible = up_button != OPTIONS.NONE
		$Buttons/ButtonUp.text = "[UP] " + up_text


func _draw():
	if not Engine.editor_hint:
		if Player.position.distance_to(global_position) < 23:
			draw_rect(Rect2(-3, -3, 4, 4), Color(0.9,0.5,0.1))
		else:
			draw_rect(Rect2(-2, -2, 2, 2), Color(0.9,0.5,0.1))
