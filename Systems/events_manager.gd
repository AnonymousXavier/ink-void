extends Node
class_name EventsManager

var events: Array = []

func update(delta: float) -> void:
	call_deferred("clear_events_queue")
	
func add_event(event: Dictionary):
	events.append(event)
	
func clear_events_queue():
	events = []
