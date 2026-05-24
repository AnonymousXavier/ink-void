extends Node
class_name DeathSystem

var enemies_to_delete: Array = []

func update() -> void:
	for event in SceneInstances.events_manager.events:
		if event.type == Enums.EVENT_TYPES.ENTITY_KILLED:
			var id = event["id"]
			enemies_to_delete.append(id)
			
			var entity_manager = SceneInstances.entity_manager
			
			# ==========================================
			# 1. EXTRACT SOULS (ECONOMY)
			# ==========================================
			if id in entity_manager.is_an_enemy:
				var gold_data = entity_manager.gold_value_components.get(id)
				var transform_data = entity_manager.transform_components.get(id)
				
				if gold_data and transform_data:
					# Instantly update the logical bank
					SceneInstances.entity_manager.bank_data.souls += gold_data.gold 
					
					# Tell the UI to spawn the flying particle!
					SceneInstances.events_manager.add_event({
						"type": Enums.EVENT_TYPES.SOUL_COLLECTED,
						"amount": gold_data.gold,
						"world_pos": transform_data.position
					})
					
			# ==========================================
			# 2. SPAWN BLOOD SPLATTER
			# ==========================================
			# Fetch the position and render data BEFORE it gets deleted
			var transform_data = entity_manager.transform_components.get(id)
			var render_data = entity_manager.render_components.get(id)
			
			if transform_data and SceneInstances.splatter_canvas:
				# If for some reason they lack a color, default to brutalist gray
				var splatter_color = render_data.modulate if render_data else Color(0.5, 0.5, 0.5) 
				
				# Pass the color into our newly upgraded stamp function!
				SceneInstances.splatter_canvas.stamp(transform_data.position, splatter_color)
				
	# Run the cleanup sequence immediately after checking all events for this frame
	if enemies_to_delete.size() > 0:
		delete_entities()
			
func delete_entities():
	for id in enemies_to_delete:
		delete_entity(id)
		
	enemies_to_delete.clear()
			
func delete_entity(id: int):
	var entity_manager = SceneInstances.entity_manager
	var transform_data: TransformData = entity_manager.transform_components.get(id)
	if not transform_data:
		return
		
	var chunk_id = Vector2i(transform_data.position / Vector2(Constants.CHUNK_SIZE, Constants.CHUNK_SIZE))
	
	# Remove from chunk list
	if entity_manager.cluster_hash.has(chunk_id):
		entity_manager.cluster_hash[chunk_id].erase(id)
		
	entity_manager.active_entities.erase(id)
	
	# Remove from all possible components
	entity_manager.transform_components.erase(id)
	entity_manager.meele_components.erase(id)
	entity_manager.projectile_weopon_components.erase(id)
	entity_manager.countdown_components.erase(id)
	entity_manager.render_components.erase(id)
	entity_manager.velocity_components.erase(id)
	entity_manager.health_components.erase(id)
	entity_manager.gold_value_components.erase(id)
	entity_manager.homing_components.erase(id)
	entity_manager.grid_footprint_components.erase(id)
	entity_manager.alignment_components.erase(id)
	
	entity_manager.is_an_enemy.erase(id)
	entity_manager.is_a_bullet.erase(id)
