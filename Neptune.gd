extends KinematicBody2D

signal door_entered
signal health_change(change)


enum STATES {
	GROUND,
	AIR,
	DASH,
	SLASH,
}

const MAX_SPEED := 800.0 # Max speed in every direction
const MAX_WALK := 80.0 # Max walkable speed by normal means
const MAX_AIRSPEED := 160.0 # Max speed in air by normal means
const MAX_WALK_RUN := 130.0 # Max runnable speed by normal means
const MAX_AIRSPEED_RUN := 150.0 # Max runnable speed in air by normal means
const WALK_ACCEL := 20.0 # Accelleration
const JUMP_FORCE := -270.0

onready var Animations := $Animations # The player sprite
onready var DashParticle := $DashParticle # particles for when the player dashes
onready var Hitbox := $Hitbox # The player's hitbox
onready var Cam := $Camera2D

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
var slash_press := false

# State machine
var current_state = STATES.GROUND

# Direction for the sppites
var direction := "_r"

var DashTimer := Timer.new() # How long the dash lasts
var ReDashTimer := Timer.new() #  How long until the dash is back
var AttackTimer := Timer.new() # Same two as above but for attack
var ReAttackTimer := Timer.new()
var NoMoveTimer := Timer.new() # Takes away control for a short time
var can_dash := true 
var air_dashes := 1
var current_air_dash := 0

var press_opposite := false # If the player is on air, have they pressed a key opposite to their direction?
var dash_echo := false # Are they holding the dash key?

var door_position := 0.0 # For door cutscenes, where should the player walk?

var can_attack := true 
var swording := false # Is the player currently attacking
var attack_echo := false # Is the player holding attack key
var sword_dir := "l" # What direction  is the player attacking in?

var knockback := Vector2(0,0) # Knockback speed when attacked
var walk := false # Is the player being forced to walk?

var last_safe_pos := Vector2(0, 0)

var HUD

# Camera shake variables
var shake := 0.0
var trauma := 0.0
var noise := OpenSimplexNoise.new()
var time := 0.0

# i-frames
var invulnerable := false
var IvulnerableTimer := Timer.new()

var using_shadow := 0.0 # The amount of shadow that has been used for healing

var unpressed_jump_on_air = false # Controls the length of jumps

var smoothing_reset := false # To make sure the camera isn't weird

var will_slash := false # Whether the player will slash or not
var slash_goal := Vector2(0, 0)
var slash_timer := 0.0

func _ready():
	HUD = get_tree().get_nodes_in_group("hud")[0]
	# If the player spawns with no health, reset it
	if Persistent.health <= 0:
		Persistent.health = 6
	# Set the current environment to the custom environment
	Persistent.WEnv.environment = Persistent.Env
	# If its the first time loading the game
	if Persistent.first_load:
		# If the player position in the save file has not been set,
		# set it to the current player position
		if Persistent.player_pos == Vector2(0, 0):
			Persistent.player_pos = position
		# If the scene that the player saved in is the currently loaded one,
		# set the player's position to the saved one
		elif Persistent.loaded_scene == get_tree().current_scene.filename:
			position = Persistent.player_pos
		# If its being loaded because the player died, save the information
		# and make sure the next load isn't treated the same way
		if Persistent.death_load:
			Persistent.save()
			Persistent.death_load = false
			if Persistent.got_diary and not Persistent.recently_collected.empty():
				Persistent.diary.append_array(Persistent.recently_collected)
				print(Persistent.recently_collected, " ", Persistent.diary)
				Persistent.recently_collected = []
				HUD.call("diary_updated")
	
	# The player will respawn in the place it entered the scene from
	# in the case of receiving environmental damage
	last_safe_pos = position
	# Make sure the next scene load isn't treated as the first time
	# loading the game
	Persistent.first_load = false
	# Set up the timers
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
	add_child(IvulnerableTimer)
	IvulnerableTimer.wait_time =  0.2
	IvulnerableTimer.one_shot = true
	IvulnerableTimer.connect("timeout", self, "vulnerable_again")
	add_child(NoMoveTimer)
	NoMoveTimer.wait_time = 0.3
	NoMoveTimer.one_shot = true
	NoMoveTimer.connect("timeout", self, "move_again")
	
	# Make the player camera be able to rotate
	Cam.rotating = true

