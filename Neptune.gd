extends KinematicBody2D

signal door_entered

enum STATES {
	GROUND,
	AIR,
	ATTACK,
}

const MAX_SPEED := 900.0 # Max speed in every direction
const MAX_WALK := 110.0
const MAX_AIRSPEED := 140.0
const WALK_ACCEL := 20.0
const JUMP_FORCE := -200.0

onready var Animations := $Animations
onready var AttackParticle := $AttackParticle

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

var entering_door := false
var door_position := 0.0

func _ready():
	add_child(AttackTimer)
	AttackTimer.wait_time = 0.22
	AttackTimer.one_shot = true
	AttackTimer.connect("timeout", self, "attack_ended")
	add_child(ReAttackTimer)
	ReAttackTimer.wait_time = 0.08
	ReAttackTimer.one_shot = true
	ReAttackTimer.connect("timeout", self, "attack_again")

func _process(delta):
	# Create the inputs
	if not entering_door:
		move_up = Input.is_key_pressed(KEY_UP)
		move_down = Input.is_key_pressed(KEY_DOWN)
		move_left = Input.is_key_pressed(KEY_LEFT)
		move_right = Input.is_key_pressed(KEY_RIGHT)
		jump_press = Input.is_key_pressed(KEY_Z)
		att_press = Input.is_key_pressed(KEY_C)
	else:
		move_up = false
		move_down = false
		jump_press = false
		att_press = false
		if abs(door_position - position.x) > 5:
			if door_position < position.x:
				move_left = true
				move_right = false
			else:
				move_right = true
				move_left = false
		else:
			move_left = false
			move_right = false
			if abs(speed.x) < 2:
				play("enter_door")


func _physics_process(delta):
	AttackParticle.visible = current_state == STATES.ATTACK
	if current_state != STATES.ATTACK:
		AttackParticle.animation = "default"
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
					attack_play(1)
				else:
					speed.x = move_toward(speed.x, -MAX_WALK*5.0, 30)
					speed.y = move_toward(speed.y, 0, 20)
					play("attack_l")
					attack_play(0)
			else:
				if move_left or press_opposite:
					speed.x = move_toward(speed.x, -MAX_WALK*2.0, 10)
					speed.y = move_toward(speed.y, 0, 20)
					press_opposite = true
					play("spin_r")
					attack_play(1)
				else:
					speed.x = move_toward(speed.x, MAX_WALK*5.0, 30)
					speed.y = move_toward(speed.y, 0, 20)
					play("attack_r")
					attack_play(0)
				
	
	if speed.length() > MAX_SPEED:
		speed = speed.normalized()*MAX_SPEED
	speed = move_and_slide_with_snap(speed, Vector2.DOWN, Vector2.UP, true)
	
	if att_press:
		attack_echo = true
	else:
		attack_echo = false

func attack_ended():
	if Animations.animation.find("spin") == -1:
		current_state = STATES.AIR
		press_opposite = false
		ReAttackTimer.start()

func attack_again():
	can_attack = true


func play(anim:String):
	if Animations.animation != anim or not Animations.playing:
		if not(Animations.animation == "enter_door" and entering_door):
			Animations.play(anim)

func attack_play(anim:int):
	if direction == "_l":
		AttackParticle.scale.x = -1
	else:
		AttackParticle.scale.x = 1
	if anim == 0:
		if AttackParticle.animation != "default":
			AttackParticle.play("default")
	elif anim == 1:
		if direction == "_l":
			if AttackParticle.animation != "spin_l":
				AttackParticle.play("spin_l")
		elif AttackParticle.animation != "spin":
			AttackParticle.play("spin")


func _on_animation_finished():
	if Animations.animation.find("spin") != -1:
		current_state = STATES.AIR
		press_opposite = false
		ReAttackTimer.start()
	if Animations.animation == "enter_door":
		emit_signal("door_entered")


func enter_door(x):
	entering_door = true
	door_position = x
