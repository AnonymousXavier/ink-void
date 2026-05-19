extends Node
class_name UpgradeSystem

func update() -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return

	for event in SceneInstances.events_manager.events:
		if event.type == Enums.EVENT_TYPES.UPGRADE_APPLIED:
			var upgrade_id = event["upgrade_id"]
			apply_upgrade(player_id, upgrade_id, entity_manager)

func apply_upgrade(player_id: int, upgrade_id: String, em: EntityManager) -> void:
	var wave_sys = SceneInstances.wave_system
	var live_deck = wave_sys.active_deck
	
	if not live_deck.has(upgrade_id): return # Safety check
	
	# Extract the data payload for this specific card
	var data = live_deck[upgrade_id]
	
	match upgrade_id:
		"hyper_dash":
			var dash = em.dash_components.get(player_id)
			if dash:
				dash.dash_speed += data["speed_inc"] 
				dash.cooldown = max(1.0, dash.cooldown - data["cd_dec"]) 
				
		"thick_blood":
			var health = em.health_components.get(player_id)
			if health:
				health.maxHealth += data["hp_inc"]
				health.health = health.maxHealth 
				
		"railgun_pierce":
			var parry = em.parry_components.get(player_id)
			if parry:
				parry.parry_pierce_bonus += data["pierce_inc"]
				
		"friction_wake":
			var dash = em.dash_components.get(player_id)
			if dash:
				dash.friction_wake_radius += data["wake_radius_inc"]
				dash.friction_wake_slow_percent += data["slow_percent_inc"]
				
		"heavy_caliber":
			var parry = em.parry_components.get(player_id)
			if parry:
				parry.parry_damage_bonus += data["dmg_inc"]
				parry.parry_speed_multiplier *= data["speed_mult"]

	# Level Up
	data["current_level"] += 1
	var current = data["current_level"]
	var maximum = data["max_level"]
	
	print("UPGRADE BOUGHT: ", upgrade_id, " (Level ", current, "/", maximum, ")")

	if current >= maximum:
		live_deck.erase(upgrade_id)
		print(upgrade_id, " HAS REACHED MAX LEVEL AND WAS BURNED FROM THE DECK!")
