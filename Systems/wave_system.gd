extends Node
class_name WaveSystem

var wave_duration: float = 5.0
var time_left: float = wave_duration
var is_wave_active: bool = true
var current_wave: int = 1

func _ready() -> void:
	SceneInstances.wave_system = self

func update(delta: float) -> void:
	if not is_wave_active: return
	
	time_left -= delta
	
	if time_left <= 0.0:
		is_wave_active = false
		trigger_shockwave()

func trigger_shockwave() -> void:
	# Spawn a massive, invisible "Hitbox" entity at the center of the arena
	# We will give it a unique component so a new system can expand it!
	var id = SceneInstances.entity_manager.next_entity_id
	SceneInstances.entity_manager.next_entity_id += 1
	
	var transform_data = TransformData.new()
	var wave_data = ShockWaveData.new()
	transform_data.position =  SceneInstances.entity_manager.transform_components[SceneInstances.entity_manager.player_id].position
	
	# We create a temporary dictionary in EntityManager just for this:
	# var shockwave_components: Dictionary = {}
	SceneInstances.entity_manager.shockwave_components[id] = wave_data
	SceneInstances.entity_manager.transform_components[id] = transform_data
	SceneInstances.entity_manager.active_entities.append(id)

func start_next_wave() -> void:
	current_wave += 1
	
	# Optional: You can make the wave_duration longer each wave!
	# wave_duration += 10.0 
	
	time_left = wave_duration
	is_wave_active = true
	
	print("STARTING WAVE: ", current_wave)
