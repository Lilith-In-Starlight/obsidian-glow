extends KinematicBody2D

enum STATES {
	GROUND,
	AIR,
	ATTACK,
}

const MAX_SPEED := 900.0 # Max speed in every direction
const MAX_WALK := 150.0
const MAX_AIRSPEED := 180.0
const WALK_ACCEL := 50.0
const JUMP_FORCE := -200.0

onready var Animations := $Animations

var speed := Vector2(0, 0)

var gravity := 13.0

var move_left := false
var move_right := false
var move_up := false
var move_down := false
var jump_press := false
var att_press := false

var current_state = STATES.GROUND

var direction := "_r"

var AttackTimer := Timer.new()
var ReAttackTimer := Timer.new()
var can_attack := true

var press_opposite := false
var attack_echo := false

func _ready():
	add_child(AttackTimer)
	AttackTimer.wait_time = 0.22
	AttackTimer.one_shot = true
	AttackTimer.connect("timeout", self, "attack_ended")
	add_child(ReAttackTimer)
	ReAttackTimer.wait_time = 0.08
	ReAttackTimer.one_shot = true
	ReAttackTimer.connect("timeout", self, "attack_again")


func _physics_process(delta):
	match current_state:
		STATES.GROUND:
			if move_left and not move_right:
				speed.x = move_toward(speed.x, -MAX_WALK, WALK_ACCEL * delta*60)
			elif move_right and not move_left:
				speed.x = move_toward(speed.x, MAX_WALK, WALK_ACCEL * delta*60)
			else:
				speed.x = move_toward(speed.x, 0.0, WALK_ACCEL * delta*60)
			
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
				play("walk" + direction)
			else:
				play("idle" + direction)
			
			if att_press and can_attack and not attack_echo:
				current_state = STATES.ATTACK
				AttackTimer.start()
			
		
		STATES.AIR:
			if move_left and not move_right:
				speed.x = move_toward(speed.x, -MAX_AIRSPEED, WALK_ACCEL * 1.1 * delta*60)
			elif move_right and not move_left:
				speed.x = move_toward(speed.x, MAX_AIRSPEED, WALK_ACCEL * 1.1 * delta*60)
			else:
				speed.x = move_toward(speed.x, 0.0, WALK_ACCEL * 0.8 * delta*60)
			
			if is_on_floor():
				current_state = STATES.GROUND
			
			if speed.y < 0:
				play("jump" + direction)
			else:
				play("fall" + direction)
			
			speed.y += gravity
			
			if att_press and can_attack and not attack_echo:
				current_state = STATES.ATTACK
				AttackTimer.start()
		
		STATES.ATTACK:
			can_attack = false
			if direction == "_l":
				if move_right or press_opposite:
					speed.x = move_toward(speed.x, MAX_WALK*2.0, 10)
					speed.y = move_toward(speed.y, 0, 20)
					press_opposite = true
					play("spin_l")
				else:
					speed.x = move_toward(speed.x, -MAX_WALK*5.0, 30)
					speed.y = move_toward(speed.y, 0, 20)
					play("attack_l")
			else:
				if move_left or press_opposite:
					speed.x = move_toward(speed.x, -MAX_WALK*2.0, 10)
					speed.y = move_toward(speed.y, 0, 20)
					press_opposite = true
					play("spin_r")
				else:
					speed.x = move_toward(speed.x, MAX_WALK*5.0, 30)
					speed.y = move_toward(speed.y, 0, 20)
					play("attack_r")
				
	
	if speed.length() > MAX_SPEED:
		speed = speed.normalized()*MAX_SPEED
	speed = move_and_slide(speed, Vector2.UP)
	
	if att_press:
		attack_echo = true
	else:
		attack_echo = false

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
				KEY_C:
					att_press = event.pressed

func attack_ended():
	if Animations.animation.find("spin") == -1:
		current_state = STATES.AIR
		press_opposite = false
		ReAttackTimer.start()

func attack_again():
	can_attack = true


func play(anim:String):
	if Animations.animation != anim:
		Animations.play(anim)


func _on_animation_finished():
	if Animations.animation.find("spin") != -1:
		current_state = STATES.AIR
		press_opposite = false
		ReAttackTimer.start()
		
