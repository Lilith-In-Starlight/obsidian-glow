extends Node2D

onready var Player := $"../Neptune"

var inside := false
onready var Buttons := $Buttons
onready var ButtonEnter := $Buttons/Enter
onready var ButtonLeave := $Buttons/Leave

func _process(delta):
	update()
	$StaticBody2D/CollisionPolygon2D.disabled = !inside
	if inside:
		ButtonEnter.visible = false
		ButtonLeave.visible = true
		$house.modulate.a = move_toward($house.modulate.a, 0.0, 0.05)
	else:
		$house.modulate.a = move_toward($house.modulate.a, 1.0, 0.05)
		ButtonEnter.visible = true
		ButtonLeave.visible = false
	
	if Player.position.x < global_position.x:
		Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - position)*0.5 + Vector2(0,10), 0.1)
	else:
		Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - position)*0.5 + Vector2(-32,10), 0.1)
	if Player.position.distance_to(global_position) < 30:
		Buttons.modulate.a = move_toward(Buttons.modulate.a, 1.0, 0.08)
	else:
		Buttons.modulate.a = move_toward(Buttons.modulate.a, 0.0, 0.08)

func _input(event):
	if event is InputEventKey and not event.is_echo() and event.is_pressed():
		if event.scancode == KEY_UP and Player.position.distance_to(position) < 30:
			inside = !inside




func _draw():
	if not Engine.editor_hint:
		if Player.position.distance_to(global_position) < 30:
			draw_rect(Rect2(-3, -3, 4, 4), Color(0.9,0.5,0.1))
		else:
			draw_rect(Rect2(-2, -2, 2, 2), Color(0.9,0.5,0.1))
