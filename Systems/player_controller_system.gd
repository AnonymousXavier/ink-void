extends Node
class_name PlayerControllerSystem

func update(_delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
		
	var input = entity_manager.player_input_data
	var velocity = entity_manager.velocity_components.get(player_id)
	var parry = entity_manager.parry_components.get(player_id)
	var health = entity_manager.health_components.get(player_id)
	var dash = entity_manager.dash_components.get(player_id)
	
	if not input or not velocity or not parry: return
	
	# 1. THE DEATH OVERRIDE
	if health and health.health <= 0:
		velocity.direction = Vector2.ZERO 
		var render: RenderingData = entity_manager.render_components.get(player_id)
		if render:
			render.modulate = Color(0.2, 0.2, 0.2, 0.5) 
		return # Lock out all input
		
	# 2. THE PARRY STATE MACHINE
	if parry.current_state == ParryData.State.READY:
		# Standard movement (Allows Quicksilver Dashing to work!)
		if input.direction != Vector2.ZERO:
			velocity.direction = input.direction.normalized()
		else:
			velocity.direction = Vector2.ZERO
			
	elif parry.current_state == ParryData.State.PARRYING:
		# Slowed down slightly during the active slash frames
		velocity.direction = input.direction * 0.5 
		
	elif parry.current_state == ParryData.State.RECOVERING:
		# Locked movement during recovery frames
		velocity.direction = Vector2.ZERO
