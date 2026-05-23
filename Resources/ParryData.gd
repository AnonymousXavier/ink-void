extends Resource
class_name ParryData

enum State { READY, PARRYING, RECOVERING }

@export var current_state: State = State.READY

# The micro-timer used for active slash frames and the brief delay between spams
@export var timer: float = 0.0 

# AMMO SYSTEM
@export var max_charges: int = 3
@export var current_charges: int = 3
@export var recharge_time: float = 2.0 # Takes 2 seconds to get 1 slash back
@export var recharge_timer: float = 0.0

@export var parry_pierce_bonus: int = 0
@export var parry_damage_bonus: int = 0
@export var parry_speed_multiplier: float = 1.0
