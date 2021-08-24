extends Node2D

const SPIKE_GARDENER := preload("res://Enemies/SpikeGuardian.tscn")
const SPIKE_GARDENER2 := preload("res://Enemies/SpikeGuardian2.tscn")
const SPIKE_TRAP := preload("res://Enemies/SpikeTrap.tscn")

var Player
var HUD
onready var Buttons := $Buttons
onready var ButtonUp := $Buttons/ButtonUp

var challenged := false
var fight := 0
var health := 1
var fight_set := false

var timer := 3.0


func _ready():
	Player = get_tree().get_nodes_in_group("player")[0]
	HUD = get_tree().get_nodes_in_group("hud")[0]


func _process(delta):
	update()
	if not challenged:
		if Player.position.x < global_position.x:
			Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - global_position)*0.5 + Vector2(0,10), 0.1)
		else:
			Buttons.rect_position = lerp(Buttons.rect_position, -(Player.position - global_position)*0.5 + Vector2(-64,10), 0.1)
		
		if Player.position.distance_to(global_position) < 23:
			Buttons.modulate.a = move_toward(Buttons.modulate.a, 1.0, 0.08)
			if Player.move_up:
				challenged = true
		else:
			Buttons.modulate.a = move_toward(Buttons.modulate.a, 0.0, 0.08)
	else:
		Buttons.modulate.a = move_toward(Buttons.modulate.a, 0.0, 0.08)
		
		match fight:
			0:
				if not fight_set:
					spawn_gardener(-100, 1)
					fight_set = true
			1:
				if not fight_set:
					spawn_gardener(-100, 1)
					spawn_gardener(100, 1)
					fight_set = true
			2:
				if not fight_set:
					spawn_gardener(-50, 1)
					spawn_gardener(50, 1)
					fight_set = true
			3:
				if not fight_set:
					spawn_gardener(0, 1)
					for i in range(-3, 4):
						var new_trap := SPIKE_TRAP.instance()
						$Plants.add_child(new_trap)
						new_trap.name = str(i)
						new_trap.position.x = i*15
						new_trap.position.y = 15
					fight_set = true
			4:
				if not fight_set:
					spawn_gardener(100, 1)
					spawn_gardener(-100, 1)
					for i in range(-15, 10):
						var new_trap := SPIKE_TRAP.instance()
						if $Plants.get_node_or_null(str(i)) == null:
							$Plants.add_child(new_trap)
							new_trap.name = str(i)
							new_trap.position.x = i*15
							new_trap.position.y = 15
					fight_set = true
			5:
				if not fight_set:
					spawn_gardener(0, 2)
					for i in $Plants.get_children():
						i.queue_free()
					fight_set = true
			6:
				if not fight_set:
					spawn_gardener(-100, 2)
					spawn_gardener(100, 2)
					fight_set = true
			7:
				if not fight_set:
					spawn_gardener(-100, 2)
					spawn_gardener(100, 1)
					fight_set = true
			8:
				if not fight_set:
					spawn_gardener(-100, 2)
					spawn_gardener(0, 1)
					spawn_gardener(100, 2)
					for i in range(-3, 4):
						var new_trap := SPIKE_TRAP.instance()
						$Plants.add_child(new_trap)
						new_trap.name = str(i)
						new_trap.position.x = i*15
						new_trap.position.y = 15
					fight_set = true
			9:
				if not fight_set:
					spawn_gardener(-100, 1)
					spawn_gardener(0, 2)
					spawn_gardener(100, 1)
					
					for i in range(-9, 10):
						var new_trap := SPIKE_TRAP.instance()
						$Plants.add_child(new_trap)
						new_trap.name = str(i)
						new_trap.position.x = i*15
						new_trap.position.y = 15
					fight_set = true
			10:
				if not fight_set:
					spawn_gardener(-180, 2)
					spawn_gardener(-60, 1)
					spawn_gardener(60, 1)
					spawn_gardener(180, 2)
					
					for i in range(-15, 16):
						var new_trap := SPIKE_TRAP.instance()
						$Plants.add_child(new_trap)
						new_trap.name = str(i)
						new_trap.position.x = i*15
						new_trap.position.y = 15
					fight_set = true
		
		if get_child_count() == 2:
			if timer > 0.0:
				timer -= delta
			else:
				timer = 3.0
				fight_set = false
				fight += 1


func spawn_gardener(x:float, type):
	var new_gardener
	match type:
		1:
			new_gardener = SPIKE_GARDENER.instance()
		2:
			print("a")
			new_gardener = SPIKE_GARDENER2.instance()
	new_gardener.name = str(randi())
	add_child(new_gardener)
	new_gardener.position.x = x
	new_gardener.position.y = -100

func _draw():
	if not challenged:
		if not Engine.editor_hint:
			if Player.position.distance_to(global_position) < 23:
				draw_rect(Rect2(-3, -3, 4, 4), Color(0.9,0.5,0.1))
			else:
				draw_rect(Rect2(-2, -2, 2, 2), Color(0.9,0.5,0.1))
