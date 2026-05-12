extends Node

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.MOUSE_CLICK, "position": event.position})
	if event is InputEventMouseMotion:
		SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.MOUSE_MOTION, "position": event.position})
