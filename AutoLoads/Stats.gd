extends Node

# Automatically compiled component data registries
var meele_data: Dictionary[Enums.ENTITY_TYPES, MeeleData] = {}
var projectile_weapon_datas: Dictionary[Enums.ENTITY_TYPES, ProjectileWeaponData] = {}
var health_data: Dictionary[Enums.ENTITY_TYPES, HealthData] = {}

const ENEMY_PROFILES = {
	Enums.ENTITY_TYPES.NORMAL_ENEMY: {
		"shape": Enums.SHAPE_TYPES.CIRCLE,
		"color": Color("ff2244"),
		"health": 10,
		"speed": 80.0,
		"damage": 1,
		"mass": 1.0,
		"fire_rate": 1.0
	},
	Enums.ENTITY_TYPES.SNIPER_ENEMY: {
		"shape": Enums.SHAPE_TYPES.TRIANGLE,
		"color": Color(1.0, 0.7, 0.1),
		"health": 10,
		"speed": 110.0,
		"damage": 1,
		"mass": 0.5,
		"fire_rate": 0.4
	},
	Enums.ENTITY_TYPES.TANK_ENEMY: {
		"shape": Enums.SHAPE_TYPES.SQUARE,
		"color": Color(0.2, 0.5, 1.0),
		"health": 20,
		"speed": 40.0,
		"damage": 2,
		"mass": 4.0,
		"fire_rate": 0.5
	}
}

func _ready() -> void:
	# Automate component dictionary generation straight from the profiles source
	for enemy_type in ENEMY_PROFILES.keys():
		var profile = ENEMY_PROFILES[enemy_type]
		
		# Compile Melee Data structures
		meele_data[enemy_type] = Misc.create_meele_data_for(
			profile["fire_rate"], 
			profile["damage"]
		)
		
		# Compile Projectile Systems 
		projectile_weapon_datas[enemy_type] = Misc.create_projectile_data_for(
			profile["fire_rate"], 
			profile["damage"], 
			Constants.CHUNK_SIZE * 0.5, 
			[Enums.ALIGNMENTS.PLAYER]
		)
		
		# Compile Core Health tracking structures
		health_data[enemy_type] = Misc.create_health_data(
			profile["health"]
		)
