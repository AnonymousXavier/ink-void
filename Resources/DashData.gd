extends Resource
class_name DashData

@export var start_position: Vector2 = Vector2.ZERO

@export var is_dashing: bool = false
@export var dash_duration: float = 1.0
@export var dash_time_left: float = 0.0

@export var cooldown: float = 3.0
@export var cooldown_time_left: float = 0.0

@export var dash_speed: float = 1800.0
@export var dash_direction: Vector2 = Vector2.ZERO

# --- FRICTION WAKE ---
@export var friction_wake_radius: float = 0.0 # Starts at 0. Upgrades will increase this!
@export var friction_wake_slow_percent: float = 0.0
