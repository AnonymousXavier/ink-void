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
				
				# --- DIRECTIONAL PARRY MATH ---
				var input = entity_manager.player_input_data
				var aim_dir = input.aim_direction.normalized()
				if aim_dir == Vector2.ZERO: aim_dir = Vector2.UP
				
				var vector_to_bullet = (bullet_transform.position - player_transform.position).normalized()
				
				# Check if the bullet is within a 60-degree cone (±30 degrees from where you are aiming)
				# (Tweak this 30.0 number up or down to make the parry more/less forgiving!)
				var is_facing_bullet = abs(aim_dir.angle_to(vector_to_bullet)) <= deg_to_rad(30.0)
				
				# --- SUCCESSFUL SLASH PARRY ---
				if player_parry.current_state == ParryData.State.PARRYING and is_facing_bullet:
					
					# 1. Micro-Freeze Glitch (Hitstop)
					SceneInstances.time_scale = 0.05
					SceneInstances.events_manager.add_event({
						"type": Enums.EVENT_TYPES.HIT_STOP, 
						"duration": 0.15 
					})
					
					# 2. INSTANT DEFLECTION MATH (Auto-Aim to Nearest Enemy)
					var return_dir = Vector2.UP # Fallback
					var closest_dist = INF
					var all_enemies = entity_manager.is_an_enemy.keys()
					
					if all_enemies.size() > 0:
						for e_id in all_enemies:
							var e_transform = entity_manager.transform_components.get(e_id)
							if e_transform:
								var dist = player_transform.position.distance_squared_to(e_transform.position)
								if dist < closest_dist:
									closest_dist = dist
									return_dir = player_transform.position.direction_to(e_transform.position)
					else:
						# If no enemies are left alive, just bounce the bullet straight back
						return_dir = (bullet_transform.position - player_transform.position).normalized()
					
					var bullet_velocity_data = entity_manager.velocity_components.get(bullet_id)
					if bullet_velocity_data:
						bullet_velocity_data.direction = return_dir
						bullet_velocity_data.speed = 1500.0 # Blazing fast return
						
					bullet_meele.damage *= 2.0
					bullet_meele.hit_targets.clear()
					alignment.alignment = Enums.ALIGNMENTS.ENEMY # Flip factions!
					
					# 3. Visual Juice (White-hot Clash Spark)
					SceneInstances.events_manager.add_event({
						"type": Enums.EVENT_TYPES.SCREEN_SHAKE, 
						"intensity": 0.8
					})
					SceneInstances.events_manager.add_event({
						"type": Enums.EVENT_TYPES.SPAWN_IMPACT_PARTICLE,
						"pos": bullet_transform.position,
						"color": Color.WHITE # Clean white clash
					})
					
					continue # Flips multiple bullets safely
					
				# --- PLAYER TAKES A HIT (Not parrying, OR parrying the wrong way!) ---
				else:
					# The Shield Interception
					if player_shield and player_shield.is_active:
						player_shield.is_active = false
						SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SCREEN_SHAKE, "intensity": 0.8})
						SceneInstances.events_manager.add_event({
							"type": Enums.EVENT_TYPES.SPAWN_IMPACT_PARTICLE,
							"pos": Vector2(bullet_transform.position.x, bullet_transform.position.y),
							"color": Color(0.0, 1.0, 1.0)
						})
						Factories.despawn_bullet(bullet_id)
						break
						
					# Lethal Body Blow
					SceneInstances.events_manager.add_event({
						"type": Enums.EVENT_TYPES.SPAWN_IMPACT_PARTICLE,
						"pos": Vector2(bullet_transform.position.x, bullet_transform.position.y),
						"color": Color(1.0, 0.2, 0.2)
					})
					SceneInstances.events_manager.add_event({
						"type": Enums.EVENT_TYPES.DAMAGE_ATTEMPT, 
						"id": player_id, 
						"amount": bullet_meele.damage
					})
					Factories.despawn_bullet(bullet_id)
					break
					
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
