extends KinematicBody2D

enum STATES {
	IDLE,
	DASHING,
	RESTING,
}

onready var Cast := $RayCast2D
onready var Player := $"../../Neptune"

var speed := Vector2(0, 0)
var health := 3
var current_state = STATES.IDLE
var dash_to := Vector2(0, 0)
var non_dash := 3.0

func _ready():
	speed = Vector2(randf(), randf()).normalized()*150

func _physics_process(delta):
	Cast.cast_to = Player.position - position
	if position.y < Player.Cam.limit_top:
		position.y = Player.Cam.limit_top
		speed.y = abs(speed.y)
	if position.x < Player.Cam.limit_left:
		position.x = Player.Cam.limit_left
		speed.x = abs(speed.x)
	elif position.x > Player.Cam.limit_right:
		position.x = Player.Cam.limit_right
		speed.x = -abs(speed.x)
	match current_state:
		STATES.IDLE:
			if Cast.is_colliding() and Cast.get_collision_point().distance_to(Player.position) < 20 and position.distance_to(Player.position) < 200 and non_dash <= 1.0 and non_dash > 0.0:
				$AnimatedSprite.play("dash")
			elif Cast.is_colliding() and Cast.get_collision_point().distance_to(Player.position) < 20 and position.distance_to(Player.position) < 200 and non_dash <= 0.0:
				current_state = STATES.DASHING
				$AnimatedSprite.play("dash")
				dash_to = Player.position
			else:
				$AnimatedSprite.play("default")
				speed += (speed.normalized()*150-speed) / 5.0
			non_dash -= delta
			if is_on_wall():
				speed.x *= -1
			if is_on_floor():
				speed.y = -abs(speed.y)
			if is_on_ceiling():
				speed.y = abs(speed.y)
				
		STATES.DASHING:
			if position.distance_to(dash_to) > 20:
				speed = (dash_to - position).normalized() * 400
			else:
				non_dash = 3.0
				$AnimatedSprite.play("default")
				current_state = STATES.IDLE
		
	if health <= 0:
		queue_free()
	
	move_and_slide(speed, Vector2.UP)
	
func attacked(d, pos, s):
	Persistent.shadow += 2.0 + randf()*4.0
	speed = (position-pos).normalized()*200 + s
	var prev_health := health
	health -= d
	if health <= 0 and prev_health > 0:
		Persistent.persands += randi() % 5
		if not Persistent.diary.has("diary_angel_ball") and not Persistent.recently_collected.has("diary_angel_ball"):
			Persistent.recently_collected.append("diary_angel_ball")
		
func _on_body_entered(body):
	if body.name == "Neptune":
		body.call("attacked", 1, position, speed.normalized()*110)
