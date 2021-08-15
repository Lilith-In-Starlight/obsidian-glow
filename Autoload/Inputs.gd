extends Node

# This node handles the custom keys

enum METHODS {
	KEYBOARD,
	MOUSE,
	CONTROLLER,
	MIDI,
}

var up_key := [KEY_UP, METHODS.KEYBOARD]
var down_key := [KEY_DOWN, METHODS.KEYBOARD]
var left_key := [KEY_LEFT, METHODS.KEYBOARD]
var right_key := [KEY_RIGHT, METHODS.KEYBOARD]
var jump_key := [KEY_Z, METHODS.KEYBOARD]
var attack_key := [KEY_X, METHODS.KEYBOARD]
var cancel_key := [KEY_C, METHODS.KEYBOARD]

func _ready():
	set_actions()

func custom_scancode_str(code:Array):
	if code[0] == -1:
		return ""
	else:
		match code[1]:
			METHODS.KEYBOARD:
				return OS.get_scancode_string(code[0])
			METHODS.CONTROLLER:
				return Input.get_joy_button_string(code[0])

func set_actions():
	var event
	var input_dict := {
		"up" : up_key,
		"down" : down_key,
		"left" : left_key,
		"right" : right_key,
		"jump" : jump_key,
		"attack" : attack_key,
		"cancel" : cancel_key,
	}
	InputMap.load_from_globals()
	for i in input_dict.keys():
		var code = input_dict[i]
		print(i, " ", code)
		match code[1]:
			METHODS.KEYBOARD:
				event = InputEventKey.new()
				event.scancode = code[0]
				InputMap.action_add_event(i, event)
			METHODS.MOUSE:
				event = InputEventMouseButton.new()
				event.button_index = code[0]
				InputMap.action_add_event(i, event)
			METHODS.CONTROLLER:
				event = InputEventJoypadButton.new()
				event.button_index = code[0]
				InputMap.action_add_event(i, event)

func input_to_array(event):
	if event is InputEventKey:
		return [event.scancode, METHODS.KEYBOARD]
	elif event is InputEventMouseButton:
		return [event.button_index, METHODS.MOUSE]
	elif event is InputEventJoypadButton:
		return [event.button_index, METHODS.CONTROLLER]
