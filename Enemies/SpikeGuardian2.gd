extends KinematicBody2D

const SPIKE := preload("res://Projectiles/SpikeProjectile.tscn")

enum STATES {
	GROUND,
	AIR,
	ATTACK,
	DEFEND,
}

onready var Cast := $Raycast

var state = STATES.AIR

var speed := Vector2(0, 0)

var Player

var sees_player := false

var attack := false

var attack_timer := 1.0

var health := 5

var time_since_last_damage := 0.0
var attacks_while_defending := 0


func _ready():
	Player = get_tree().get_nodes_in_group("player")[0]


func _physics_process(delta):
	modulate.r = move_toward(modulate.r, 1.0, 0.05)
	modulate.g = move_toward(modulate.g, 1.0, 0.05)
	modulate.b = move_toward(modulate.b, 1.0, 0.05)
	time_since_last_damage += delta
	Cast.cast_to = (Player.position - global_position).normalized()*250
	if Cast.is_colliding():
		sees_player = Cast.get_collider() == Player
	else:
		sees_player = false 
	match state:
		STATES.AIR:
			speed.y += 30
			
			if attack and abs(speed.y) < 30:
				attack = false
				state = STATES.ATTACK
			
			if is_on_floor():
				state = STATES.GROUND
		
		STATES.GROUND:
			speed.y = 60
			if sees_player:
				if Player.position.x > global_position.x + 20 and attack_timer > 0.1:
					speed.x = move_toward(speed.x, 80, 10)
				elif Player.position.x < global_position.x - 20 and attack_timer > 0.1:
					speed.x = move_toward(speed.x, -80, 10)
				else:
					speed.x = move_toward(speed.x, 0, 10)
				
				attack_timer -= delta
				if attack_timer <= 0.0:
					speed.y = -400
					state = STATES.AIR
					attack = true
				
				if not is_on_floor():
					state = STATES.AIR
		
		STATES.ATTACK:
			
			if is_on_floor():
				state = STATES.GROUND
	
	# Animations
	match state:
		STATES.GROUND:
			if abs(speed.x) < 5:
				$AnimatedSprite.play("default")
			else:
				$AnimatedSprite.play("walk")
				$AnimatedSprite.scale.x = -sign(speed.x)
		
		STATES.AIR:
			if speed.y > 0:
				$AnimatedSprite.play("jump")
			else:
				$AnimatedSprite.play("fall")
				
		STATES.ATTACK:
			$AnimatedSprite.play("attack")
			
			if Player.position.x > global_position.x:
				$AnimatedSprite.scale.x = 1
			else:
				$AnimatedSprite.scale.x = -1
			
	speed = move_and_slide(speed, Vector2.UP)


func _on_frame_changed():
	if $AnimatedSprite.animation == "attack":
		match $AnimatedSprite.frame:
			3:
				speed = (global_position-Player.position).normalized()*80
				var new_spike = SPIKE.instance()
				new_spike.position = global_position
				new_spike.rotation = global_position.angle_to_point(Player.position)
				get_tree().current_scene.get_node("Enemies").add_child(new_spike)
			6:
				attack_timer = 2.0
				state = STATES.AIR

func attacked(d, pos, s):
	if health > 0:
		modulate = Color("#a00000")
		Persistent.shadow += 2.0 + randf()*2.0
	speed = (global_position-pos).normalized()*200 + s
	var prev_health := health
	health -= d
	if health <= 0 and prev_health > 0:
		Persistent.killed.append([get_tree().current_scene.filename, name])
		if Language.not_in_diary("diary_spike_guardian"):
			Persistent.recently_collected.append("diary_spike_guardian")
		Persistent.persands += randi() % 5
		queue_free()
	
	time_since_last_damage = 0
