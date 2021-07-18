extends Sprite


onready var Player := $"../../Neptune"
var trans := Transform2D()
var noise := OpenSimplexNoise.new()
var time := 0
var a = 0
var yscale := 1.0

func _ready():
	if randf() > 0.5:
		z_index = -1
	yscale = scale.y
	print(yscale)

func _process(delta):
	time += delta * 80
	a = lerp(a, noise.get_noise_3d(position.x, position.y, time)*0.3 + 0.1 - ((Player.speed.x/100) / Player.position.distance_to(position)), 0.2)
	trans.y = Vector2(a, yscale)
	trans.origin = position
	transform = trans
	if Player.position.distance_to(position) < 20 and Player.current_state == Player.STATES.ATTACK:
		queue_free()
