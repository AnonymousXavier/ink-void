extends Node

var enemies_to_delete: Array = []

func _ready() -> void:
	get_tree().process_frame.connect(delete_entities)

func update() -> void:
	for event in SceneInstances.events_manager.events:
		if event.type == Enums.EVENT_TYPES.ENTITY_KILLED:
			var id = event["id"]
			enemies_to_delete.append(id)
			
			# Fetch the position BEFORE it gets deleted
			var transform_data = SceneInstances.entity_manager.transform_components.get(id)
			if transform_data and SceneInstances.splatter_canvas:
				print("Stamt")
				SceneInstances.splatter_canvas.stamp(transform_data.position)
			
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
