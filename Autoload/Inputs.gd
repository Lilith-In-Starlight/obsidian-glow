extends Node


var up_key := KEY_UP
var down_key := KEY_DOWN
var left_key := KEY_LEFT
var right_key := KEY_RIGHT
var jump_key := KEY_Z
var attack_key := KEY_X
var cancel_key := KEY_C

func custom_scancode_str(code:int):
	if code == -1:
		return ""
	return OS.get_scancode_string(code)
