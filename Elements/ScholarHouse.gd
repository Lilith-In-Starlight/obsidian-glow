extends Node2D

onready var Player := $"../Neptune"

var inside := false
onready var Buttons := $Buttons
onready var ButtonEnter := $Buttons/Enter
onready var ButtonLeave := $Buttons/Leave

onready var ButtonsLibrarian := $Buttons2

var Dialogue

var had_it_already := false

func _ready():
	Dialogue = get_tree().get_nodes_in_group("hud")[0]
	had_it_already = Persistent.got_diary

func _process(delta):
	update()
	$StaticBody2D/CollisionPolygon2D.disabled = !inside
	if inside:
		ButtonEnter.visible = false
		ButtonLeave.visible = true
		ButtonsLibrarian.visible = true
		$house.modulate.a = move_toward($house.modulate.a, 0.0, 0.05)
	else:
		$house.modulate.a = move_toward($house.modulate.a, 1.0, 0.05)
		ButtonEnter.visible = true
		ButtonLeave.visible = false
		ButtonsLibrarian.visible = true
	
	if Player.position.x < global_position.x:
		Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - position)*0.5 + Vector2(0,10), 0.1)
	else:
		Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - position)*0.5 + Vector2(-32,10), 0.1)
	if Player.position.distance_to(global_position) < 30:
		Buttons.modulate.a = move_toward(Buttons.modulate.a, 1.0, 0.08)
	else:
		Buttons.modulate.a = move_toward(Buttons.modulate.a, 0.0, 0.08)
	
	
	if Player.position.x < $librarian.global_position.x:
		ButtonsLibrarian.rect_position = lerp(ButtonsLibrarian.rect_position, -(Player.position - $librarian.position)*0.5 + Vector2(0,10) + Vector2(85, 85), 0.1)
	else:
		ButtonsLibrarian.rect_position = lerp(ButtonsLibrarian.rect_position, -(Player.position - $librarian.position)*0.5 + Vector2(-32,10) + Vector2(85, 85), 0.1)
	if Player.position.distance_to($librarian.global_position) < 30 and Dialogue.dialogue.empty() and inside:
		ButtonsLibrarian.modulate.a = move_toward(ButtonsLibrarian.modulate.a, 1.0, 0.08)
	else:
		ButtonsLibrarian.modulate.a = move_toward(ButtonsLibrarian.modulate.a, 0.0, 0.08)

func _input(event):
	if Input.is_action_just_pressed("up"):
		if Player.position.distance_to(position) < 30:
			inside = !inside
		elif Player.position.distance_to($librarian.global_position) < 30 and Dialogue.dialogue.empty() and inside:
			if not Persistent.got_diary:
				Dialogue.dialogue = [
							"Ah. As darkness foretold.", 
							"I find your existence difficult to believe, but alas, you're here.", 
							"Greetings, Ailment. I am the Librarian. I travel the world in search for information.", "I have been tasked with giving you something, and in turn you must do me a favor.",
							"You are going to travel the world. I used to be capable of that, but my youth is falling apart.",
							"Without traveling, there is no world, no information. So, please, take this diary and write on it, or draw, or anything. This will be of aid to you in your travels.",
							"It is incomplete, however. Visit the spike gardeners, east of here. They are great magicians, and friends of mine, they will know what to do."
					]
				Persistent.got_diary = true
			else:
				Dialogue.dialogue = [
						"Goodbye, little sickness. Continue your journeys, there's a lot of world for you to see."
					]
	else:
		if (Input.is_action_just_released("jump") or Input.is_action_just_released("attack")) and Dialogue.dialogue.empty():
			if not had_it_already and Persistent.got_diary:
				Dialogue.c_menu = Dialogue.MENUS.DIARY
				had_it_already = true


func _draw():
	if not Engine.editor_hint:
		if Player.position.distance_to(global_position) < 30:
			draw_rect(Rect2(-3, -3, 4, 4), Color(0.9,0.5,0.1))
		else:
			draw_rect(Rect2(-2, -2, 2, 2), Color(0.9,0.5,0.1))
