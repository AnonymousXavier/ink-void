extends Node
class_name EnemyManager

var enemies_currently_alive = 0

func update() -> void:
	if not Cache.is_ready:
		return

	if not SceneInstances.wave_system.is_wave_active:
		return 
	
	enemies_currently_alive = len(SceneInstances.entity_manager.is_an_enemy)
	handle_enemy_spawning()
	
func get_max_enemies_allowed(wave: int) -> int:
	return 2 + ((wave - 1) * 3)
	
func handle_enemy_spawning():
	var wave_sys = SceneInstances.wave_system
	var current_wave = wave_sys.current_wave
	
	if enemies_currently_alive < get_max_enemies_allowed(current_wave):
		spawn_enemy(current_wave)

func spawn_enemy(wave: int):
	var entity_manager = SceneInstances.entity_manager
	
	var weights = Stats.get_spawn_weights_for_wave(wave)
	var total_weight = 0
	
	for w in weights.values():
		total_weight += w
		
	var roll = Constants.RNG.randi_range(0, total_weight)
	var enemy_type = Enums.ENTITY_TYPES.NORMAL_ENEMY 
	
	var running_sum = 0
	for type_key in weights.keys():
		running_sum += weights[type_key]
		if roll <= running_sum:
			enemy_type = type_key
			break

	var camera = SceneInstances.camera
	var cam_center = camera.position
	var cam_size = camera.get_size()
	
	var direction = Vector2i(1 if Constants.RNG.randi_range(0, 1) else -1, 1 if Constants.RNG.randi_range(0, 1) else -1)
	var x = Constants.RNG.randf_range(cam_size.x / 2.0, cam_size.x)
	var y = Constants.RNG.randf_range(cam_size.y / 2.0, cam_size.y)
	var spawn_pos = Vector2i(cam_center) + Vector2i(x,y) * direction
	
	var enemy_id = Factories.create_enemy(enemy_type, spawn_pos)
		
	var render = entity_manager.render_components.get(enemy_id)
	var health = entity_manager.health_components.get(enemy_id)
	var velocity = entity_manager.velocity_components.get(enemy_id)
	
	if health and velocity:
		var hp_multiplier: float = 1.0 + ((wave - 1) * 0.25) 
		var speed_multiplier: float = 1.0 + ((wave - 1) * 0.1) 
		
		health.maxHealth = max(1, int(health.maxHealth * hp_multiplier))
		health.health = health.maxHealth
			
		velocity.speed *= speed_multiplier
			
	if render:
		var red_tint = min(1.0, 0.08 * wave)
		render.modulate = render.modulate * Color(1.0, 1.0 - red_tint, 1.0 - red_tint, 1.0)
	
	SceneInstances.entity_manager.add_entity_to_a_chunk(spawn_pos, enemy_id)
