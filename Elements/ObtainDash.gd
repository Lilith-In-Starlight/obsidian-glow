extends Node2D

export var speed := 0.3

onready var Player := $"../../Neptune"
onready var Buttons := $Buttons
onready var ButtonUp := $Buttons/ButtonUp

var font := DynamicFont.new()
var show_text := false
var vischar := 0.0

var time := 0.0



func _ready():		
	Buttons.modulate.a = 0.0
	if Persistent.abilities.has("dash"):
		Buttons.visible = false

func _process(delta):
	time += delta*5
	update()
	if Persistent.abilities.has("dash") or !get_parent().inside:
		ButtonUp.modulate.a = move_toward(ButtonUp.modulate.a, 0.0, 0.08)
	else:
		ButtonUp.modulate.a = move_toward(ButtonUp.modulate.a, 1.0, 0.08)
	if Player.position.x < global_position.x:
		Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - global_position)*0.5 + Vector2(0,10), 0.1)
	else:
		Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - global_position)*0.5 + Vector2(-32,10), 0.1)
	if Player.position.distance_to(global_position) < 30:
		Buttons.modulate.a = move_toward(Buttons.modulate.a, 1.0, 0.08)
		if Player.move_up and not Persistent.abilities.has("dash") and get_parent().inside:
			Persistent.abilities.append("dash")
			get_tree().get_nodes_in_group("hud")[0].c_menu = get_tree().get_nodes_in_group("hud")[0].MENUS.DASH
	else:
		Buttons.modulate.a = move_toward(Buttons.modulate.a, 0.0, 0.08)


func _draw():
	if not Engine.editor_hint:
		if Player.position.distance_to(global_position) < 30:
			draw_rect(Rect2(-5, -5 + cos(time), 7, 7), Color(1.0,1.0,1.0))
		else:
			draw_rect(Rect2(-3, -3 + cos(time), 4, 4), Color(1.0,1.0,1.0))
