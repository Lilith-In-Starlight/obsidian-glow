extends Panel


export var save_name := ""

func _ready():
	var save := ConfigFile.new()
	save.load(save_name)
	
