extends KinematicBody2D


enum STATES {
	IDLE, # Hasn't seen the player
	CHARGING, # Saw the player and is ready to attack
	SLASHING, # Attacking
	DEFENDING, # The player's getting greedy with attacks
	BREATHING, # Has a random chance of getting tired for a short time
	DEAD,
}

onready var Animations := $Animations
onready var Cast := $RayCast

var Player
var current_state = STATES.IDLE
var speed := Vector2(0, 0)

var health := 5

var attacks_while_defending := 0
var time_since_last_damage := 0.0

var noise := OpenSimplexNoise.new()
var time := 0.0

var locked := 0.5

func _ready():
	noise.seed = hash(name)
	if Persistent.killed.has([get_tree().current_scene.filename, name]):
		queue_free()
	Player = get_tree().get_nodes_in_group("player")[0]


func _physics_process(delta):
	time += 1
	if locked > -0.1:
		locked -= delta
	Cast.cast_to = Player.position - global_position
	$CheesePreventer.cast_to.x = -30 * Animations.scale.x
	if health <= 0:
		current_state = STATES.DEAD
	time_since_last_damage += delta
	modulate.r = move_toward(modulate.r, 1.0, 0.05)
	modulate.g = move_toward(modulate.g, 1.0, 0.05)
	modulate.b = move_toward(modulate.b, 1.0, 0.05)
	match current_state:
		STATES.IDLE:
			$Hurtbox/CollisionShape2D2.disabled = true
			$SpikeAttack.modulate.a -= 0.1
			if is_on_floor():
				speed.y = 60
				Animations.play("default")
			else:
				Animations.play("fall")
			if not $CheesePreventer.is_colliding():
				if Cast.is_colliding() and Cast.get_collider() == Player:
					if Player.position.distance_to(global_position) < 100 and (Player.position.y > global_position.y - 10 or Player.current_state == Player.STATES.AIR) and is_on_floor() and locked <= 0.0:
						current_state = STATES.SLASHING
					else:
						speed.x = move_toward(speed.x, clamp(50 * -Animations.scale.x + noise.get_noise_1d(time)*150, -50, 50), 50)
				else:
					speed.x = move_toward(speed.x, 0, 50)
			else:
				if abs($CheesePreventer.get_collision_point().x - global_position.x) < 25:
					speed.x = move_toward(speed.x, 200 * Animations.scale.x, 50)
				else:
					speed.x = move_toward(speed.x, 0, 50)
			
			if Player.position.x > global_position.x:
				Animations.scale.x = -1
			else:
				Animations.scale.x = 1
		
		STATES.CHARGING:
			pass
		STATES.SLASHING:
			$SpikeAttack.modulate.a -= 0.1
			Animations.play("slashing")
		STATES.DEFENDING:
			speed.x *= 0.75
			
			if Player.position.x > global_position.x:
				Animations.scale.x = -1
			else:
				Animations.scale.x = 1
				
			if Player.position.y < global_position.y - 10:
				Animations.play("defend_v")
			else:
				Animations.play("defend_h")
			
			if attacks_while_defending >= 3:
				if $SpikeAttack.modulate.a < 0:
					$SpikeAttack.modulate.a = 0
				$SpikeAttack.modulate.a += 0.01
				if $SpikeAttack.modulate.a >= 1.0:
					$Hurtbox/CollisionShape2D2.disabled = false
					if Language.not_in_diary("diary_spike_guardian"):
						Persistent.recently_collected.append("diary_spike_guardian")
					if Language.not_in_diary("diary_spike_guardian_magic"):
						Persistent.recently_collected.append("diary_spike_guardian_magic")
					current_state = STATES.IDLE
			else:
				if time_since_last_damage > 0.7:
					attacks_while_defending = 0
					current_state = STATES.IDLE
			
				
		STATES.BREATHING:
			Animations.play("breath")
			$Hurtbox/CollisionShape2D.disabled = true
			
			if not $CheesePreventer.is_colliding():
				speed.x *= 0.75
			else:
				speed.x = move_toward(speed.x, 200 * Animations.scale.x, 50)
			
		STATES.DEAD:
			$Hurtbox/CollisionShape2D2.disabled = true
			$SpikeAttack.modulate.a -= 0.1
			$Hurtbox/CollisionShape2D.disabled = true
			speed.x *= 0.75
			Animations.play("dead")
	
	speed.y += 30
	
	if is_on_floor():
		speed.y = 60
	
	match Animations.animation:
		"default", "fall":
			Animations.position = Vector2(0, 0)
		"slashing", "breath":
			Animations.position = Vector2(-7 * Animations.scale.x, 0)
		"dead":
			Animations.position = Vector2(-2 * Animations.scale.x, 0)
		"defend_h":
			Animations.position = Vector2(-4 * Animations.scale.x, 1)
		"defend_v":
			Animations.position = Vector2(-2 * Animations.scale.x, -3)
	
	speed = move_and_slide(speed, Vector2.UP)


func _on_animation_finished():
	match Animations.animation:
		"slashing":
			if current_state != STATES.DEAD:
				if randi()%10 != 1:
					current_state = STATES.IDLE
				else:
					current_state = STATES.BREATHING
		"breath":
			if current_state != STATES.DEAD:
				current_state = STATES.IDLE


func _on_frame_changed():
	match Animations.animation:
		"slashing":
			match Animations.frame:
				3, 4:
					$Hurtbox/CollisionShape2D.disabled = false
					$Hurtbox/CollisionShape2D.position.x = -8 * Animations.scale.x
					speed.x = -400 * Animations.scale.x
					speed.y = 0
				5:
					$Hurtbox/CollisionShape2D.disabled = true
					speed.x = 0
				_:
					$Hurtbox/CollisionShape2D.disabled = true
					speed.x *= 0.75


func attacked(d, pos, s):
	if time_since_last_damage > 0.7:
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
	else:
		current_state = STATES.DEFENDING
		attacks_while_defending += 1
	
	time_since_last_damage = 0


func _on_Hurtbox_body_entered(body):
	if body.name == "Neptune":
		body.call("attacked", 1, global_position, speed.normalized()*110)
