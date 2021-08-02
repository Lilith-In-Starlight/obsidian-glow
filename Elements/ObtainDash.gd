extends Node2D

export var speed := 0.3

onready var Player := $"../../Neptune"
onready var Buttons := $Buttons
onready var ButtonUp := $Buttons/ButtonUp

var font := DynamicFont.new()
var show_text := false
var vischar := 0.0
var HUD

var time := 0.0


func _ready():
	# The buttons start out invisible
	Buttons.modulate.a = 0.0
	# If the player has the dash, remove them entirely
	if Persistent.abilities.has("dash"):
		Buttons.visible = false
	
	HUD = get_tree().get_nodes_in_group("hud")[0]


func _process(delta):
	time += delta*5
	update()
	
	# If the player isn't inside the librarian's house or if it has the dash
	# the button should not be visible
	if Persistent.abilities.has("dash") or !get_parent().inside:
		ButtonUp.modulate.a = move_toward(ButtonUp.modulate.a, 0.0, 0.08)
	else:
		ButtonUp.modulate.a = move_toward(ButtonUp.modulate.a, 1.0, 0.08)
	
	# Controls at which side the options are shown
	if Player.position.x < global_position.x:
		Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - global_position)*0.5 + Vector2(0,10), 0.1)
	else:
		Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - global_position)*0.5 + Vector2(-32,10), 0.1)
	
	# If the player is close, show the options
	if Player.position.distance_to(global_position) < 30:
		Buttons.modulate.a = move_toward(Buttons.modulate.a, 1.0, 0.08)
		# Only interact if the player doesn't have dash and is inside
		if Player.move_up and not Persistent.abilities.has("dash") and get_parent().inside:
			Persistent.abilities.append("dash")
			HUD.c_menu = HUD.MENUS.DASH
	else:
		Buttons.modulate.a = move_toward(Buttons.modulate.a, 0.0, 0.08)


func _draw():
	# The square that indicates interaction
	if not Engine.editor_hint:
		if Player.position.distance_to(global_position) < 30:
			draw_rect(Rect2(-5, -5 + cos(time), 7, 7), Color(1.0,1.0,1.0))
		else:
			draw_rect(Rect2(-3, -3 + cos(time), 4, 4), Color(1.0,1.0,1.0))
