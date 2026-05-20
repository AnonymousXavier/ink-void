extends Resource
class_name ProjectileWeaponData

var attack_range: int # Cells it covers
var damage: float
var fire_rate: float # Bullets per sec
var target_id: int

var target_alignments: Array[Enums.ALIGNMENTS]

var is_aiming: bool = false
var aim_timer: float = 0.0
var aim_duration: float = 0.8 # Takes 0.8 seconds to lock on and fire
