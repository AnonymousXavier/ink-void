extends Node
class_name PlayerControllerSystem

func update(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1 or not entity_manager.active_entities.has(player_id):
		return
		
	var input: PlayerInputData = entity_manager.player_input_data
	var velocity = entity_manager.velocity_components.get(player_id)
	var parry = entity_manager.parry_components.get(player_id)
	var render = entity_manager.render_components.get(player_id)
	
	# 1. HANDLE TIMERS & STATE TRANSITIONS
	if parry.current_state != ParryData.State.READY:
		parry.timer -= delta
		
		if parry.timer <= 0:
			if parry.current_state == ParryData.State.PARRYING:
				parry.current_state = ParryData.State.RECOVERING
				parry.timer = 0.5
				render.texture.resource_local_to_scene = true 
				# render.modulate = Color.RED # Whiff indication
				
			elif parry.current_state == ParryData.State.RECOVERING:
				parry.current_state = ParryData.State.READY
	
	# 2. APPLY LOGIC BASED ON INPUT & STATE
	if parry.current_state == ParryData.State.READY:
		velocity.direction = input.direction
		# render.modulate = Color.WHITE
		
		if input.parry_pressed:
			parry.current_state = ParryData.State.PARRYING
			parry.timer = 0.2
			velocity.direction = input.direction * 0.5 
			# render.modulate = Color.CYAN 
			
	elif parry.current_state == ParryData.State.RECOVERING:
		# Lock movement during recovery
		velocity.direction = Vector2.ZERO
		
	# 3. HANDLE MOVEMENT
	var dx = 0
	var dy = 0
	if Input.get_action_strength("left"):
		dx = -1
	elif Input.get_action_strength("right"):
		dx = 1
	if Input.get_action_strength("down"):
		dy = 1
	elif Input.get_action_strength("up"):
		dy = -1
		
	velocity.direction = Vector2(dx, dy).normalized()
