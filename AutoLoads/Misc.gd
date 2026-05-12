extends Node
class_name Misc

static var base = float(Enums.LEVELS.LOW + Enums.LEVELS.MEDIUM + Enums.LEVELS.HIGH)

static func create_meele_data_for(fire_rate: Enums.LEVELS, damage: Enums.LEVELS) -> MeeleData:
	var meele_data = MeeleData.new()
	
	meele_data.attack_range = Constants.MAX_ENEMY_BASE_RANGE
	meele_data.damage = (damage / base) * Constants.MAX_ENEMY_BASE_DAMAGE
	meele_data.fire_rate = (fire_rate / base) * Constants.MAX_ENEMY_BASE_FIRE_RATE
	
	return meele_data

static func create_projectile_data_for(fire_rate: Enums.LEVELS, damage: Enums.LEVELS, attack_range: Enums.LEVELS, target_alignments: Array[Enums.ALIGNMENTS]) -> ProjectileWeaponData:
	var projectile_weapon_data = ProjectileWeaponData.new()
	
	projectile_weapon_data.damage = (damage / base) * Constants.MAX_ENEMY_BASE_DAMAGE
	projectile_weapon_data.attack_range = (attack_range / base) * Constants.MAX_ENEMY_BASE_RANGE * Constants.TILE_SIZE # Covert from cells to int
	projectile_weapon_data.fire_rate = (fire_rate / base) * Constants.MAX_ENEMY_BASE_FIRE_RATE
	projectile_weapon_data.target_alignments = target_alignments
	
	return projectile_weapon_data

static func create_health_data(value: float):
	var health_data = HealthData.new()
	
	health_data.health = value
	health_data.maxHealth = health_data.health
	
	return health_data

static func create_tower_health_data_for(health: Enums.LEVELS):
	return create_health_data((health / base) * Constants.MAX_TURRET_BASE_HEALTH)
	
static func create_enemy_health_data_for(health: Enums.LEVELS):
	return create_health_data((health / base) * Constants.MAX_TURRET_BASE_HEALTH)

static func convert_screen_pos_to_world_pos(position: Vector2):
	var pixel_position =  SceneInstances.camera._top_left + position / SceneInstances.camera.zoom
	var cell_position = Vector2i((pixel_position / Constants.TILE_SIZE).floor())
	return cell_position * Constants.TILE_SIZE
