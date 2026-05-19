extends Node
class_name GameOverSystem

var is_dead: bool = false
var cinematic_timer: float = 3.0 # 3 real-world seconds of slow-mo
var game_ended: bool = false

func update(delta: float) -> void:
	if game_ended: return # Stop executing once the sequence is over!
	
	if not is_dead:
		for event in SceneInstances.events_manager.events:
			if event.type == Enums.EVENT_TYPES.GAME_OVER:
				is_dead = true
				
				# Snap into extreme slow-motion
				SceneInstances.time_scale = 0.05 
				
				# Massive screen shake for impact
				SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SCREEN_SHAKE, "amount": 1.5})
				
				# Request Extraction to the SaveSystem!
				SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SAVE_REQUESTED})
				break 
				
	# 2. THE CINEMATIC HOLD
	if is_dead:
		cinematic_timer -= delta
		
		if cinematic_timer <= 0.0:
			# The sequence is over. Boot them to the Meta-Shop.
			# Reset time so the main menu isn't permanently frozen
			SceneInstances.time_scale = 1.0 
			SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SHOW_DEATH_SCREEN})
			
			game_ended = true
