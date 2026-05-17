extends Resource
class_name MeeleData

@export_group("Core Stats")
@export var attack_range: int # Cells it covers
@export var damage: float
@export var fire_rate: float # Bullets per sec
@export var target_id: int
@export var pierce_count: int = 0 # How many more enemies THIS specific bullet can hit

func clone() -> MeeleData:
	var data_clone = MeeleData.new()
	
	data_clone.attack_range = attack_range
	data_clone.damage = damage
	data_clone.fire_rate = fire_rate
	
	return data_clone
