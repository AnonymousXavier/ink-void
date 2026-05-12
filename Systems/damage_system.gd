extends Node
class_name DamageSystem

func update(_delta: float) -> void:
	var events_manager = SceneInstances.events_manager
	for event in events_manager.events:
		if event["type"] == Enums.EVENT_TYPES.DAMAGE_ATTEMPT:
			var damage_health_event = {"type": Enums.EVENT_TYPES.DAMAGE_CONFIRMED, "id": event["id"], "amount": event["amount"]}
			events_manager.add_event(damage_health_event)
