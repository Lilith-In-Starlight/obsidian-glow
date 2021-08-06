extends TextureRect


export var mask_hud := "none"

func _process(delta):
	if Persistent.masks.has(mask_hud):
		texture = Persistent.mask_textures[mask_hud]
	else:
		texture = Persistent.mask_textures["none"]
