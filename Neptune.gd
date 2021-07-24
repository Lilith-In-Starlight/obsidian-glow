extends KinematicBody2D

signal door_entered

enum STATES {
	GROUND,
	AIR,
	DASH,
}

const MAX_SPEED := 900.0 # Max speed in every direction
const MAX_WALK := 80.0
const MAX_AIRSPEED := 160.0
const MAX_WALK_RUN := 130.0
const MAX_AIRSPEED_RUN := 150.0
const WALK_ACCEL := 20.0
const JUMP_FORCE := -250.0

onready var Animations := $Animations
onready var DashParticle := $DashParticle
onready var Hitbox := $Hitbox

var speed := Vector2(0, 0)

var gravity := 13.0

var move_left := false
var move_right := false
var move_up := false
var move_down := false
var jump_press := false
var dash_press := false
var attack_press := false

var current_state = STATES.GROUND

var direction := "_r"

var DashTimer := Timer.new()
var ReDashTimer := Timer.new()
var AttackTimer := Timer.new()
var ReAttackTimer := Timer.new()
var can_dash := true

var press_opposite := false
var dash_echo := false

var door_position := 0.0

var can_attack := true
var swording := false
var attack_echo := false
var sword_dir := "l"

var knockback := Vector2(0,0)
var walk := false

func _ready():
	add_child(DashTimer)
	DashTimer.wait_time = 0.2
	DashTimer.one_shot = true
	DashTimer.connect("timeout", self, "dash_ended")
	add_child(ReDashTimer)
	ReDashTimer.wait_time = 0.08
	ReDashTimer.one_shot = true
	ReDashTimer.connect("timeout", self, "dash_again")
	add_child(AttackTimer)
	AttackTimer.wait_time = 0.2
	AttackTimer.one_shot = true
	AttackTimer.connect("timeout", self, "attack_ended")
	add_child(ReAttackTimer)
	ReAttackTimer.wait_time = 0.08
	ReAttackTimer.one_shot = true
	ReAttackTimer.connect("timeout", self, "attack_again")

func _process(delta):
	# Create the inputs
	match Persistent.player_cutscene:
		"no":
			move_up = Input.is_key_pressed(KEY_UP)
			move_down = Input.is_key_pressed(KEY_DOWN)
			move_left = Input.is_key_pressed(KEY_LEFT)
			move_right = Input.is_key_pressed(KEY_RIGHT)
			jump_press = Input.is_key_pressed(KEY_Z)
			for i in Persistent.notch_fillers.size():
				match Persistent.notch_fillers[i]:
					"dash":
						dash_press = Input.is_key_pressed(Persistent.notch_keys[i])
			attack_press = Input.is_key_pressed(KEY_X)
		"door":
			move_up = false
			move_down = false
			jump_press = false
			dash_press = false
			attack_press = false
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
		"nomove":
			move_up = false
			move_down = false
			jump_press = false
			dash_press = false
			attack_press = false
			move_right = false
			move_left = false
		"train":
			play("close_train")
		"leave_l", "enter_l":
			move_up = false
			move_down = false
			jump_press = false
			dash_press = false
			attack_press = false
			move_right = false
			move_left = true
		"leave_r", "enter_r":
			move_up = false
			move_down = false
			jump_press = false
			dash_press = false
			attack_press = false
			move_right = true
			move_left = false


