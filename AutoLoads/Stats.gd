extends Node

@onready var meele_data: Dictionary[Enums.ENTITY_TYPES, MeeleData] = {
	Enums.ENTITY_TYPES.NORMAL_ENEMY: Misc.create_meele_data_for(Enums.LEVELS.HIGH, Enums.LEVELS.HIGH)
}

@onready var projectile_weapon_data: Dictionary[Enums.ENTITY_TYPES, ProjectileWeaponData] = {
	Enums.ENTITY_TYPES.TURRET: Misc.create_projectile_data_for(Enums.LEVELS.HIGH, Enums.LEVELS.LOW, Enums.LEVELS.HIGH, [Enums.ALIGNMENTS.ENEMY])
}

@onready var health_data: Dictionary[Enums.ENTITY_TYPES, HealthData] = {
	Enums.ENTITY_TYPES.BASE: Misc.create_health_data(100),
	Enums.ENTITY_TYPES.NORMAL_ENEMY: Misc.create_enemy_health_data_for(Enums.LEVELS.LOW),
	Enums.ENTITY_TYPES.TURRET: Misc.create_tower_health_data_for(Enums.LEVELS.LOW)
}
