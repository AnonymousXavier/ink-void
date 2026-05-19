extends Node
class_name GameOverSystem

var is_dead: bool = false
var cinematic_timer: float = 3.0 # 3 real-world seconds of slow-mo

func update(delta: float) -> void:
	# 1. THE TRIGGER (Event-Driven!)
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
		# Because time_scale is 0.05, 'delta' is tiny. 
		# We must divide by time_scale to count in real-world seconds!
		var real_time_delta = delta / max(SceneInstances.time_scale, 0.01)
		cinematic_timer -= real_time_delta
		
		if cinematic_timer <= 0.0:
			# The sequence is over. Boot them to the Meta-Shop.
			# Reset time so the main menu isn't permanently frozen!
			SceneInstances.time_scale = 1.0 
			get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