func _physics_process(delta):
	DashParticle.visible = current_state == STATES.DASH
	if current_state != STATES.DASH:
		DashParticle.animation = "default"
	
	Hitbox.monitoring = swording
	Hitbox.monitorable = swording
	match sword_dir:
		"r":
			Hitbox.rotation = 0
			$AnimatedSprite.rotation = 0
			$AnimatedSprite.scale.x = 1
		"l":
			Hitbox.rotation = -PI
			$AnimatedSprite.rotation = 0
			$AnimatedSprite.scale.x = -1
		"u":
			Hitbox.rotation = -PI/2
			$AnimatedSprite.scale.x = 1
			$AnimatedSprite.rotation = -PI/2
		"d":
			Hitbox.rotation = PI/2
			$AnimatedSprite.scale.x = 1
			$AnimatedSprite.rotation = PI/2
	
	match current_state:
		STATES.GROUND:
			if move_left and not move_right:
				if walk:
					speed.x = move_toward(speed.x, -MAX_WALK, WALK_ACCEL * delta*60)
				else:
					speed.x = move_toward(speed.x, -MAX_WALK_RUN, WALK_ACCEL * delta*60)
			elif move_right and not move_left:
				if walk:
					speed.x = move_toward(speed.x, MAX_WALK, WALK_ACCEL * delta*60)
				else:
					speed.x = move_toward(speed.x, MAX_WALK_RUN, WALK_ACCEL * delta*60)
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
			if not swording:
				if abs(speed.x) > 0 and abs(speed.x) < 110:
					play("walk" + direction)
				elif abs(speed.x) >= 110:
					play("run" + direction)
				else:
					play("idle" + direction)
			else:
				play("attack" + direction)
			
			if dash_press and can_dash and not dash_echo:
				current_state = STATES.DASH
				DashTimer.start()
			
			if attack_press and can_attack and not attack_echo:
				swording = true
				can_attack = false
				AttackTimer.start()
				$AnimatedSprite.frame = 0
				
			if move_up:
				sword_dir = "u"
			elif move_left:
				sword_dir = "l"
			elif move_right:
				sword_dir = "r"
			else:
				sword_dir = direction.replace("_", "")
		STATES.AIR:
			if move_left and not move_right:
				if walk:
					speed.x = move_toward(speed.x, -MAX_AIRSPEED, WALK_ACCEL * 1.1 * delta*60)
				else:
					speed.x = move_toward(speed.x, -MAX_AIRSPEED_RUN, WALK_ACCEL * 1.1 * delta*60)
			elif move_right and not move_left:
				if walk:
					speed.x = move_toward(speed.x, MAX_AIRSPEED, WALK_ACCEL * 1.1 * delta*60)
				else:
					speed.x = move_toward(speed.x, MAX_AIRSPEED_RUN, WALK_ACCEL * 1.1 * delta*60)
			else:
				speed.x = move_toward(speed.x, 0.0, WALK_ACCEL * 0.8 * delta*60)
			
			if is_on_floor():
				current_state = STATES.GROUND
			
			if speed.y < 0:
				play("jump" + direction)
			else:
				play("fall" + direction)
			
			speed.y += gravity * delta*60
			
			if dash_press and can_dash and not dash_echo:
				current_state = STATES.DASH
				DashTimer.start()
				
			if attack_press and can_attack and not attack_echo:
				swording = true
				can_attack = false
				AttackTimer.start()
				$AnimatedSprite.frame = 0
				
			if move_up:
				sword_dir = "u"
			elif move_down:
				sword_dir = "d"
			elif move_left:
				sword_dir = "l"
			elif move_right:
				sword_dir = "r"
			else:
				sword_dir = direction.replace("_", "")
		
		STATES.DASH:
			can_dash = false
			if direction == "_l":
				if move_right or press_opposite:
					speed.x = move_toward(speed.x, MAX_WALK*3.0, 10)
					speed.y = move_toward(speed.y, 0, 20)
					press_opposite = true
					play("spin_l")
					attack_play(1)
				else:
					speed.x = move_toward(speed.x, -MAX_WALK*8.0, 30)
					speed.y = move_toward(speed.y, 0, 20)
					play("dash_l")
					attack_play(0)
			else:
				if move_left or press_opposite:
					speed.x = move_toward(speed.x, -MAX_WALK*3.0, 10)
					speed.y = move_toward(speed.y, 0, 20)
					press_opposite = true
					play("spin_r")
					attack_play(1)
				else:
					speed.x = move_toward(speed.x, MAX_WALK*8.0, 30)
					speed.y = move_toward(speed.y, 0, 20)
					play("dash_r")
					attack_play(0)
				
	
	if speed.length() > MAX_SPEED:
		speed = speed.normalized()*MAX_SPEED
	speed = move_and_slide_with_snap(speed, Vector2.DOWN, Vector2.UP, true)
	move_and_slide_with_snap(knockback, Vector2.DOWN, Vector2.UP, true)
	knockback *= 0.5
	
	dash_echo = dash_press
	attack_echo = attack_press

func attack_ended():
	swording = false
	ReAttackTimer.start()

func attack_again():
	can_attack = true

func dash_ended():
	if Animations.animation.find("spin") == -1:
		current_state = STATES.AIR
		press_opposite = false
		ReDashTimer.start()

func dash_again():
	can_dash = true


func play(anim:String):
	if Animations.animation != anim or not Animations.playing:
		if not(Animations.animation == "enter_door" and Persistent.player_cutscene == "door") and not(Animations.animation == "close_train" and Persistent.player_cutscene == "train"):
			Animations.play(anim)

func attack_play(anim:int):
	if direction == "_l":
		DashParticle.scale.x = -1
	else:
		DashParticle.scale.x = 1
	if anim == 0:
		if DashParticle.animation != "default":
			DashParticle.play("default")
	elif anim == 1:
		if direction == "_l":
			if DashParticle.animation != "spin_l":
				DashParticle.play("spin_l")
		elif DashParticle.animation != "spin":
			DashParticle.play("spin")


func _on_animation_finished():
	if Animations.animation.find("spin") != -1:
		current_state = STATES.AIR
		press_opposite = false
		ReDashTimer.start()
	if Animations.animation == "enter_door":
		emit_signal("door_entered")


func enter_door(x):
	Persistent.player_cutscene = "door"
	door_position = x


func _on_body_attacked(body):
	print("a")
	if not body.is_in_group("grass"):
		knockback.x = (position-body.position).normalized().x*200
		speed.y = (position-body.position).normalized().y*250
	if body.is_in_group("attackable"): 
		body.call("attacked", 1, position, speed)

func attacked(d, p, s):
	speed = (position-p).normalized()*200 + s*0.5
#	health -= d
