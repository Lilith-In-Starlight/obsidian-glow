extends Node2D

var closed = false

var phase := 3

func _ready():
	if Persistent.outskirts_arena:
		$Barriers/CollisionShape2D.position.y = -50
		$Barriers/CollisionShape2D2.position.y = -50

func _process(delta):
	if Persistent.outskirts_arena:
		$Barriers/CollisionShape2D.position.y = lerp($Barriers/CollisionShape2D.position.y, -80, 0.2)
		$Barriers/CollisionShape2D2.position.y = lerp($Barriers/CollisionShape2D2.position.y, -80, 0.2)
	elif $"../Neptune".position.x < 209:
		$Barriers/CollisionShape2D.position.y = lerp($Barriers/CollisionShape2D.position.y, 71, 0.2)
		$Barriers/CollisionShape2D2.position.y = lerp($Barriers/CollisionShape2D2.position.y, 71, 0.2)
		if !closed:
			closed = true
			var asdfa := preload("res://Enemies/DashAngel.tscn")
			var asdf := asdfa.instance()
			add_child(asdf)
			asdf.position = Vector2(0, 40)
			$"../Neptune".shake = 1.0
	elif $"../Neptune".position.x > 209:
		$Barriers/CollisionShape2D.position.y = lerp($Barriers/CollisionShape2D.position.y, 71, 0.2)
		$Barriers/CollisionShape2D2.position.y = lerp($Barriers/CollisionShape2D2.position.y, -80, 0.2)
	$Barriers/EnemyBarrier.position.y = $Barriers/CollisionShape2D.position.y - 2
	$Barriers/EnemyBarrier2.position.y = $Barriers/CollisionShape2D2.position.y + 10
	
	var health := 0
	for i in get_children():
		if i != $Barriers:
			if i.health > 0:
				health += i.health
	if health <= 0:
		Persistent.outskirts_arena = true
