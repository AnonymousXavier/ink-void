extends Resource
class_name ParryData

enum State { READY, PARRYING, RECOVERING, FROZEN_AIMING }

@export var current_state: State = State.READY
@export var timer: float = 0.0
@export var hijacked_bullet_id: int = -1 # Caches the intercepted bullet
@export var parry_pierce_bonus: int = 0 # How many enemies a parried bullet will rip through

@export var parry_damage_bonus: int = 0
@export var parry_speed_multiplier: float = 1.0
