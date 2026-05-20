extends Resource
class_name MeeleData

var attack_range: int # Cells it covers
var damage: float
var fire_rate: float # Bullets per sec
var target_id: int
var pierce_count: int = 0 # How many more enemies THIS specific bullet can hit
var mass: float

var hit_targets: Array[int] = []
