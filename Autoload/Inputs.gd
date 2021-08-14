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

func custom_scancode_str(code:Array):
	if code[0] == -1:
		return ""
	else:
		match code[1]:
			METHODS.KEYBOARD:
				return OS.get_scancode_string(code[0])
			METHODS.CONTROLLER:
				return Input.get_joy_button_string(code[0])

func process_input(event):
	if event is InputEventKey:
		if up_key[1] == METHODS.KEYBOARD and event.scancode == up_key[0]:
			return "up"
		elif down_key[1] == METHODS.KEYBOARD and event.scancode == down_key[0]:
			return "down"
		elif left_key[1] == METHODS.KEYBOARD and event.scancode == left_key[0]:
			return "left"
		elif right_key[1] == METHODS.KEYBOARD and event.scancode == right_key[0]:
			return "right"
		elif jump_key[1] == METHODS.KEYBOARD and event.scancode == jump_key[0]:
			return "jump"
		elif attack_key[1] == METHODS.KEYBOARD and event.scancode == attack_key[0]:
			return "right"
		elif cancel_key[1] == METHODS.KEYBOARD and event.scancode == cancel_key[0]:
			return "cancel"
		elif event.scancode == KEY_ESCAPE:
			return "escape"
	elif event is InputEventMouseButton:
		if up_key[1] == METHODS.MOUSE and event.button_index == up_key[0]:
			return "up"
		elif down_key[1] == METHODS.MOUSE and event.button_index == down_key[0]:
			return "down"
		elif left_key[1] == METHODS.MOUSE and event.button_index == left_key[0]:
			return "left"
		elif right_key[1] == METHODS.MOUSE and event.button_index == right_key[0]:
			return "right"
		elif jump_key[1] == METHODS.MOUSE and event.button_index == jump_key[0]:
			return "jump"
		elif attack_key[1] == METHODS.MOUSE and event.button_index == attack_key[0]:
			return "right"
		elif cancel_key[1] == METHODS.MOUSE and event.button_index == cancel_key[0]:
			return "cancel"
	elif event is InputEventMIDI:
		if up_key[1] == METHODS.MIDI and event.message == up_key[0]:
			return "up"
		elif down_key[1] == METHODS.MIDI and event.message == down_key[0]:
			return "down"
		elif left_key[1] == METHODS.MIDI and event.message == left_key[0]:
			return "left"
		elif right_key[1] == METHODS.MIDI and event.message == right_key[0]:
			return "right"
		elif jump_key[1] == METHODS.MIDI and event.message == jump_key[0]:
			return "jump"
		elif attack_key[1] == METHODS.MIDI and event.message == attack_key[0]:
			return "right"
		elif cancel_key[1] == METHODS.MIDI and event.message == cancel_key[0]:
			return "cancel"
	
	elif event is InputEventJoypadMotion:
		match event.axis:
			JOY_AXIS_1, JOY_AXIS_3, JOY_ANALOG_LY, JOY_ANALOG_RY:
				if event.axis_value > 0.1:
					return "down"
				if event.axis_value < 0.1:
					return "up"
			JOY_AXIS_0, JOY_AXIS_2, JOY_ANALOG_LX, JOY_ANALOG_RX:
				if event.axis_value > 0.1:
					return "right"
				if event.axis_value < 0.1:
					return "left"
	
	return "null"
	
