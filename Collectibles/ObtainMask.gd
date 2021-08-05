extends Node2D


export var mask_name := "none"

onready var Buttons := $Buttons

var Player
var HUD

var time := 0.0


func _ready():
	Player = get_tree().get_nodes_in_group("player")[0]
	HUD = get_tree().get_nodes_in_group("hud")[0]
	if Persistent.masks.has(mask_name):
		queue_free()


func _process(delta):
	time += delta
	if not Engine.editor_hint:
		update()
		
		if Player.position.x < position.x:
			Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - position)*0.5 + Vector2(0,10), 0.1)
		else:
			Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - position)*0.5 + Vector2(-64,10), 0.1)
		
		if Player.position.distance_to(position) < 30 and not Persistent.masks.has(mask_name):
			Buttons.modulate.a = move_toward(Buttons.modulate.a, 1.0, 0.08)
			if Player.move_up:
				Persistent.masks.append(mask_name)
				HUD.MaskNotificationImage.texture = Persistent.mask_textures[mask_name]
				HUD.mask_collected()
		else:
			Buttons.modulate.a = move_toward(Buttons.modulate.a, 0.0, 0.08)


func _draw():
	# The square that indicates interaction
	if not Engine.editor_hint:
		if Player.position.distance_to(global_position) < 30:
			draw_rect(Rect2(-5, -5 + cos(time), 7, 7), Color(1.0,1.0,1.0))
		else:
			draw_rect(Rect2(-3, -3 + cos(time), 4, 4), Color(1.0,1.0,1.0))
