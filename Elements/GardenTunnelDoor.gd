extends AnimatedSprite


func _ready():
	if Persistent.beat_the_gardeners:
		play("open")
		$KinematicBody2D/CollisionShape2D.disabled = true
