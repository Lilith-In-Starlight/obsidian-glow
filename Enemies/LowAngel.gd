extends KinematicBody2D



enum STATES {
	IDLE,
	ATTACKING,
	RELEASE,
	WAITING,
}

const FIREBALL := preload("res://Projectiles/Fireball.tscn")

onready var Ray := $RayCast
onready var Animations := $AnimatedSprite
onready var Player := $"../../Neptune"
var state = STATES.IDLE
var speed := Vector2(0, 0)
var noise := OpenSimplexNoise.new()
var time := 0.0
var time_attack := 0.0
var health := 5

func _ready():
	noise.seed = hash(name)

func _physics_process(delta):
	if health > 0:
		var randv := Vector2(noise.get_noise_2d(position.x, time * 60) * 100, noise.get_noise_2d(position.y, time * 60) * 100)
		time += delta
		Ray.cast_to = Player.position - position
		if Player.position.x > position.x:
			Animations.scale.x = 1
		else:
			Animations.scale.x = -1
		match state:
			STATES.IDLE:
				play("default")
				speed = randv
				if Ray.is_colliding():
					if Ray.get_collider() == Player and Player.position.distance_to(position) < 400:
						speed = lerp(speed, (Player.position - position + randv*0.2).normalized()*30, 0.1)
						if Player.position.distance_to(position) < 200:
							state = STATES.ATTACKING
			STATES.ATTACKING:
				play("attack")
				if Player.position.distance_to(position) > 40:
					speed = lerp(speed, (Player.position - position + randv).normalized()*50, 0.1)
				else:
					speed = lerp(speed, (position-Player.position + randv).normalized()*50, 0.1)
				time_attack += delta
				if Player.position.distance_to(position) < 45:
					if time_attack > 2.3:
						time_attack = 0.0
						var nf := FIREBALL.instance()
						nf.position = position
						nf.direction = (Player.position-position).normalized()
						get_parent().add_child(nf)
						speed = (position-Player.position).normalized()*40
						state = STATES.RELEASE
			STATES.RELEASE:
				play("release")
				speed = lerp(speed, randv, 0.02)
				time_attack += delta
				if time_attack > 1.5:
					time_attack = 0.0
					state = STATES.IDLE
		if Persistent.player_cutscene != "no":
			state = STATES.IDLE
	else:
		speed.y += 8
		if is_on_floor():
			speed.x *= 0.75
			play("dead")
		else:
			play("die")
	move_and_slide(speed, Vector2.UP)

func attacked(d, pos, s):
	Persistent.shadow += 1.0 + randf()*2.0
	speed = (position-pos).normalized()*200 + s
	var prev_health := health
	health -= d
	if health <= 0 and prev_health > 0:
		Persistent.persands += randi() % 5
	

func play(anim:String):
	if Animations.animation != anim or not Animations.playing:
		Animations.play(anim)