func _process(delta):
	if not smoothing_reset:
		Cam.reset_smoothing()
		smoothing_reset = true
	# Make sure the player never has more than the maximum health
	if Persistent.health > Persistent.max_health:
		Persistent.health = Persistent.max_health
	
	# Shake function
	trauma = lerp(trauma, shake, 0.8)
	shake = move_toward(shake, 0.0, 0.02)
	Cam.rotation = noise.get_noise_1d(time * 10) * trauma * 0.1
	Cam.offset = Vector2(noise.get_noise_1d(time * 10 + 100) * trauma, noise.get_noise_1d(time * 10 - 100) * trauma) * 5.0
	time += delta*60 * 5
	
	# Some events make time slower or faster, make time always end up
	# at normal speed
	Engine.time_scale = move_toward(Engine.time_scale, 1.0, 0.025)
	
	
	# Create the inputs
	match Persistent.player_cutscene:
		"no": # No cutscene
			move_up = Input.is_key_pressed(Inputs.up_key)
			move_down = Input.is_key_pressed(Inputs.down_key)
			move_left = Input.is_key_pressed(Inputs.left_key)
			move_right = Input.is_key_pressed(Inputs.right_key)
			jump_press = Input.is_key_pressed(Inputs.jump_key)
			attack_press = Input.is_key_pressed(Inputs.attack_key)
			
			# Abilities
			for i in Persistent.notch_fillers.size():
				match Persistent.notch_fillers[i]:
					"dash":
						dash_press = Input.is_key_pressed(Persistent.notch_keys[i])
					"slash":
						slash_press = Input.is_key_pressed(Persistent.notch_keys[i])
			
		"door": # When the player enters a door
			move_up = false
			move_down = false
			jump_press = false
			dash_press = false
			attack_press = false
			# When the player is close to the door it's entering
			# make it play an animation
			# If its not, make it walk to it
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
		"nomove", "nomovetemp": # The player should be frozen
			move_up = false
			move_down = false
			jump_press = false
			dash_press = false
			attack_press = false
			move_right = false
			move_left = false
			if current_state == STATES.DASH:
				current_state = STATES.AIR
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
	
	# Controls the raycast for the slash attack
	var attackables := get_tree().get_nodes_in_group("attackable")
	if Persistent.notch_fillers.has("slash") and not attackables.empty():
		$SlashCast.enabled = true
		var closest
		for i in attackables:
			if (closest == null or i.position.distance_to(position) < closest.position.distance_to(position)) and i.position.distance_to(position) < 250:
				closest = i
				slash_goal = i.position
		if closest != null:
			$SlashCast.cast_to = closest.position - position
	else:
		$SlashCast.enabled = false
	
	# Controls the particles that appear during the healing animation
	$HealParticles.emitting = using_shadow >= 0.08 and Persistent.shadow + using_shadow >= 4.0
	# They only appear if the player is healing, and if the amount of shadow they have in total is enough to heal
	
	# Most of the player's functions can only happen if they have health
	if Persistent.health > 0:
		# If they have health, these death animation particles must not play
		$DeathParticles.emitting = false
		
		# The dashing particles are only visible if the player is dashing
		DashParticle.visible = current_state == STATES.DASH
		
		# If they're not, the dash particle must go to its default state
		if current_state != STATES.DASH:
			DashParticle.animation = "default"
		
		# The hitbox only matters if the player is attacking
		Hitbox.monitoring = swording or current_state == STATES.SLASH
		Hitbox.monitorable = swording or current_state == STATES.SLASH
		$Hitbox2.monitoring = current_state == STATES.SLASH
		$Hitbox2.monitorable = current_state == STATES.SLASH
		
		# Controls the attack sprite direction
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
		
		match current_state: # State machine
			STATES.GROUND:
				unpressed_jump_on_air = false # Makes it so that the player
				# can still control their jump lenght
				current_air_dash = 0 # They're on the ground, the air dashes
				# are reset
				
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
					speed.y = 60
					# This makes it so that if the player suddenly walks off
					# The ground, the falling feels natural
					# It's sixty because this way slopes are  handled better
					
				# Jump
				if jump_press:
					Persistent.jump_tutorial = true
					speed.y = JUMP_FORCE
					current_state = STATES.AIR
				
				# Directions for the sprites
				if speed.x > 0:
					direction = "_r"
					using_shadow = 0
				elif speed.x < 0:
					direction = "_l"
					using_shadow = 0
				else:
					# The player can only heal if they're not moving, have enough 
					# shadow to use, and their health is less than the maximum
					if move_down and Persistent.shadow - 0.08 >= 0.0 and Persistent.health < Persistent.max_health:
						# The shadow they have is reduced and the shadow
						# they are using increases
						using_shadow += 0.08
						Persistent.shadow -= 0.08
						# If they have used more than 4.0 shadow, the shadow
						# they're using resets and they heal one flask
						if using_shadow > 4.0:
							using_shadow = 0.08
							Persistent.health += 1
							Persistent.heal_tutorial = true
					else:
						Persistent.shadow += using_shadow
						using_shadow = 0
				
				# Ground Animations
				if using_shadow == 0 or using_shadow + Persistent.shadow < 4.0:
					if not swording:
						# If the player isn't attacking, choose the animation
						# based on their speed
						if abs(speed.x) > 0 and abs(speed.x) < 110:
							play("walk" + direction)
						elif abs(speed.x) >= 110:
							play("run" + direction)
						else:
							play("idle" + direction)
					else:
						# If they're attacking
						play("attack" + direction)
				else:
					# If they're healing
					play("heal" + direction)
				
				# Dashing
				if dash_press and can_dash and not dash_echo and current_air_dash < air_dashes:
					current_state = STATES.DASH
					current_air_dash += 1
					speed.y *= 0.001
					DashTimer.start()
				
				# Sword dirs can only be changed if the player isn't currently
				# attacking
				if not swording:
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
				
				# Attacking
				if attack_press and can_attack and not attack_echo:
					Persistent.attack_tutorial = true
					swording = true
					can_attack = false
					AttackTimer.start()
					$AnimatedSprite.frame = 0
				
				if slash_press:
					slash_timer += delta
					Engine.time_scale = 0.5
					if slash_timer >= 0.5:
						will_slash = true
				elif will_slash and $SlashCast.is_colliding():
					if $SlashCast.get_collider().is_in_group("attackable"):
						current_state = STATES.SLASH
					will_slash = false
					slash_timer = 0.0
				else:
					will_slash = false
					slash_timer = 0.0
				
			
			STATES.AIR:
				# The player can't be using their shadow if they're in the
				# air
				using_shadow = 0
				# Horizontal movement
				if move_left and not move_right:
					direction = "_l"
					if walk:
						speed.x = move_toward(speed.x, -MAX_AIRSPEED, WALK_ACCEL * 1.1 * delta*60)
					else:
						speed.x = move_toward(speed.x, -MAX_AIRSPEED_RUN, WALK_ACCEL * 1.1 * delta*60)
				elif move_right and not move_left:
					direction = "_r"
					if walk:
						speed.x = move_toward(speed.x, MAX_AIRSPEED, WALK_ACCEL * 1.1 * delta*60)
					else:
						speed.x = move_toward(speed.x, MAX_AIRSPEED_RUN, WALK_ACCEL * 1.1 * delta*60)
				else:
					speed.x = move_toward(speed.x, 0.0, WALK_ACCEL * 0.8 * delta*60)
				
				# Change to ground state
				if is_on_floor() and speed.y > -60:
					current_state = STATES.GROUND
				
				# Animations
				if speed.y < 0:
					play("jump" + direction)
				else:
					play("fall" + direction)
				
				# Falling
				speed.y = move_toward(speed.y, 500, gravity * delta*60)
				
				# Dash
				if dash_press and can_dash and not dash_echo and current_air_dash < air_dashes:
					current_air_dash += 1
					current_state = STATES.DASH
					DashTimer.start()
				
				# Sword dirs can only be changed if the player isn't attacking
				if not swording:
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
				
				# Attack
				if attack_press and can_attack and not attack_echo:
					Persistent.attack_tutorial = true
					swording = true
					can_attack = false
					AttackTimer.start()
					$AnimatedSprite.frame = 0
				
				# Controls the jump speed
				if not jump_press and speed.y < -20 and not unpressed_jump_on_air:
					unpressed_jump_on_air = true
					speed.y *= 0.6413
					# To make the jump feel natural, instead of increasing
					# the gravity, the player speed is reduced
				
				
				if slash_press:
					slash_timer += delta
					if slash_timer >= 0.5:
						Engine.time_scale = 0.5
						will_slash = true
				elif will_slash and $SlashCast.is_colliding():
					if $SlashCast.get_collider().is_in_group("attackable"):
						current_state = STATES.SLASH
					will_slash = false
					slash_timer = 0.0
				else:
					will_slash = false
					slash_timer = 0.0
			
			STATES.DASH:
				# If the player is dashing, they are not jumping, so
				# they can still control their jump length next time they jump
				unpressed_jump_on_air = false
				
				# Can't use shadow if they're dashing
				using_shadow = 0
				
				# If the player is dashing, they can't dash until dash is over
				can_dash = false
				
				# The player dashes to wherever they are looking, unless they
				# press a key opposite to where they're loking
				# in that case, they spin
				if direction == "_l":
					if move_right or press_opposite:
						speed.x = move_toward(speed.x, MAX_WALK*3.0, 10 * delta*60)
						speed.y = move_toward(speed.y, -20, 20 * delta*60)
						press_opposite = true
						play("spin_l")
						attack_play(1)
					else:
						speed.x = -MAX_WALK*5.0
						speed.y = move_toward(speed.y, 0, 200 * delta*60)
						play("dash_l")
						attack_play(0)
				else:
					if move_left or press_opposite:
						speed.x = move_toward(speed.x, -MAX_WALK*3.0, 10 * delta*60)
						speed.y = move_toward(speed.y, -20, 200 * delta*60)
						press_opposite = true
						play("spin_r")
						attack_play(1)
					else:
						speed.x = MAX_WALK*5.0
						speed.y = move_toward(speed.y, 0, 200 * delta*60)
						play("dash_r")
						attack_play(0)
			STATES.SLASH:
				if speed.x > 0:
					direction = "_r"
				elif speed.x < 0:
					direction = "_l"
				
				
				play("spin" + direction)
				
				speed = (slash_goal - position).normalized() * 800
				slash_timer += delta
				if position.distance_to(slash_goal) < 20 or slash_timer >= 0.3:
					current_state = STATES.AIR
					speed *= 0.5
					slash_timer = 0.0
		
		# Limit the speed
		if speed.length() > MAX_SPEED:
			speed = speed.normalized()*MAX_SPEED
		
		# Move the player according to speed and knockback. Must be done separately
		# because we don't want the actual speed to be influenced by
		# the knockback speed
		speed = move_and_slide_with_snap(speed, Vector2.DOWN, Vector2.UP, true)
		move_and_slide_with_snap(knockback, Vector2.DOWN, Vector2.UP, true)
		knockback *= 0.5 # Knockback speed is reduced by half every frame
	
	else:
		# The player ran out of health, so the next scene load is
		# after a death
		Persistent.death_load = true
		play("death") # Play the death animation
		Persistent.shadow -= 0.2 # Remove all the player's shadow
		
		# If the savefile doesn't have a scene saved, go to the beginning
		# of the game
		if Persistent.loaded_scene == "":
			Persistent.loaded_scene = "res://Areas/Field/Field.tscn"
		
		# Go to the last saved scene
		Persistent.entered_from = Persistent.loaded_scene.replace("res://Areas/", "").replace(".tscn", "")
		Persistent.next_scene = load(Persistent.loaded_scene)
	
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
		speed.x *= 0.5
		press_opposite = false
		ReDashTimer.start() # Takes some time to be able to dash again

