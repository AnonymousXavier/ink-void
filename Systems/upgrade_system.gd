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
	var wave_sys = SceneInstances.wave_system
	var live_deck = wave_sys.active_deck
	
	if not live_deck.has(upgrade_id): return # Safety check
	
	# Extract the data payload for this specific card
	var data = live_deck[upgrade_id]
	
	# 1. Apply the Data-Driven Math
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

	# 2. Level Up and Burn
	data["current_level"] += 1
	var current = data["current_level"]
	var maximum = data["max_level"]
	
	print("UPGRADE BOUGHT: ", upgrade_id, " (Level ", current, "/", maximum, ")")
	
	# The Clamp & Burn
	if current >= maximum:
		live_deck.erase(upgrade_id)
		print(upgrade_id, " HAS REACHED MAX LEVEL AND WAS BURNED FROM THE DECK!")
