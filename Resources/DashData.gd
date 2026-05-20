extends RefCounted
class_name DashData

var start_position: Vector2 = Vector2.ZERO

var is_dashing: bool = false
var dash_duration: float = 0.15 
var dash_time_left: float = 0.0

var cooldown: float = 3.0
var cooldown_time_left: float = 0.0

var dash_speed: float = 1800.0
var dash_direction: Vector2 = Vector2.ZERO

# --- FRICTION WAKE ---
var friction_wake_radius: float = 0.0 # Starts at 0. Upgrades will increase this!
var friction_wake_slow_percent: float = 0.0
