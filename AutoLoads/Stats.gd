extends Node

@onready var meele_data: Dictionary[Enums.ENTITY_TYPES, MeeleData] = {
	Enums.ENTITY_TYPES.NORMAL_ENEMY: Misc.create_meele_data_for(1, 1)
}

@onready var projectile_weapon_datas: Dictionary[Enums.ENTITY_TYPES, ProjectileWeaponData] = {
	Enums.ENTITY_TYPES.NORMAL_ENEMY: Misc.create_projectile_data_for(1, 1, Constants.CHUNK_SIZE * 0.375, [Enums.ALIGNMENTS.PLAYER])
}

@onready var health_data: Dictionary[Enums.ENTITY_TYPES, HealthData] = {
	Enums.ENTITY_TYPES.NORMAL_ENEMY: Misc.create_health_data(1),
}
