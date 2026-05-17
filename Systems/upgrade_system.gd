extends Node
class_name UpgradeSystem

func update(_delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return

	for event in SceneInstances.events_manager.events:
		if event.type == Enums.EVENT_TYPES.UPGRADE_APPLIED:
			var upgrade_id = event["upgrade_id"]
			apply_upgrade(player_id, upgrade_id, entity_manager)

func apply_upgrade(player_id: int, upgrade_id: String, em: EntityManager) -> void:
	match upgrade_id:
		"hyper_dash":
			var dash = em.dash_components.get(player_id)
			if dash:
				dash.dash_speed += 600.0 # From 1800 to 2400
				dash.cooldown = max(1.0, dash.cooldown - 1.0) # Reduce cooldown by 1s
				
		"thick_blood":
			var health = em.health_components.get(player_id)
			if health:
				health.maxHealth += 1
				health.health = health.maxHealth # Heal to full
				
		"railgun_pierce":
			var parry = em.parry_components.get(player_id)
			if parry:
				parry.parry_pierce_bonus = 99 # Parried bullets now pierce everything
