extends Node2D

@onready var bg_color_rect: ColorRect = $BG
@onready var enemy_manager: EnemyManager = $EnemyManager
@onready var rendering_system: RenderingSystem = $RenderingSystem
@onready var camera: Camera = $Camera
@onready var events_manager: EventsManager = $EventsManager
@onready var entity_manager: EntityManager = $EntityManager

var player_spawned: bool = false
var shader_material: ShaderMaterial

func _ready() -> void:
	SceneInstances.camera = camera
	SceneInstances.BG = bg_color_rect
	SceneInstances.events_manager = events_manager
	SceneInstances.entity_manager = entity_manager
	SceneInstances.rendering_system = rendering_system
	
	Factories.create_bullet_pool()
	
func _process(delta: float) -> void:
	if Cache.is_ready and not player_spawned:
		Factories.create_player(Vector2.ZERO)
		player_spawned = true
		print("Player Spawned")
