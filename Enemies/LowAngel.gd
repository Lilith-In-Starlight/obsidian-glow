extends KinematicBody2D


enum STATES {
	IDLE,
	ATTACKING,
	RELEASE,
	WAITING,
}
onready var Ray := $RayCast
onready var Animations := $AnimatedSprite
onready var Player := $"../../Neptune"
var state = STATES.IDLE
var speed := Vector2(0, 0)
var noise := OpenSimplexNoise.new()
var time := 0.0
var tim

func _physics_process(delta):
	var randv := Vector2(noise.get_noise_2d(position.x, time * 60) * 100, noise.get_noise_2d(position.y, time * 60) * 100)
	time += delta
	Ray.cast_to = Player.position - position
	
	match state:
		STATES.IDLE:
			speed = randv
			if Ray.is_colliding():
				if Ray.get_collider() == Player and Player.position.distance_to(position) < 300:
					state = STATES.ATTACKING
		STATES.ATTACKING:
			play("attack")
			if Player.position.distance_to(position) > 70:
				speed = lerp(speed, (Player.position - position + randv).normalized()*30, 0.1)
			else:
				speed = lerp(speed, (position-Player.position + randv).normalized()*30, 0.1)
	move_and_slide(speed)


func play(anim:String):
	if Animations.animation != anim or not Animations.playing:
		Animations.play(anim)
