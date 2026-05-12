extends Resource
class_name ProjectileWeaponData

@export_group("Core Stats")
@export var attack_range: int # Cells it covers
@export var damage: float
@export var fire_rate: float # Bullets per sec
@export var target_id: int
@export var target_alignments: Array[Enums.ALIGNMENTS]

func clone() -> ProjectileWeaponData:
	var data_clone = ProjectileWeaponData.new()
	
	data_clone.attack_range = attack_range
	data_clone.damage = damage
	data_clone.fire_rate = fire_rate
	data_clone.target_alignments = target_alignments
	
	return data_clone
