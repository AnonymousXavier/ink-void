extends Node
class_name ImpactSystem

func update(_delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
	
	var player_transform = entity_manager.transform_components.get(player_id)
	var player_parry = entity_manager.parry_components.get(player_id)
	var player_health = entity_manager.health_components.get(player_id)
	
	if not player_transform or not player_parry or not player_health: return
	
	for bullet_id in entity_manager.is_a_bullet.keys():
		var bullet_transform = entity_manager.transform_components.get(bullet_id)
		var alignment = entity_manager.alignment_components.get(bullet_id)
		var bullet_meele = entity_manager.meele_components.get(bullet_id)
	
		if not bullet_transform or not alignment or not bullet_meele: continue
		
		# BULLET TARGETS PLAYER
		if alignment.alignment == Enums.ALIGNMENTS.PLAYER:
			# Dash Invincibility
			var dash = entity_manager.dash_components.get(player_id)
			if dash and dash.is_dashing:
				continue 
			
			# Isnt Dashing
			if player_transform.position.distance_to(bullet_transform.position) <= Constants.PARRY_RADIUS:
				
				if player_parry.current_state == ParryData.State.PARRYING:
					SceneInstances.time_scale = 0.1 
					player_parry.current_state = ParryData.State.FROZEN_AIMING
					player_parry.hijacked_bullet_id = bullet_id
					
					bullet_transform.position = player_transform.position
					var bullet_velocity_data = entity_manager.velocity_components.get(bullet_id)
					if bullet_velocity_data:
						bullet_velocity_data.speed = 0.0
					
					break 
					
				elif player_parry.current_state != ParryData.State.FROZEN_AIMING:
					SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.DAMAGE_ATTEMPT, "id": player_id, "amount": bullet_meele.damage})
					print("PLAYER HIT! HP: ", player_health.health)
					Factories.despawn_bullet(bullet_id)
					break
					
		# BULLET TARGETS ENEMIES 
		elif alignment.alignment == Enums.ALIGNMENTS.ENEMY:
			var bullet_hit_enemy = false
			
			for enemy_id in entity_manager.is_an_enemy.keys():
				var enemy_transform = entity_manager.transform_components.get(enemy_id)
				var enemy_health = entity_manager.health_components.get(enemy_id)
				
				if not enemy_transform or not enemy_health: continue
				
				if bullet_transform.position.distance_to(enemy_transform.position) <= Constants.PARRY_RADIUS * 1.5:
					SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.DAMAGE_ATTEMPT, "id": enemy_id, "amount": bullet_meele.damage})
					print("ENEMY HIT! HP: ", enemy_health.health)
					
					Factories.despawn_bullet(bullet_id)
					bullet_hit_enemy = true
					break 
			
			if bullet_hit_enemy:
				continue
