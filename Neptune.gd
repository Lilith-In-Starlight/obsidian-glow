extends KinematicBody2D

signal door_entered

enum STATES {
	GROUND,
	AIR,
	DASH,
}

const MAX_SPEED := 900.0 # Max speed in every direction
const MAX_WALK := 80.0 # Max walkable speed by normal means
const MAX_AIRSPEED := 160.0 # Max speed in air by normal means
const MAX_WALK_RUN := 130.0 # Max runnable speed by normal means
const MAX_AIRSPEED_RUN := 150.0 # Max runnable speed in air by normal means
const WALK_ACCEL := 20.0 # Accelleration
const JUMP_FORCE := -250.0

onready var Animations := $Animations # The player sprite
onready var DashParticle := $DashParticle # particles for when the player dashes
onready var Hitbox := $Hitbox # The player's hitbox

var speed := Vector2(0, 0)

var gravity := 13.0

# Keys
var move_left := false
var move_right := false
var move_up := false
var move_down := false
var jump_press := false
var dash_press := false
var attack_press := false

# State machine
var current_state = STATES.GROUND

# Direction for the sppites
var direction := "_r"

var DashTimer := Timer.new() # How long the dash lasts
var ReDashTimer := Timer.new() #  How long until the dash is back
var AttackTimer := Timer.new() # Same two as above but for attack
var ReAttackTimer := Timer.new()
var can_dash := true 

var press_opposite := false # If the player is on air, have they pressed a key opposite to their direction?
var dash_echo := false # Are they holding the dash key?

var door_position := 0.0 # For door cutscenes, where should the player walk?

var can_attack := true 
var swording := false # Is the player currently attacking
var attack_echo := false # Is the player holding attack key
var sword_dir := "l" # What direction  is the player attacking in?

var knockback := Vector2(0,0) # Knockback speed when attacked
var walk := false # Is the player being forced to walk?

func _ready():
	if Persistent.first_load:
		if Persistent.player_pos == Vector2(0, 0):
			Persistent.player_pos = position
		elif Persistent.loaded_scene == get_tree().current_scene.filename:
			position = Persistent.player_pos
	Persistent.first_load = false
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
		"no": # No cutscene
			move_up = Input.is_key_pressed(KEY_UP)
			move_down = Input.is_key_pressed(KEY_DOWN)
			move_left = Input.is_key_pressed(KEY_LEFT)
			move_right = Input.is_key_pressed(KEY_RIGHT)
			jump_press = Input.is_key_pressed(KEY_Z)
			# Abilities
			for i in Persistent.notch_fillers.size():
				match Persistent.notch_fillers[i]:
					"dash":
						dash_press = Input.is_key_pressed(Persistent.notch_keys[i])
			attack_press = Input.is_key_pressed(KEY_X)
		"door": # When the player enters a door
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
		"nomove": # The player should be frozen
			move_up = false
			move_down = false
			jump_press = false
			dash_press = false
			attack_press = false
			move_right = false
			move_left = false
		"train": # The player entered a train
			play("close_train")
		"leave_l", "enter_l": # For when moving to/from a screen towards the left
			move_up = false
			move_down = false
			jump_press = false
			dash_press = false
			attack_press = false
			move_right = false
			move_left = true
		"leave_r", "enter_r": # For when moving to/from a screen towards the right
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
	
	# The hitbox only matters if the player is attacking
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
			# Controls the walking
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
			
			# If the player isn't on the ground, make the state change
			if not is_on_floor():
				current_state = STATES.AIR
			else:
				speed.y = 1
				# This makes it so that if the player suddenly walks off
				# The ground, the falling feels natural
				
			# Jump
			if jump_press:
				speed.y = JUMP_FORCE
				current_state = STATES.AIR
			
			# Directions for the sprites
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
			
			# Dashing
			if dash_press and can_dash and not dash_echo:
				current_state = STATES.DASH
				DashTimer.start()
			
			# Attacking
			if attack_press and can_attack and not attack_echo:
				swording = true
				can_attack = false
				AttackTimer.start()
				$AnimatedSprite.frame = 0
			
			# Sword dirs
			if move_up:
				sword_dir = "u"
			elif move_left:
				sword_dir = "l"
			elif move_right:
				sword_dir = "r"
			else:
				sword_dir = direction.replace("_", "")
				# If the player isn't pressing any direction key,
				# they should attack to where they are looking
		STATES.AIR:
			# Horizontal movement
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
			
			# Change to ground state
			if is_on_floor():
				current_state = STATES.GROUND
			
			# Animations
			if speed.y < 0:
				play("jump" + direction)
			else:
				play("fall" + direction)
			
			# Falling
			speed.y += gravity * delta*60
			
			# Dash
			if dash_press and can_dash and not dash_echo:
				current_state = STATES.DASH
				DashTimer.start()
			
			# Attack
			if attack_press and can_attack and not attack_echo:
				swording = true
				can_attack = false
				AttackTimer.start()
				$AnimatedSprite.frame = 0
			
			# Sword dirs
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
				# If the player isn't pressing any direction key,
				# they should attack to where they are looking
		
		STATES.DASH:
			# If the player is dashing, they can't dash until dash is over
			can_dash = false
			# The player dashes to wherever they are looking, unless they
			# press a key opposite to where they're loking
			# in that case, they spin
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
				
	# Limit the speed
	if speed.length() > MAX_SPEED:
		speed = speed.normalized()*MAX_SPEED
	
	# Move the player according to speed and knockback. Must be done separately
	# because we don't want the actual speed to be influenced by
	# the knockback speed
	speed = move_and_slide_with_snap(speed, Vector2.DOWN, Vector2.UP, true)
	move_and_slide_with_snap(knockback, Vector2.DOWN, Vector2.UP, true)
	knockback *= 0.5 # Knockback speed is reduced by half every frame
	
	# Used to check whether the player is holding these keys
	dash_echo = dash_press
	attack_echo = attack_press

# When the attack has ended
func attack_ended():
	swording = false
	ReAttackTimer.start() # Takes some time to be able to attack again

# Give them their attack back
func attack_again():
	can_attack = true

# Their dash ended
func dash_ended():
	if Animations.animation.find("spin") == -1:
		current_state = STATES.AIR
		press_opposite = false
		ReDashTimer.start() # Takes some time to be able to dash again

# They can dash again
# TODO: THEY CAN ONLY GET IT BACK IF THEY HAVE TOUCHED THE GROUND
func dash_again():
	can_dash = true

# A custom function to play animations in the player's sprite
func play(anim:String):
	if Animations.animation != anim or not Animations.playing:
		if not(Animations.animation == "enter_door" and Persistent.player_cutscene == "door") and not(Animations.animation == "close_train" and Persistent.player_cutscene == "train"):
			Animations.play(anim)

# A custom animation for the dash particles
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

# When the player's animations are finished
func _on_animation_finished():
	if Animations.animation.find("spin") != -1:
		current_state = STATES.AIR
		press_opposite = false
		ReDashTimer.start()
	if Animations.animation == "enter_door":
		emit_signal("door_entered")

# When the player is commanded to enter a door
func enter_door(x):
	Persistent.player_cutscene = "door"
	door_position = x

# When the player attacks something
func _on_body_attacked(body):
	if not body.is_in_group("grass"):
		knockback.x = (position-body.position).normalized().x*200
		speed.y = (position-body.position).normalized().y*250
	if body.is_in_group("attackable"): 
		body.call("attacked", 1, position, speed)

# When the player is attacked
func attacked(d, p, s):
	speed = (position-p).normalized()*200 + s*0.5
#	health -= d
