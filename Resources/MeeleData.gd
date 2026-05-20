extends Resource
class_name MeeleData

@export_group("Core Stats")
@export var attack_range: int # Cells it covers
@export var damage: float
@export var fire_rate: float # Bullets per sec
@export var target_id: int
@export var pierce_count: int = 0 # How many more enemies THIS specific bullet can hit
@export var mass: float

var hit_targets: Array[int] = []
