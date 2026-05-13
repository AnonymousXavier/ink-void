extends Resource
class_name ParryData

enum State { READY, PARRYING, RECOVERING, FROZEN_AIMING }

@export var current_state: State = State.READY
@export var timer: float = 0.0
@export var hijacked_bullet_id: int = -1 # Caches the intercepted bullet
