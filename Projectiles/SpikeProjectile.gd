extends KinematicBody2D

var collided = false

func _ready():
	match randi()%10:
		0, 1, 2, 3, 4, 5, 6:
			modulate = Color("#095100")
		7, 8:
			modulate = Color("#1d4400")
		9:
			modulate = Color("#bb7600")

func _process(delta):
	if not collided:
		var col := move_and_collide(-Vector2(cos(rotation), sin(rotation))*300*delta)
		if col:
			$Hurtbox.monitoring = false
			collided = true


func attacked(d, pos, s):
	queue_free()


func _on_body_entered(body):
	if body.name == "Neptune":
		body.call("attacked", 1, position, Vector2(cos(rotation), sin(rotation))*110)
	queue_free()

