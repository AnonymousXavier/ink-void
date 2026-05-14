extends Node
class_name FlashSystem

func update(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	
	# 1. Listen for the crunch!
	for event in SceneInstances.events_manager.events:
		if event.type == Enums.EVENT_TYPES.DAMAGE_ATTEMPT:
			var id = event["id"]
			
			# Inject the component if they don't have it, or reset it if they do
			if not entity_manager.flash_components.has(id):
				entity_manager.flash_components[id] = FlashData.new()
			else:
				entity_manager.flash_components[id].time_left = 0.05
				
	# 2. Process the decay
	var expired_flashes: Array = []
	for id in entity_manager.flash_components.keys():
		var flash = entity_manager.flash_components[id]
		
		# We ignore time_scale here so the flash is instant even if time is frozen!
		flash.time_left -= delta 
		if flash.time_left <= 0:
			expired_flashes.append(id)
			
	# 3. Scrub the dead data
	for id in expired_flashes:
		entity_manager.flash_components.erase(id)
