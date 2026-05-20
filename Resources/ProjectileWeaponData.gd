extends Resource
class_name ProjectileWeaponData

@export var attack_range: int # Cells it covers
@export var damage: float
@export var fire_rate: float # Bullets per sec
@export var target_id: int

@export var target_alignments: Array[Enums.ALIGNMENTS]

@export var is_aiming: bool = false
@export var aim_timer: float = 0.0
@export var aim_duration: float = 0.8 # Takes 0.8 seconds to lock on and fire
