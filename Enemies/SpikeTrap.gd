extends Area2D


var Player
var is_in := false

func _ready():
	Player = get_tree().get_nodes_in_group("player")[0]



func _on_body_entered(body):
	if body == Player:
		$Timer.start()
		is_in = true


func _on_body_exited(body):
	if body == Player:
		is_in = false


func _on_timeout():
	$AnimatedSprite.play("default")
	$Timer2.start()


func _on_Timer2_timeout():
	$AnimatedSprite.play("default", true)


func _on_frame_changed():
	if is_in and $AnimatedSprite.frame > 2:
		is_in = false
		Player.attacked(1, position, Vector2(0, -200))
