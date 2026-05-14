extends Node
class_name CameraShakeSystem

var trauma: float = 0.0
var max_offset: float = 40.0 # How violent the max screen kick is in pixels
var decay_rate: float = 3.0  # How fast the screen calms down

func update(delta: float) -> void:
	# 1. Listen for violence in the pipeline
	for event in SceneInstances.events_manager.events:
		if event.type == Enums.EVENT_TYPES.DAMAGE_ATTEMPT:
			add_trauma(0.2) # A tiny, tactile crunch when enemies get hit
		elif event.type == Enums.EVENT_TYPES.SCREEN_SHAKE:
			add_trauma(event.get("amount", 0.8)) # A massive kick for deliberate triggers!
			
	# 2. Process the physical kick
	if trauma > 0.0:
		# Squaring the trauma makes the initial hit punchy, and the tail end smooth
		var shake = trauma * trauma 
		var offset_x = max_offset * shake * randf_range(-1.0, 1.0)
		var offset_y = max_offset * shake * randf_range(-1.0, 1.0)
		
		SceneInstances.camera.offset = Vector2(offset_x, offset_y)
		
		# Decay the trauma
		trauma = max(trauma - decay_rate * delta, 0.0)
	else:
		SceneInstances.camera.offset = Vector2.ZERO

func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)
