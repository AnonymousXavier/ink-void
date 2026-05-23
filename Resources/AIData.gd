extends Resource
class_name AIData

enum State { IDLE, CHASING, STRAFING, RETREATING, STUNNED }

@export var current_state: State = State.CHASING

# How desperately this enemy wants to get away from its allies (1.0 = normal, 2.0 = extreme claustrophobia)
@export var separation_weight: float = 1.5
