extends Node
class_name ParrySystem

func update(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
	
	var parry: ParryData = entity_manager.parry_components.get(player_id)
	var input: PlayerInputData = entity_manager.player_input_data
	
	if not parry or not input: return
	
	# RELOAD 
	if parry.current_charges < parry.max_charges:
		parry.recharge_timer -= delta
		if parry.recharge_timer <= 0:
			parry.current_charges += 1
			
			# If we are still missing charges, immediately start the next reload!
			if parry.current_charges < parry.max_charges:
				parry.recharge_timer = parry.recharge_time
			else:
				parry.recharge_timer = 0.0

	# 2. STATE MACHINE (Active Slash & Spam Delay)
	if parry.current_state == ParryData.State.PARRYING or parry.current_state == ParryData.State.RECOVERING:
		parry.timer -= delta
		
		if parry.timer <= 0:
			if parry.current_state == ParryData.State.PARRYING:
				parry.current_state = ParryData.State.RECOVERING
				# This is the "Spam Delay". Setting this to 0.1s means you can fire rapidly, 
				# but you can't accidentally burn all 3 charges in a single frame.
				parry.timer = 0.15 
			elif parry.current_state == ParryData.State.RECOVERING:
				parry.current_state = ParryData.State.READY
				
	# 3. INPUT TRIGGER (Consumes Ammo)
	if parry.current_state == ParryData.State.READY and input.parry_pressed and parry.current_charges > 0:
		SceneInstances.audio_system.play_sound("slash")
		# If we were full, starting a drain means we need to start the background timer
		if parry.current_charges == parry.max_charges:
			parry.recharge_timer = parry.recharge_time
			
		parry.current_charges -= 1 # Consume a charge!
		
		parry.current_state = ParryData.State.PARRYING
		parry.timer = Constants.PARRY_WAIT_TIME
