extends Node
class_name HitStopSystem

var hit_stop_end_time: int = 0
var is_stopped: bool = false
const HIT_STOP_DURATION_MS: int = 45 # The sweet spot for human perception

func update() -> void:
	# 1. THE WAKE-UP SEQUENCE
	if is_stopped:
		if Time.get_ticks_msec() >= hit_stop_end_time:
			Engine.time_scale = 1.0 # Snap physics back to normal!
			is_stopped = false
		return # Stop executing so we don't trigger a freeze while already frozen

	# 2. THE TRIGGER SEQUENCE
	for event in SceneInstances.events_manager.events:
		# You can later expand this to critical hits, explosions, etc.
		if event.type == Enums.EVENT_TYPES.ENTITY_KILLED:
			print("GAME PAUSED")
			Engine.time_scale = 0.0 # Hard freeze the engine
			hit_stop_end_time = Time.get_ticks_msec() + HIT_STOP_DURATION_MS
			is_stopped = true
			
			return # Exit early so 10 simultaneous deaths don't overlap the timer
