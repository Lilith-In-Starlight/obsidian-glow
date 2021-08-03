extends Node2D

onready var CollisionShapeLeft := $Barriers/CollisionShape2D
onready var CollisionShapeRight := $Barriers/CollisionShape2D2
onready var BarrierLeft := $Barriers/EnemyBarrier
onready var BarrierRight := $Barriers/EnemyBarrier2
onready var Barriers := $Barriers

var closed := false

var phase := 3

func _ready():
	if Persistent.outskirts_arena:
		CollisionShapeLeft.position.y = -50
		CollisionShapeRight.position.y = -50

func _process(delta):
	if Persistent.outskirts_arena:
		CollisionShapeLeft.position.y = lerp(CollisionShapeLeft.position.y, -80, 0.2)
		CollisionShapeRight.position.y = lerp(CollisionShapeRight.position.y, -80, 0.2)
	elif $"../Neptune".position.x < 209:
		CollisionShapeLeft.position.y = lerp(CollisionShapeLeft.position.y, 71, 0.2)
		CollisionShapeRight.position.y = lerp(CollisionShapeRight.position.y, 71, 0.2)
		if !closed:
			closed = true
			var dash_angel := preload("res://Enemies/DashAngel.tscn")
			var DashAngel := dash_angel.instance()
			add_child(DashAngel)
			DashAngel.position = Vector2(0, 40)
			$"../Neptune".shake = 1.0
	elif $"../Neptune".position.x > 209:
		CollisionShapeLeft.position.y = lerp(CollisionShapeLeft.position.y, 71, 0.2)
		CollisionShapeRight.position.y = lerp(CollisionShapeRight.position.y, -80, 0.2)
	BarrierLeft.position.y = CollisionShapeLeft.position.y - 2
	BarrierRight.position.y = CollisionShapeRight.position.y + 10
	
	var health := 0
	for i in get_children():
		if i != Barriers:
			if i.health > 0:
				health += i.health
	if health <= 0:
		Persistent.outskirts_arena = true
