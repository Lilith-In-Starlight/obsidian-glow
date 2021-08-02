extends Node2D


func _on_body_entered(body):
	if body.has_method("env_hurt"):
		body.call("env_hurt")
