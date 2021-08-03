extends Panel


export var save_name := ""
var empty := true

func _ready():
	var Save := ConfigFile.new()
	var err := Save.load(save_name)
	if err == OK:
		empty = false
	
	