# They can dash again
func dash_again():
	press_opposite = false
	can_dash = true

# A custom function to play animations in the player's sprite
func play(anim:String):
	if Animations.animation != anim or not Animations.playing:
		if not(Animations.animation == "enter_door" and Persistent.player_cutscene == "door") and not(Animations.animation == "close_train" and Persistent.player_cutscene == "train"):
			Animations.play(anim)

# A custom animation for the dash particles
func attack_play(anim:int):
	# Direction of the slash
	if direction == "_l":
		DashParticle.scale.x = -1
	else:
		DashParticle.scale.x = 1
	
	# What animation is being played
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
	# If the animation that just finished is a spin, the player gets
	# the dash back
	if Animations.animation.find("spin") != -1:
		current_state = STATES.AIR
		press_opposite = false
		ReDashTimer.start()
	
	if Animations.animation == "enter_door":
		emit_signal("door_entered")
	
	# If the death animation finished, the scene can change
	if Animations.animation == "death":
		$DeathParticles.emitting = false
		Persistent.SChangeTimer.start()
		# Next time a scene is loaded it must be treated as the first time
		Persistent.first_load = true
		Persistent.shadow = 0.0

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
		if not (Persistent.masks_wearing.has("survivor") and Persistent.health == 1) and current_state != STATES.SLASH:
			body.call("attacked", 1, position, speed)
		else:
			body.call("attacked", 2, position, speed*1.5)

