extends Sprite

var Player
var goals := []
var goalpos := []
var time := 0
var change := true
var pit

var noise := OpenSimplexNoise.new()

func _ready():
	Player = get_tree().get_nodes_in_group("player")[0]
	pit = get_tree().get_nodes_in_group("pit")[0]

func _process(delta):
	time += 1
	var number := 0
	for i in get_children():
		if i is AnimatedSprite:
			if change:
				var posi := randf()
				if posi > 0.5:
					if goals.size() < get_child_count():
						goals.append(Player)
						goalpos.append(Player.position)
					else:
						goals[number] = Player
				else:
					if goals.size() < get_child_count():
						var ran = pit.get_children()[pit.get_child_count()-1]
						goals.append(ran)
						goalpos.append(ran.position)
					else:
						goals[number] = pit.get_children()[pit.get_child_count()-1]
			
			if not is_instance_valid(goals[number]):
				goals[number] = Player
			
			if ["Buttons", "Plants", "Platforms"].has(goals[number].name):
				goals[number] = Player
			
			goalpos[number].x = lerp(goalpos[number].x, goals[number].global_position.x, 0.05)
			goalpos[number].y = lerp(goalpos[number].y, goals[number].global_position.y, 0.05)
			var comp = goalpos[number]-i.global_position
			if comp.x < -10:
				if comp.y > -10 and comp.y < 10:
					i.animation = "left"
				elif comp.y < -10:
					i.animation = "up_left"
				elif comp.y > 10:
					i.animation = "down_left"
			elif comp.x > 10:
				if comp.y > -10 and comp.y < 10:
					i.animation = "right"
				elif comp.y < -10:
					i.animation = "up_right"
				elif comp.y > 10:
					i.animation = "down_right"
			else:
				if comp.y > -10 and comp.y < 10:
					if comp.x > 0:
						i.animation = "mid_right"
					else:
						i.animation = "mid_left"
				elif comp.y < -10:
					if comp.x > 0:
						i.animation = "up_mid_right"
					else:
						i.animation = "up_mid_left"
				elif comp.y > 10:
					if comp.x > 0:
						i.animation = "down_mid_right"
					else:
						i.animation = "down_mid_left"
		else:
			if pit.fight >= 11:
				if i.name != "feet":
					i.texture = preload("res://Sprites/Decoration/ThePit/greenbody_celebrate.png")
	
	if time % 120 == 0:
		change = true
	else:
		change = false
