extends Area2D


var direction := Vector2(0,0)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	position += direction.normalized() * 110 * delta


func _on_body_entered(body):
	if body.name == "Neptune":
		body.call("attacked", 1, position, direction.normalized()*110)
	queue_free()

