extends Node
class_name ParrySystem

func update(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
	
	var parry: ParryData = entity_manager.parry_components.get(player_id)
	var input: PlayerInputData = entity_manager.player_input_data
	var p_transform: TransformData = entity_manager.transform_components.get(player_id)
	
	if not parry or not input or not p_transform: return
	
	# Handle Active Timers (Unscaled delta so parry recovers even if time is frozen)
	if parry.current_state == ParryData.State.PARRYING or parry.current_state == ParryData.State.RECOVERING:
		parry.timer -= delta
		
		if parry.timer <= 0:
			if parry.current_state == ParryData.State.PARRYING:
				# Missed the parry!
				parry.current_state = ParryData.State.RECOVERING
				parry.timer = Constants.PARRY_MISSED_PENALTY_TIME
			elif parry.current_state == ParryData.State.RECOVERING:
				# Recovery finished
				parry.current_state = ParryData.State.READY
				
	# Handle Initiation Trigger
	if parry.current_state == ParryData.State.READY and input.parry_pressed:
		parry.current_state = ParryData.State.PARRYING
		parry.timer = Constants.PARRY_WAIT_TIME

	# --- CONTINUOUS RADAR SWEEP (TARGETING MATRIX) ---
	var has_targeting_matrix = MetaEconomy.active_perks.has("targeting_matrix")
	
	# Only run the sweep if the perk is actually equipped
	if has_targeting_matrix:
		for entity_id in entity_manager.active_entities:
			# Check if this entity is an enemy bullet targeting the player
			var align = entity_manager.alignment_components.get(entity_id)
			if not align or align.alignment != Enums.ALIGNMENTS.PLAYER:
				continue
				
			var b_transform = entity_manager.transform_components.get(entity_id)
			var b_render = entity_manager.render_components.get(entity_id)
			
			if b_transform and b_render:
				var distance = p_transform.position.distance_to(b_transform.position)
				
				# Flip the visual flag if it crosses the threshold
				if distance <= Constants.PARRY_RADIUS:
					b_render.is_parry_highlighted = true
				else:
					b_render.is_parry_highlighted = false
