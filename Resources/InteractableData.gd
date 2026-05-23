extends Resource
class_name InteractableData

var interaction_radius: float = 100.0
var event_to_fire: int 
var is_player_in_range: bool = false

var base_color: Color
var hover_color: Color

# Add this to label the terminal!
var terminal_name: String = ""
