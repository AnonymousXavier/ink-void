extends RefCounted
class_name InteractableData

var interaction_radius: float = 100.0
var event_to_fire: int # We will use Enums.EVENT_TYPES to tell the UI what to open!
var is_player_in_range: bool = false

var base_color: Color
var hover_color: Color
