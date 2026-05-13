extends Node
class_name Misc

static func create_meele_data_for(fire_rate: int, damage: int) -> MeeleData:
	var meele_data = MeeleData.new()
	
	meele_data.attack_range = 1
	meele_data.damage = damage
	meele_data.fire_rate = fire_rate
	
	return meele_data

static func create_projectile_data_for(fire_rate: int, damage:int, attack_range: int, target_alignments: Array[Enums.ALIGNMENTS]) -> ProjectileWeaponData:
	var projectile_weapon_data = ProjectileWeaponData.new()
	
	projectile_weapon_data.damage = damage
	projectile_weapon_data.attack_range = attack_range
	projectile_weapon_data.fire_rate = fire_rate
	projectile_weapon_data.target_alignments = target_alignments
	
	return projectile_weapon_data

static func create_health_data(value: float):
	var health_data = HealthData.new()
	
	health_data.health = value
	health_data.maxHealth = health_data.health
	
	return health_data

static func convert_screen_pos_to_world_pos(position: Vector2):
	var pixel_position =  SceneInstances.camera._top_left + position / SceneInstances.camera.zoom
	var cell_position = Vector2i((pixel_position / Constants.TILE_SIZE).floor())
	return cell_position * Constants.TILE_SIZE
