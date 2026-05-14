extends Node

func update(_delta):
	for event in SceneInstances.events_manager.events:
		if event["type"] == Enums.EVENT_TYPES.ENTITY_KILLED:
			if SceneInstances.entity_manager.gold_value_components.has(event["id"]):
				continue
				var gold_value: GoldValueData = SceneInstances.entity_manager.gold_value_components[event["id"]]
				if gold_value:
					SceneInstances.entity_manager.bank_data.gold += gold_value.gold
