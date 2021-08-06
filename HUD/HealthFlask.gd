extends TextureRect

var frame := 0


func _ready():
	material = material.duplicate()
	frame = randi() % 10

func _on_timeout():
	frame = (frame+1)%20
	get_material().set_shader_param("frame", float(frame))
	get_material().set_shader_param("angry", Persistent.health == 1 and Persistent.masks_wearing.has("survivor"))
