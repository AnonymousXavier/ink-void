extends Node
class_name ImpactSystem

func update() -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
	
	var player_transform = entity_manager.transform_components.get(player_id)
	var player_parry = entity_manager.parry_components.get(player_id)
	var player_health = entity_manager.health_components.get(player_id)
	var player_shield = entity_manager.shield_components.get(player_id) 
	
	if not player_transform or not player_parry or not player_health: return
	
	for bullet_id in entity_manager.is_a_bullet.keys():
		var bullet_transform = entity_manager.transform_components.get(bullet_id)
		var alignment = entity_manager.alignment_components.get(bullet_id)
		var bullet_meele = entity_manager.meele_components.get(bullet_id)
	
		if not bullet_transform or not alignment or not bullet_meele: continue
		
		# ==========================================
		# BULLET TARGETS PLAYER
		# ==========================================
		if alignment.alignment == Enums.ALIGNMENTS.PLAYER:
			var dash = entity_manager.dash_components.get(player_id)
			if dash and dash.is_dashing: continue 
			
			var distance = player_transform.position.distance_to(bullet_transform.position)
			
			if distance <= Constants.PARRY_RADIUS:
				# --- SUCCESSFUL SLASH PARRY ---
				if player_parry.current_state == ParryData.State.PARRYING:
					
					# 1. Micro-Freeze Glitch (Hitstop)
					SceneInstances.time_scale = 0.05
					SceneInstances.events_manager.add_event({
						"type": Enums.EVENT_TYPES.HIT_STOP, 
						"duration": 0.15 
					})
					
					# 2. Instant Deflection Math
					var input = entity_manager.player_input_data
					var aim_dir = input.aim_direction.normalized()
					if aim_dir == Vector2.ZERO: aim_dir = Vector2.UP # Fallback
					
					var bullet_velocity_data = entity_manager.velocity_components.get(bullet_id)
					if bullet_velocity_data:
						bullet_velocity_data.direction = aim_dir
						bullet_velocity_data.speed = 1500.0 # Blazing fast return
						
					bullet_meele.damage *= 2.0
					bullet_meele.hit_targets.clear()
					alignment.alignment = Enums.ALIGNMENTS.ENEMY # Flip factions!
					
					# 3. Visual Juice
					SceneInstances.events_manager.add_event({
						"type": Enums.EVENT_TYPES.SCREEN_SHAKE, 
						"intensity": 0.8
					})
					SceneInstances.events_manager.add_event({
						"type": Enums.EVENT_TYPES.SPAWN_IMPACT_PARTICLE,
						"pos": bullet_transform.position,
						"color": Color(1.0, 0.8, 0.2) # Golden slash sparks!
					})
					
					# CRITICAL FIX: Use 'continue' so we can deflect multiple bullets in the same frame!
					continue 
					
				# --- PLAYER TAKES A HIT ---
				else:
					# The Shield Interception
					if player_shield and player_shield.is_active:
						player_shield.is_active = false
						SceneInstances.events_manager.add_event({
							"type": Enums.EVENT_TYPES.SCREEN_SHAKE, 
							"intensity": 0.8
						})
						SceneInstances.events_manager.add_event({
							"type": Enums.EVENT_TYPES.SPAWN_IMPACT_PARTICLE,
							"pos": Vector2(bullet_transform.position.x, bullet_transform.position.y),
							"color": Color(0.0, 1.0, 1.0) # Cyan shield sparks!
						})
						Factories.despawn_bullet(bullet_id)
						break
						
					# Lethal Body Blow
					SceneInstances.events_manager.add_event({
						"type": Enums.EVENT_TYPES.SPAWN_IMPACT_PARTICLE,
						"pos": Vector2(bullet_transform.position.x, bullet_transform.position.y),
						"color": Color(1.0, 0.2, 0.2) # Crimson blood sparks
					})
					SceneInstances.events_manager.add_event({
						"type": Enums.EVENT_TYPES.DAMAGE_ATTEMPT, 
						"id": player_id, 
						"amount": bullet_meele.damage
					})
					Factories.despawn_bullet(bullet_id)
					break # Only take one bullet's worth of damage per frame (Micro I-Frame)
					
		# ==========================================
		# BULLET TARGETS ENEMIES (Deflected or Player-Fired)
		# ==========================================
		elif alignment.alignment == Enums.ALIGNMENTS.ENEMY:
			var bullet_hit_enemy = false
			for enemy_id in entity_manager.is_an_enemy.keys():
				var enemy_transform = entity_manager.transform_components.get(enemy_id)
				var enemy_health = entity_manager.health_components.get(enemy_id)
				
				if not enemy_transform or not enemy_health: continue
				
				if bullet_transform.position.distance_to(enemy_transform.position) <= Constants.PARRY_RADIUS * 1.5:
					if enemy_id in bullet_meele.hit_targets: continue 
					
					bullet_meele.hit_targets.append(enemy_id)
					SceneInstances.events_manager.add_event({
						"type": Enums.EVENT_TYPES.DAMAGE_ATTEMPT, 
						"id": enemy_id, 
						"amount": bullet_meele.damage
					})
					SceneInstances.events_manager.add_event({
						"type": Enums.EVENT_TYPES.SPAWN_IMPACT_PARTICLE,
						"pos": Vector2(bullet_transform.position.x, bullet_transform.position.y),
						"color": Color(1.0, 0.2, 0.2) # Crimson blood sparks
					})
					
					if bullet_meele.pierce_count > 0:
						bullet_meele.pierce_count -= 1
					else:
						Factories.despawn_bullet(bullet_id)
						
					bullet_hit_enemy = true
					break
			if bullet_hit_enemy: continue
