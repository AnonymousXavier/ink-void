extends Node
class_name ReviveSystem

# The cost doubles every time you use it in a single run (50 -> 100 -> 200)
var current_revive_cost: int = 50

func update() -> void:
	for event in SceneInstances.events_manager.events:
		if event["type"] == Enums.EVENT_TYPES.PENDING_REVIVE:
			trigger_revive_sequence()
			
		elif event["type"] == Enums.EVENT_TYPES.REVIVE_CONFIRMED:
			execute_revive()
			
		elif event["type"] == Enums.EVENT_TYPES.REVIVE_REJECTED:
			# The player chose to die, or couldn't afford it. Fire the true end.
			SceneInstances.events_manager.add_event({
				"type": Enums.EVENT_TYPES.GAME_OVER, 
				"id": SceneInstances.entity_manager.player_id
			})

func trigger_revive_sequence():
	var bank = SceneInstances.entity_manager.bank_data
	
	# 1. Hard freeze the custom game loop
	SceneInstances.time_scale = 0.0
	
	# 2. Check if they have enough Keys (Souls)
	var can_afford = bank.souls >= current_revive_cost
	
	# 3. Tell the UI Manager to slide the Tribute overlay onto the screen
	SceneInstances.events_manager.add_event({
		"type": Enums.EVENT_TYPES.SHOW_REVIVE_UI,
		"cost": current_revive_cost,
		"can_afford": can_afford
	})

func execute_revive():
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	var bank = entity_manager.bank_data
	
	# 1. Deduct the souls and scale the cost for next time
	bank.souls -= current_revive_cost
	current_revive_cost *= 2 
	
	# 2. Heal the player back to baseline
	var health = entity_manager.health_components.get(player_id)
	if health:
		health.health = health.maxHealth
		
	# 3. BREATHING ROOM: Trigger your existing shockwave system!
	# This clears all bullets around the player so they don't instantly die the frame they wake up.
	if SceneInstances.wave_system:
		SceneInstances.wave_system.trigger_shockwave()
		
	# 4. Wake the engine back up
	SceneInstances.time_scale = 1.0
