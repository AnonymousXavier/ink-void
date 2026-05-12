extends Resource
class_name ParryData

enum State { READY, PARRYING, RECOVERING }

@export var current_state: State = State.READY
@export var timer: float = 0.0
