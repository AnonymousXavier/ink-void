extends Node

@onready var meele_data: Dictionary[Enums.ENTITY_TYPES, MeeleData] = {
	Enums.ENTITY_TYPES.NORMAL_ENEMY: Misc.create_meele_data_for(Enums.LEVELS.HIGH, Enums.LEVELS.HIGH)
}


@onready var health_data: Dictionary[Enums.ENTITY_TYPES, HealthData] = {
	Enums.ENTITY_TYPES.NORMAL_ENEMY: Misc.create_enemy_health_data_for(Enums.LEVELS.LOW),
}
