extends Node

func _process(_delta: float) -> void:
	for event in SceneInstances.events_manager.events:
		if event["type"] == Enums.EVENT_TYPES.TARGET_REACHED:
			var id = event["id"]
			
			# Did a bullet arrive?
			if SceneInstances.entity_manager.is_a_bullet.has(id):
				var meele_data = SceneInstances.entity_manager.meele_components[id]
				var target_id = meele_data.target_id
				
				# Only mail the damage if the target still exists in the world
				if SceneInstances.entity_manager.transform_components.has(target_id):
					SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.DAMAGE_ATTEMPT, "id": target_id, "amount": meele_data.damage})

				# Always recycle the bullet, even if it hit thin air where a ghost used to be
				Factories.despawn_bullet(id)
			
			# Did an enemy arrive at the base?
			elif SceneInstances.entity_manager.is_an_enemy.has(id):
				# Trigger enemy base-attack logic
				pass
