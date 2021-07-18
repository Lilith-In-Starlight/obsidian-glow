tool
extends Position2D


export var text = "TEXT"
export var speed := 0.3

onready var Player := $"../Neptune"
onready var Text := $Label
onready var Buttons := $Buttons

var font := DynamicFont.new()
var show_text := false
var vischar := 0.0
func _ready():
	if not Engine.editor_hint:
		Text.modulate.a = 0.0
		Buttons.modulate.a = 0.0


func _process(delta):
	if not Engine.editor_hint:
		update()
		if Player.position.x < position.x:
			Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - position)*0.5 + Vector2(0,10), 0.1)
		else:
			Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - position)*0.5 + Vector2(-64,10), 0.1)
		if Player.position.distance_to(position) < 30:
			if not show_text:
				Buttons.modulate.a = move_toward(Buttons.modulate.a, 1.0, 0.08)
			else:
				Text.modulate.a = move_toward(Text.modulate.a, 1.0, 0.05)
				Buttons.modulate.a = move_toward(Buttons.modulate.a, 0.0, 0.08)
			if Input.is_key_pressed(KEY_DOWN):
				Text.text = text
				if not show_text:
					Text.visible_characters = 0
					vischar = 0.0
					show_text = true
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
		$Label.text = text


func _draw():
	if not Engine.editor_hint:
		if Player.position.distance_to(position) < 30:
			draw_rect(Rect2(-3, -3, 4, 4), Color(0.9,0.5,0.1))
		else:
			draw_rect(Rect2(-2, -2, 2, 2), Color(0.9,0.5,0.1))
