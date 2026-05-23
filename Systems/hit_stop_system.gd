extends Node
class_name HitStopSystem

var hit_stop_end_time: int = 0
var is_stopped: bool = false

func update() -> void:
	# 1. THE WAKE-UP SEQUENCE
	if is_stopped:
		# Use raw real-world unscaled time so this timer doesn't freeze when the game freezes!
		if Time.get_ticks_msec() >= hit_stop_end_time:
			SceneInstances.time_scale = 1.0 # Snap the custom engine clock back to normal!
			Engine.time_scale = 1.0 # Catch-all just in case
			is_stopped = false
		return # Stop executing so we don't trigger a freeze while already frozen

	# 2. THE EVENT CATCHER
	for event in SceneInstances.events_manager.events:
		
		# A. The Heavy Kill Freeze (Complete Stop)
		if event["type"] == Enums.EVENT_TYPES.ENTITY_KILLED:
			SceneInstances.time_scale = 0.0 
			hit_stop_end_time = Time.get_ticks_msec() + 45 # 45ms hitstop
			is_stopped = true
			return 
			
		# B. The Parry Deflect Glitch (Slow-mo Stop)
		elif event["type"] == Enums.EVENT_TYPES.HIT_STOP:
			# Expects duration in seconds (e.g. 0.15) and converts to ms
			var duration_ms = int(event.get("duration", 0.15) * 1000) 
			hit_stop_end_time = Time.get_ticks_msec() + duration_ms
			is_stopped = true
			return
