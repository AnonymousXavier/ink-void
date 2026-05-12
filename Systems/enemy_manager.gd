extends Node
class_name EnemyManager

var start_time: int
var enemies_currently_alive = 0

func _ready() -> void:
	start_time = Time.get_ticks_msec()
	
func _process(_delta: float) -> void:
	if not Cache.is_ready:
		return
	
	enemies_currently_alive = len(SceneInstances.entity_manager.is_an_enemy)
	handle_enemy_spawning()
	process_enemies()
	
func get_enemies_expected_on_screen(secs_passed: int):
	var minimum_enemies_expected = 5
	return sin(deg_to_rad(secs_passed))* 10 + minimum_enemies_expected
	
func handle_enemy_spawning():
	var secs_passed = (Time.get_ticks_msec() - start_time) / 1000
	if get_enemies_expected_on_screen(secs_passed) > enemies_currently_alive:
		spawn_enemy()

func process_enemies():
	var entity_manager = SceneInstances.entity_manager
	for enemy_id in entity_manager.is_an_enemy:
		if enemy_id not in entity_manager.velocity_components: # Isnt Currently in Motion
			var velocity_data = VelocityData.new()
			var movement_event = {"type": Enums.EVENT_TYPES.MOVEMENT, "id": enemy_id}
			
			velocity_data.target = SceneInstances.camera.get_center()
			entity_manager.velocity_components[enemy_id] = velocity_data
			
			SceneInstances.events_manager.add_event(movement_event)

func spawn_enemy(): # A higher level function, spawn enemy a random an enemy at a random coord outside screen boundaries
	var enemy_type = Enums.ENTITY_TYPES.NORMAL_ENEMY
	var camera = SceneInstances.camera
	
	var cam_center = camera.get_center()
	var cam_size = camera.get_size()
	
	var direction = Vector2i(1 if Constants.RNG.randi_range(0, 1) else -1, 1 if Constants.RNG.randi_range(0, 1) else -1)
	var x = Constants.RNG.randf_range(cam_size.y / 2, cam_size.y)
	var y = Constants.RNG.randf_range(cam_size.y / 2, cam_size.y)
	var spawn_pos = Vector2i(cam_center) + Vector2i(x,y) * direction
	
	var enemy_id = Factories.create_enemy(enemy_type, spawn_pos)
	SceneInstances.entity_manager.add_entity_to_a_chunk(spawn_pos, enemy_id)
	
