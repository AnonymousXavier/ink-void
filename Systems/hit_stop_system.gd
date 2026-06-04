extends Node
class_name HitStopSystem

var hit_stop_end_time: int = 0
var is_stopped: bool = false

func update() -> void:
	if is_stopped:
		# Use raw real-world unscaled time so this timer doesn't freeze
		if Time.get_ticks_msec() >= hit_stop_end_time:
			is_stopped = false
			_resolve_time_conflict() # <--- CHRONO-CLASH FIX
		return 

	# THE EVENT CATCHER
	for event in SceneInstances.events_manager.events:
		
		# Complete Stop (Kills)
		if event["type"] == Enums.EVENT_TYPES.ENTITY_KILLED:
			SceneInstances.time_scale = 0.0 
			hit_stop_end_time = Time.get_ticks_msec() + 45 
			is_stopped = true
			return 
			
		# The Parry Deflect
		elif event["type"] == Enums.EVENT_TYPES.HIT_STOP:
			var duration_ms = int(event.get("duration", 0.15) * 1000) 
			hit_stop_end_time = Time.get_ticks_msec() + duration_ms
			is_stopped = true
			return

# Evaluates the ECS state to determine what the time scale SHOULD be
func _resolve_time_conflict() -> void:
	var em = SceneInstances.entity_manager
	var player_id = em.player_id
	
	if player_id != -1 and em.dash_components.has(player_id):
		var dash = em.dash_components.get(player_id)
		# If they were dashing, return the time scale to Quicksilver speed
		if dash.is_dashing:
			SceneInstances.time_scale = 0.1 
			return
			
	# If no priority states are active, return to normal
	SceneInstances.time_scale = 1.0
