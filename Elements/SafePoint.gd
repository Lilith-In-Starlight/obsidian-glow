extends Area2D


func _on_body_entered(body):
	if body.name == "Neptune":
		body.last_safe_pos = position
