extends Node
class_name WaveSystem

var wave_duration: float = 20.0
var time_left: float = wave_duration
var is_wave_active: bool = true
var current_wave: int = 1

var active_deck: Dictionary = {}

func _ready() -> void:
	SceneInstances.wave_system = self
	_initialize_deck()

func _initialize_deck() -> void:
	# Deep clone the blueprint so we don't corrupt the global Dictionary
	active_deck = Constants.UPGRADES.duplicate(true)
	
	# Inject the starting level onto every card
	for upgrade_id in active_deck:
		active_deck[upgrade_id]["current_level"] = 0

func update(delta: float) -> void:
	if not is_wave_active: return
	
	time_left -= delta
	
	if time_left <= 0.0:
		is_wave_active = false
		trigger_shockwave()

func trigger_shockwave() -> void:
	# Spawn a massive, invisible "Hitbox" entity at the center of the arena
	# give it a unique component so a new system can expand it!
	var id = SceneInstances.entity_manager.next_entity_id
	SceneInstances.entity_manager.next_entity_id += 1
	
	var transform_data = TransformData.new()
	var wave_data = ShockWaveData.new()
	transform_data.position =  SceneInstances.entity_manager.transform_components[SceneInstances.entity_manager.player_id].position
	
	SceneInstances.entity_manager.shockwave_components[id] = wave_data
	SceneInstances.entity_manager.transform_components[id] = transform_data
	SceneInstances.entity_manager.active_entities.append(id)

func start_next_wave() -> void:
	current_wave += 1
	
	wave_duration += 10.0 
	time_left = wave_duration
	is_wave_active = true
	
	print("STARTING WAVE: ", current_wave)
