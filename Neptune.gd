extends KinematicBody2D

enum STATES {
	GROUND,
	AIR,
}

const MAX_SPEED := 900.0 # Max speed in every direction
const MAX_WALK := 60.0
const MAX_AIRSPEED := 80.0
const WALK_ACCEL := 10.0
const JUMP_FORCE := -200.0

onready var Animations := $Animations

var speed := Vector2(0, 0)

var gravity := 15.0

var move_left := false
var move_right := false
var move_up := false
var move_down := false
var jump_press := false

var current_state = STATES.GROUND

var direction := "_r"


func _physics_process(delta):
	match current_state:
		STATES.GROUND:
			if move_left and not move_right:
				speed.x = move_toward(speed.x, -MAX_WALK, WALK_ACCEL)
			elif move_right and not move_left:
				speed.x = move_toward(speed.x, MAX_WALK, WALK_ACCEL)
			else:
				speed.x = move_toward(speed.x, 0.0, WALK_ACCEL)
			
			if not is_on_floor():
				current_state = STATES.AIR
			else:
				speed.y = 1
			if jump_press:
				speed.y = JUMP_FORCE
				current_state = STATES.AIR
			
			if speed.x > 0:
				direction = "_r"
			elif speed.x < 0:
				direction = "_l"
			
			# Ground Animations
			if abs(speed.x) > 0:
				Animations.play("walk" + direction)
			else:
				Animations.play("idle" + direction)
		
		STATES.AIR:
			if move_left and not move_right:
				speed.x = move_toward(speed.x, -MAX_AIRSPEED, WALK_ACCEL * 1.1)
			elif move_right and not move_left:
				speed.x = move_toward(speed.x, MAX_AIRSPEED, WALK_ACCEL * 1.1)
			else:
				speed.x = move_toward(speed.x, 0.0, WALK_ACCEL * 0.8)
			
			if is_on_floor():
				current_state = STATES.GROUND
			
			if speed.y < 0:
				Animations.play("jump" + direction)
			else:
				Animations.play("fall" + direction)
			
			speed.y += gravity
	
	if speed.length() > MAX_SPEED:
		speed = speed.normalized()*MAX_SPEED
	speed = move_and_slide(speed, Vector2.UP)

func _input(event):
	if event is InputEventKey:
		if not event.echo:
			match event.scancode:
				KEY_LEFT:
					move_left = event.pressed
				KEY_RIGHT:
					move_right = event.pressed
				KEY_UP:
					move_up = event.pressed
				KEY_DOWN:
					move_down = event.pressed
				KEY_Z:
					jump_press = event.pressed
