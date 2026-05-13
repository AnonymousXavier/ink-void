extends Node
class_name CountDownSystem

func update(delta: float) -> void:
	# Grab the scaled delta so timers freeze when the engine freezes!
	var scaled_delta = delta * SceneInstances.time_scale
	
	for timer_id in SceneInstances.entity_manager.countdown_components:
		var countdown_data: CountDownData = SceneInstances.entity_manager.countdown_components[timer_id]
		
		if countdown_data.started: # Isnt Idle
			countdown_data.time_left -= scaled_delta # <--- Applied here
			
			if countdown_data.time_left <= 0.0:
				countdown_data.started = false

static func start_countdown_for(countdowndata: CountDownData):
	countdowndata.started = true
	countdowndata.time_left = countdowndata.wait_time
