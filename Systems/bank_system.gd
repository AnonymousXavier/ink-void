extends Node

func _process(_delta):
	for event in SceneInstances.events_manager.events:
		if event["type"] == Enums.EVENT_TYPES.ENTITY_KILLED:
			if SceneInstances.entity_manager.gold_value_components.has(event["id"]):
				var gold_value: GoldValueData = SceneInstances.entity_manager.gold_value_components[event["id"]]
				SceneInstances.entity_manager.bank_data.gold += gold_value.gold
				# 1. Look up the dead enemy's GoldValueData component
			# 2. Add that value to the Player's BankData component
