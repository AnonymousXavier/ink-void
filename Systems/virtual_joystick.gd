extends Control
class_name VirtualJoystick

@export var action_left: String = "move_left"
@export var action_right: String = "move_right"
@export var action_up: String = "move_up"
@export var action_down: String = "move_down"

var touch_id: int = -1
var center: Vector2
var radius: float = 50.0 
var output_vector: Vector2 = Vector2.ZERO

@onready var base: TextureRect = $Base
@onready var stick: TextureRect = $Base/Stick

func _ready() -> void:
	# Calculate the dead center of the joystick base
	radius = base.size.x / 2.0
	center = base.global_position + (base.size / 2.0)
	stick.position = (base.size / 2.0) - (stick.size / 2.0)

# Add these two new variables at the top
var is_dragging: bool = false
var tap_start_pos: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_id == -1:
			var dist = event.position.distance_to(center)
			if dist < radius * 2.0: 
				touch_id = event.index 
				
				# TAP LOGIC: Record where the thumb started!
				tap_start_pos = event.position
				is_dragging = false
				
				_update_stick(event.position)
				
		elif not event.pressed and event.index == touch_id:
			# TAP LOGIC: If they lifted their thumb without dragging, it's a click!
			if not is_dragging:
				Input.action_press("parry")
				call_deferred("_release_tap_action") # Safely release it next frame
				
			_reset_stick()

	elif event is InputEventScreenDrag and event.index == touch_id:
		# TAP LOGIC: If they move their thumb more than 10 pixels, cancel the tap!
		if event.position.distance_to(tap_start_pos) > 10.0:
			is_dragging = true
			
		_update_stick(event.position)

# Add this small helper function at the bottom of the script
func _release_tap_action() -> void:
	Input.action_release("parry")

func _update_stick(pos: Vector2) -> void:
	var offset = pos - center
	
	# Clamp the stick so it can't be dragged outside the base circle
	if offset.length() > radius:
		offset = offset.normalized() * radius
	
	# Move the visual UI knob
	stick.position = (base.size / 2.0) + offset - (stick.size / 2.0)
	
	output_vector = offset / radius
	_fire_inputs()

func _reset_stick() -> void:
	touch_id = -1
	stick.position = (base.size / 2.0) - (stick.size / 2.0)
	output_vector = Vector2.ZERO
	_fire_inputs()

# This is the magic. It artificially presses the Input Map actions with analog weight!
func _fire_inputs() -> void:
	# X-Axis
	if output_vector.x < 0:
		Input.action_press(action_left, abs(output_vector.x))
		Input.action_release(action_right)
	elif output_vector.x > 0:
		Input.action_press(action_right, output_vector.x)
		Input.action_release(action_left)
	else:
		Input.action_release(action_left)
		Input.action_release(action_right)
		
	# Y-Axis
	if output_vector.y < 0:
		Input.action_press(action_up, abs(output_vector.y))
		Input.action_release(action_down)
	elif output_vector.y > 0:
		Input.action_press(action_down, output_vector.y)
		Input.action_release(action_up)
	else:
		Input.action_release(action_up)
		Input.action_release(action_down)
