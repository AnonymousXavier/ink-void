extends Node
class_name ParrySystem

func update(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
	
	var parry: ParryData = entity_manager.parry_components.get(player_id)
	var input: PlayerInputData = entity_manager.player_input_data
	var player_transform = entity_manager.transform_components.get(player_id)
	var player_velocity = entity_manager.velocity_components.get(player_id)
	
	if not parry or not input: return
	
	# Handle Active Window & Miss Cooldown Timers (Using raw unscaled delta)
	if parry.current_state == ParryData.State.PARRYING or parry.current_state == ParryData.State.RECOVERING:
		parry.timer -= delta
		
		if parry.timer <= 0:
			if parry.current_state == ParryData.State.PARRYING:
				# Window closed without catching a projectile! Trigger Recovery Penalty
				parry.current_state = ParryData.State.RECOVERING
				parry.timer = Constants.PARRY_MISSED_PENALTY_TIME
			elif parry.current_state == ParryData.State.RECOVERING:
				# Recovery finished, tool is primed again
				parry.current_state = ParryData.State.READY
				
	# Handle Initiation Trigger (Spacebar pressed while READY)
	if parry.current_state == ParryData.State.READY and input.parry_pressed:
		parry.current_state = ParryData.State.PARRYING
		parry.timer = Constants.PARRY_WAIT_TIME

	# Handle Frozen Aiming Release (Spacebar pressed while holding a captured bullet)
	elif parry.current_state == ParryData.State.FROZEN_AIMING and input.parry_pressed:
		var bullet_id = parry.hijacked_bullet_id
		
		# Verify bullet still exists in active tracker registries
		if entity_manager.is_a_bullet.has(bullet_id):
			var bullet_transform = entity_manager.transform_components.get(bullet_id)
			var bullet_velocity = entity_manager.velocity_components.get(bullet_id)
			var bullet_meele = entity_manager.meele_components.get(bullet_id)
			var bullet_alignment = entity_manager.alignment_components.get(bullet_id)
			
			if bullet_transform and bullet_velocity and bullet_meele and bullet_alignment:
				# Calculate aim vector based on where the player is currently pointing
				var aim_direction = input.aim_direction.normalized()
				if aim_direction == Vector2.ZERO:
					aim_direction = Vector2.UP # Fallback direction vector

				# Parrying a 2-damage Tank bullet yields 4 player projectile damage!
				bullet_meele.damage = bullet_meele.damage * 2.0 
				bullet_meele.hit_targets.clear() # Reset target filter history array
				bullet_meele.pierce_count = 1 if bullet_meele.mass >= 4.0 else 0 # Tanks pierce through 1 extra enemy
				
				# Re-align faction arrays to explicitly target enemies
				bullet_alignment.alignment = Enums.ALIGNMENTS.ENEMY
				
				# Update bullet positioning vectors and snap speed to extreme velocities
				bullet_transform.position = player_transform.position
				bullet_velocity.direction = aim_direction
				bullet_velocity.speed = 1200.0 # Blazing fast projectile bounce speed
				
				# THE KINETIC RECOIL KICKBACK
				# Push the 1-HP player backwards in the opposite direction of their aim vector
				if player_velocity:
					var recoil_force = bullet_meele.mass * 250.0
					# Inject raw pushback vector directly into player velocity components
					player_velocity.knockback_vector = -aim_direction * recoil_force

				# Clean visual juice registration
				SceneInstances.events_manager.add_event({
					"type": Enums.EVENT_TYPES.SCREEN_SHAKE, 
					"intensity": 0.3 * bullet_meele.mass
				})
		
		# 4. Snap engine physics back to full simulation scale and trigger window reset
		SceneInstances.time_scale = 1.0
		parry.hijacked_bullet_id = -1
		parry.current_state = ParryData.State.RECOVERING
		parry.timer = 0.15 # Tiny recovery window after a successful blast release
