extends Node2D

export var speed := 0.3

onready var Player := $"../Neptune"
onready var Buttons := $Buttons
onready var ButtonUp := $Buttons/ButtonUp

var font := DynamicFont.new()
var show_text := false
var vischar := 0.0



func _ready():		
	Buttons.modulate.a = 0.0
	if Persistent.abilities.has("dash"):
		Buttons.visible = false

func _process(delta):
	update()
	if Persistent.abilities.has("dash"):
		ButtonUp.modulate.a = move_toward(ButtonUp.modulate.a, 0.0, 0.08)
	if Player.position.x < position.x:
		Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - position)*0.5 + Vector2(0,10), 0.1)
	else:
		Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - position)*0.5 + Vector2(-32,10), 0.1)
	if Player.position.distance_to(position) < 30:
		Buttons.modulate.a = move_toward(Buttons.modulate.a, 1.0, 0.08)
		if Player.move_up and not Persistent.abilities.has("dash"):
			Persistent.abilities.append("dash")
			get_tree().get_nodes_in_group("hud")[0].c_menu = get_tree().get_nodes_in_group("hud")[0].MENUS.DASH
	else:
		Buttons.modulate.a = move_toward(Buttons.modulate.a, 0.0, 0.08)


func _draw():
	if not Engine.editor_hint:
		if Player.position.distance_to(position) < 30:
			draw_rect(Rect2(-3, -3, 4, 4), Color(0.9,0.5,0.1))
		else:
			draw_rect(Rect2(-2, -2, 2, 2), Color(0.9,0.5,0.1))
