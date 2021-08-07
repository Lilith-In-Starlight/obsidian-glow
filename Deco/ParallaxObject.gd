extends Node2D


export var offset := Vector2(0, 0)
export var depth := 0.0

var init_pos: Vector2
var Cam: Camera2D

func _ready():
	depth *= 10
	init_pos = position
	Cam = get_tree().get_nodes_in_group("player")[0].get_node("Camera2D")

func _process(delta):
	position = init_pos + (Cam.get_camera_position() - init_pos) * 1.0/depth
