extends Node
class_name HealthSystem

func update() -> void:
	for event in SceneInstances.events_manager.events:
		if event["type"] == Enums.EVENT_TYPES.DAMAGE_CONFIRMED:
			if apply_damage(event["id"], event["amount"]) <= 0:
				SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.ENTITY_KILLED, "id": event["id"]})
			
func apply_damage(entity_id: int, amount: float):
	if not SceneInstances.entity_manager.health_components.has(entity_id):
		return 0 # Ignore the damage.
		
	var healthData: HealthData = SceneInstances.entity_manager.health_components[entity_id]
	healthData.health -= amount
	
	return healthData.health
	
	
