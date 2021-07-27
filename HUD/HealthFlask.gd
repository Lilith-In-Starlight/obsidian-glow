extends TextureRect


var frame := 0

func _ready():
	material = material.duplicate()
	frame = randi() % 10

func _on_timeout():
	frame = (frame+1)%20
	get_material().set_shader_param("frame", float(frame))
