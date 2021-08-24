extends Sprite

var Player

func _ready():
	Player = get_tree().get_nodes_in_group("player")[0]

func _process(delta):
	for i in get_children():
		var comp = Player.position-i.global_position
		print(comp)
		if comp.x < -10:
			if comp.y > -10 and comp.y < 10:
				$AnimatedSprite.animation = "left"
			elif comp.y < -10:
				$AnimatedSprite.animation = "up_left"
			elif comp.y > 10:
				$AnimatedSprite.animation = "down_left"
		elif comp.x > 10:
			if comp.y > -10 and comp.y < 10:
				$AnimatedSprite.animation = "right"
			elif comp.y < -10:
				$AnimatedSprite.animation = "up_right"
			elif comp.y > 10:
				$AnimatedSprite.animation = "down_right"
		else:
			if comp.y > -10 and comp.y < 10:
				if comp.x > 0:
					$AnimatedSprite.animation = "mid_right"
				else:
					$AnimatedSprite.animation = "mid_left"
			elif comp.y < -10:
				if comp.x > 0:
					$AnimatedSprite.animation = "up_mid_right"
				else:
					$AnimatedSprite.animation = "up_mid_left"
			elif comp.y > 10:
				if comp.x > 0:
					$AnimatedSprite.animation = "down_mid_right"
				else:
					$AnimatedSprite.animation = "down_mid_left"
