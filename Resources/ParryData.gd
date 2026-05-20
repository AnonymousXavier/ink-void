extends Resource
class_name ParryData

enum State { READY, PARRYING, RECOVERING, FROZEN_AIMING }

var current_state: State = State.READY
var timer: float = 0.0
var hijacked_bullet_id: int = -1 # Caches the intercepted bullet
var parry_pierce_bonus: int = 0 # How many enemies a parried bullet will rip through

var parry_damage_bonus: int = 0
var parry_speed_multiplier: float = 1.0
