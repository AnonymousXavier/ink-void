extends CanvasLayer

@onready var right_joystick: VirtualJoystick = $"Right Joystick"

var is_currently_glowing: bool = false
var current_tween: Tween

func _process(_delta: float) -> void:
	# Safety check to ensure the engine is fully loaded
	if not Cache.is_ready or SceneInstances.events_manager == null:
		return

	# Catch the hover event from the ECS
	for event in SceneInstances.events_manager.events:
		if event.type == Enums.EVENT_TYPES.TERMINAL_HOVER:
			var is_hovering = event.get("is_hovering", false)
			
			if is_hovering and not is_currently_glowing:
				_set_glow(true)
			elif not is_hovering and is_currently_glowing:
				_set_glow(false)

func _set_glow(active: bool) -> void:
	is_currently_glowing = active
	
	# Kill any existing tween so they don't fight if the player stutters on the boundary
	if current_tween and current_tween.is_valid():
		current_tween.kill()
		
	current_tween = create_tween()
	
	print("Animating Pad")
	
	# We use parallel() so the color and scale animate at the exact same time
	if active:
		# Swell up slightly and glow bright gold
		current_tween.parallel().tween_property(right_joystick, "modulate", Color(1.5, 1.2, 0.5, 1.0), 0.2)
		current_tween.parallel().tween_property(right_joystick, "scale", Vector2(1.1, 1.1), 0.2)
	else:
		# Return to the base state
		current_tween.parallel().tween_property(right_joystick, "modulate", Color.WHITE, 0.2)
		current_tween.parallel().tween_property(right_joystick, "scale", Vector2.ONE, 0.2)
