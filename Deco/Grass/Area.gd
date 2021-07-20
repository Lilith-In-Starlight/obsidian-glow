extends StaticBody2D

func attacked(d, p, s):
	get_parent().queue_free()
