extends Position2D

export var speed := 0.3

onready var Player := $"../Neptune"
onready var Text := $Label
onready var Buttons := $Buttons
onready var ButtonUp := $Buttons/ButtonUp

var font := DynamicFont.new()
var show_text := false
var vischar := 0.0



func _ready():		
	Text.modulate.a = 0.0
	Buttons.modulate.a = 0.0
	if Persistent.abandoned_ticket:
		Buttons.visible = false

func _process(delta):
	update()
	if Persistent.abandoned_ticket:
		ButtonUp.modulate.a = move_toward(ButtonUp.modulate.a, 0.0, 0.08)
	if Player.position.x < position.x:
		Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - position)*0.5 + Vector2(0,10), 0.1)
	else:
		Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - position)*0.5 + Vector2(-32,10), 0.1)
	if Player.position.distance_to(position) < 30:
		Text.modulate.a = move_toward(Text.modulate.a, 1.0, 0.05)
		Buttons.modulate.a = move_toward(Buttons.modulate.a, 1.0, 0.08)
		vischar = move_toward(vischar, Text.text.length(), speed)
		Text.visible_characters = int(vischar)
		if Player.move_up:
			Persistent.abandoned_ticket = true
	else:
		Buttons.modulate.a = move_toward(Buttons.modulate.a, 0.0, 0.08)
		Text.modulate.a = move_toward(Text.modulate.a, 0.0, 0.05)


func _draw():
	if not Engine.editor_hint:
		if Player.position.distance_to(position) < 30:
			draw_rect(Rect2(-3, -3, 4, 4), Color(0.9,0.5,0.1))
		else:
			draw_rect(Rect2(-2, -2, 2, 2), Color(0.9,0.5,0.1))