func attacked(d, p, s):
	# When the player is attacked
	if not invulnerable and not current_state == STATES.SLASH:
		knockback = (position-p).normalized()*200 + s*0.5
		Persistent.health -= d
		emit_signal("health_change", -d)
		# Shake the camera and slow down time
		shake = 0.3 * d
		Engine.time_scale = 0.05
		# i-frames
		invulnerable = true
		IvulnerableTimer.start()
		# In case the player dies from this attack
		$DeathParticles.emitting = true

func env_hurt():
	# When the player receives environmental damage
	if not invulnerable:
		Persistent.health -= 1
		emit_signal("health_change", -1)
		# Take the player to the last safe position
		position = last_safe_pos
		# Shake camera
		shake = 0.3
		# Make sure the player can't move so they don't fall into spike pits again
		speed.x = 0
		Persistent.player_cutscene = "nomove"
		NoMoveTimer.start()
		# Reset dash
		ReDashTimer.start()
		# i-frames
		invulnerable = true
		IvulnerableTimer.start()
		# In case the player dies from this attack
		$DeathParticles.emitting = true


# End the i-frames
func vulnerable_again():
	invulnerable = false


# End the temporal non-movement
func move_again():
	Persistent.player_cutscene = "no"


func _on_area_entered(area):
	if area.is_in_group("sword_hurtbox"):
		print("a")
		knockback = (position-area.position).normalized()*200
		shake = 0.4
		Engine.time_scale = 0.04
