extends Node2D

const SPIKE_GARDENER := preload("res://Enemies/SpikeGuardian.tscn")
const SPIKE_GARDENER2 := preload("res://Enemies/SpikeGuardian2.tscn")
const SPIKE_TRAP := preload("res://Enemies/SpikeTrap.tscn")

var Player
var HUD
onready var Buttons := $Buttons
onready var ButtonUp := $Buttons/ButtonUp

var challenged := false
var fight := -1
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
			-1:
				if not fight_set:
					fight_set = true
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
		
		if get_child_count() == 3:
			if timer > 0.0:
				timer -= delta
				match fight+1:
					0:
						set_platform(1, -100, 1)
					1:
						set_platform(1, -100, 1)
						set_platform(2, 100, 1)
					2:
						set_platform(1, -50, 1)
						set_platform(2, 50, 1)
					3:
						set_platform(1, 0, 1)
					4:
						set_platform(1, 100, 1)
						set_platform(2, -100, 1)
					5:
						set_platform(1, 0, 2)
					6:
						set_platform(1, -100, 2)
						set_platform(2, 100, 2)
					7:
						set_platform(1, -100, 2)
						set_platform(2, 100, 1)
					8:
						set_platform(1, -100, 2)
						set_platform(2, 0, 1)
						set_platform(3, 100, 2)
					9:
						set_platform(1, -100, 1)
						set_platform(2, 0, 2)
						set_platform(3, 100, 1)
					10:
						set_platform(1, -180, 2)
						set_platform(2, -60, 1)
						set_platform(3, 60, 1)
						set_platform(4, 180, 2)
					11:
						for i in $Plants.get_children():
							i.queue_free()
			else:
				timer = 3.0
				fight_set = false
				fight += 1
				
				match fight:
					0:
						quit_platform(1)
					1:
						quit_platform(1)
						quit_platform(2)
					2:
						quit_platform(1)
						quit_platform(2)
					3:
						quit_platform(1)
					4:
						quit_platform(1)
						quit_platform(2)
					5:
						quit_platform(1)
					6:
						quit_platform(1)
						quit_platform(2)
					7:
						quit_platform(1)
						quit_platform(2)
					8:
						quit_platform(1)
						quit_platform(2)
						quit_platform(3)
					9:
						quit_platform(1)
						quit_platform(2)
						quit_platform(3)
					10:
						quit_platform(1)
						quit_platform(2)
						quit_platform(3)
						quit_platform(4)
				


func spawn_gardener(x:float, type):
	var new_gardener
	match type:
		1:
			new_gardener = SPIKE_GARDENER.instance()
		2:
			new_gardener = SPIKE_GARDENER2.instance()
	new_gardener.name = str(randi())
	add_child(new_gardener)
	new_gardener.position.x = x
	new_gardener.position.y = -100
	new_gardener.speed.y = -250

func _draw():
	if not challenged:
		if not Engine.editor_hint:
			if Player.position.distance_to(global_position) < 23:
				draw_rect(Rect2(-3, -3, 4, 4), Color(0.9,0.5,0.1))
			else:
				draw_rect(Rect2(-2, -2, 2, 2), Color(0.9,0.5,0.1))

func set_platform(p:=1, pos:= 0.0, g:=1):
	var plat
	var anims
	var guy
	var tex
	match p:
		1:
			plat = $Platforms/P1
			anims = $Platforms/P1/Animations
			guy = $Platforms/P1/Platform/Guy
		2:
			plat = $Platforms/P2
			anims = $Platforms/P2/Animations
			guy = $Platforms/P2/Platform/Guy
		3:
			plat = $Platforms/P3
			anims = $Platforms/P3/Animations
			guy = $Platforms/P3/Platform/Guy
		4:
			plat = $Platforms/P4
			anims = $Platforms/P4/Animations
			guy = $Platforms/P4/Platform/Guy
	
	match g:
		1:
			tex = preload("res://Sprites/Enemies/SpikeGuardian/idle.png")
		2:
			tex = preload("res://Sprites/Enemies/SpikeGuardian2/idle.png")
			
	plat.position.x = pos
	anims.play("Enter")
	guy.texture = tex
	guy.visible = true


func quit_platform(p:=1):
	var anims
	var guy
	match p:
		1:
			anims = $Platforms/P1/Animations
			guy = $Platforms/P1/Platform/Guy
		2:
			anims = $Platforms/P2/Animations
			guy = $Platforms/P2/Platform/Guy
		3:
			anims = $Platforms/P3/Animations
			guy = $Platforms/P3/Platform/Guy
		4:
			anims = $Platforms/P4/Animations
			guy = $Platforms/P4/Platform/Guy
	
	anims.play("Leave")
	guy.visible = false
