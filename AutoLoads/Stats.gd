extends Node

# Dynamically compiled data registries
var meele_data: Dictionary[Enums.ENTITY_TYPES, MeeleData] = {}
var projectile_weapon_datas: Dictionary[Enums.ENTITY_TYPES, ProjectileWeaponData] = {}
var health_data: Dictionary[Enums.ENTITY_TYPES, HealthData] = {}

const ENEMY_PROFILES = {
	Enums.ENTITY_TYPES.NORMAL_ENEMY: {
		"shape": Enums.SHAPE_TYPES.CIRCLE,
		"color": Color("ff2244"),
		"health": 1,
		"speed": 80.0,
		"damage": 1,
		"mass": 1.0,
		"fire_rate": 1.0
	},
	Enums.ENTITY_TYPES.SNIPER_ENEMY: {
		"shape": Enums.SHAPE_TYPES.TRIANGLE,
		"color": Color(1.0, 0.7, 0.1),
		"health": 2,
		"speed": 110.0,
		"damage": 1,
		"mass": 0.5,
		"fire_rate": 0.4
	},
	Enums.ENTITY_TYPES.TANK_ENEMY: {
		"shape": Enums.SHAPE_TYPES.SQUARE,
		"color": Color(0.2, 0.5, 1.0),
		"health": 3,
		"speed": 40.0,
		"damage": 2,
		"mass": 4.0,
		"fire_rate": 0.5
	}
}

# Explicit enemy density curves mapping
const WAVE_SPAWN_WEIGHTS = {
	1: { Enums.ENTITY_TYPES.NORMAL_ENEMY: 100 },
	2: { Enums.ENTITY_TYPES.NORMAL_ENEMY: 90,  Enums.ENTITY_TYPES.SNIPER_ENEMY: 10 },
	3: { Enums.ENTITY_TYPES.NORMAL_ENEMY: 80,  Enums.ENTITY_TYPES.SNIPER_ENEMY: 20 },
	4: { Enums.ENTITY_TYPES.NORMAL_ENEMY: 70,  Enums.ENTITY_TYPES.SNIPER_ENEMY: 30 },
	5: { Enums.ENTITY_TYPES.NORMAL_ENEMY: 60,  Enums.ENTITY_TYPES.SNIPER_ENEMY: 40 },
	6: { Enums.ENTITY_TYPES.NORMAL_ENEMY: 55,  Enums.ENTITY_TYPES.SNIPER_ENEMY: 45 },
	7: { Enums.ENTITY_TYPES.NORMAL_ENEMY: 50,  Enums.ENTITY_TYPES.SNIPER_ENEMY: 50 }, # Peak 50/50 Skill Check
	8: { Enums.ENTITY_TYPES.NORMAL_ENEMY: 45,  Enums.ENTITY_TYPES.SNIPER_ENEMY: 45, Enums.ENTITY_TYPES.TANK_ENEMY: 10 } # Tanks arrive!
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
		var weapon = Misc.create_projectile_data_for(
			profile["fire_rate"], 
			profile["damage"], 
			Constants.CHUNK_SIZE * 0.5, 
			[Enums.ALIGNMENTS.PLAYER]
		)
		
		# Set custom aim times per profile variant
		if enemy_type == Enums.ENTITY_TYPES.SNIPER_ENEMY:
			weapon.aim_duration = 1.2 # Snipers trace long lines before firing
		else:
			weapon.aim_duration = 0.5
			
		projectile_weapon_datas[enemy_type] = weapon
		
		# Compile Core Health tracking structures
		health_data[enemy_type] = Misc.create_health_data(
			profile["health"]
		)

# Generates procedural scaling for infinite runs past wave 8
static func get_spawn_weights_for_wave(wave: int) -> Dictionary:
	if WAVE_SPAWN_WEIGHTS.has(wave):
		return WAVE_SPAWN_WEIGHTS[wave]
	
	# Beyond wave 8, slowly bleed out the normal swarms to make room for heavy threats
	var sniper_weight = min(45, 45 + (wave - 8))
	var tank_weight = min(35, 10 + ((wave - 8) * 3))
	var normal_weight = max(20, 100 - sniper_weight - tank_weight)
	
	return {
		Enums.ENTITY_TYPES.NORMAL_ENEMY: normal_weight,
		Enums.ENTITY_TYPES.SNIPER_ENEMY: sniper_weight,
		Enums.ENTITY_TYPES.TANK_ENEMY: tank_weight
	}
