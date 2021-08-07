extends Area2D

enum DIRS {
	LEFT,
	RIGHT,
	UP,
	DOWN
}

export var newScene:String # Where this changer will take the player
export(DIRS) var enter_dir = DIRS.LEFT # The direction this player should move when they enter it
onready var Player := $"../Neptune" # The player
export var identifier := 0

var scene # Stores the PackedScene that is loaded in _ready()
var can_enter := true # The player can't enter this if hey come from it



func _ready():
	
	# Load the scene that the player will go to if they enter
	scene = load("res://Areas/" + newScene + ".tscn")
	
	# If the scene they'd go to from here happens to be the one they
	# come from, they can't enter this until they've gone out of it
	# (this is detected with a signal)
	if newScene == Persistent.entered_from and Persistent.ident == identifier:
		can_enter = false
		Player.position = position
		
		# The HUD distinguishes between entering and leaving
		match enter_dir:
			DIRS.LEFT:
				Persistent.player_cutscene = "enter_r"
			DIRS.RIGHT:
				Persistent.player_cutscene = "enter_l"
			DIRS.DOWN:
				Player.position.y -= 50
				Player.position.x -= 50
				can_enter = true
				Persistent.player_cutscene = "no"
				Player.last_safe_pos = Player.position
				Persistent.ident = identifier


func _on_body_entered(body):
	# If the player enters the changer
	if body.name == "Neptune" and can_enter:
		Persistent.entered_from = get_tree().current_scene.filename.replace("res://Areas/", "").replace(".tscn", "")
		print(Persistent.entered_from)
		# Set the scene the player will go to and start the change 
		Persistent.next_scene = scene
		Persistent.SChangeTimer.start()
		
		# Make the player move towards the changer
		match enter_dir:
			DIRS.LEFT:
				Persistent.player_cutscene = "leave_l"
			DIRS.RIGHT:
				Persistent.player_cutscene = "leave_r"
			DIRS.UP:
				Persistent.player_cutscene = "leave_v"
				Player.speed.y = -200
			DIRS.DOWN:
				Persistent.player_cutscene = "leave_v"


func _on_body_exited(body):
	# If the player exits the changer, they can enter it again and the
	# cutscene stops
	if body.name == "Neptune":
		can_enter = true
		Persistent.player_cutscene = "no"
		body.last_safe_pos = body.position
		Persistent.ident = identifier
