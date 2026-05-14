extends Node
class_name ParrySystem

func update(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
	
	var parry: ParryData = entity_manager.parry_components.get(player_id)
	var input: PlayerInputData = entity_manager.player_input_data
	
	if not parry or not input: return
	
	# Handle Active Timers (Unscaled delta so parry recovers even if time is frozen)
	if parry.current_state == ParryData.State.PARRYING or parry.current_state == ParryData.State.RECOVERING:
		parry.timer -= delta
		
		if parry.timer <= 0:
			if parry.current_state == ParryData.State.PARRYING:
				# Missed the parry!
				parry.current_state = ParryData.State.RECOVERING
				parry.timer = 0.5 
			elif parry.current_state == ParryData.State.RECOVERING:
				# Recovery finished
				parry.current_state = ParryData.State.READY
				
	# Handle Initiation Trigger
	if parry.current_state == ParryData.State.READY and input.parry_pressed:
		parry.current_state = ParryData.State.PARRYING
		parry.timer = 1.0
