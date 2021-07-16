tool
extends Position2D


export var text = "TEXT"


func _process(delta):
	$Label.text = text
