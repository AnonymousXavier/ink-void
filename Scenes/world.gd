extends Node2D

@onready var bg: ColorRect = $BG
@onready var rendering_system: RenderingSystem = $RenderingSystem
@onready var input_system: InputSystem = $InputSystem
@onready var events_manager: EventsManager = $EventsManager
@onready var enemy_manager: EnemyManager = $EnemyManager
@onready var camera: Camera = $Camera
@onready var homing_system: HomingSystem = $HomingSystem
@onready var movement_system: MovementSystem = $MovementSystem
@onready var entity_manager: EntityManager = $EntityManager
@onready var shooting_system: ShootingSystem = $ShootingSystem
@onready var count_down_system: CountDownSystem = $CountDownSystem
@onready var projectile_dispatch_system: Node = $ProjectileDispatchSystem
@onready var impact_system: Node = $ImpactSystem
@onready var damage_system: DamageSystem = $DamageSystem
@onready var health_system: HealthSystem = $HealthSystem
@onready var death_system: Node = $DeathSystem
@onready var bank_system: Node = $BankSystem
@onready var overlay_system: Node = $OverlaySystem
@onready var player_controller_system: PlayerControllerSystem = $PlayerControllerSystem
@onready var stalking_system: StalkingSystem = $StalkingSystem


var player_spawned: bool = false
var shader_material: ShaderMaterial

func _ready() -> void:
	SceneInstances.camera = camera
	SceneInstances.BG = bg
	SceneInstances.events_manager = events_manager
	SceneInstances.entity_manager = entity_manager
	SceneInstances.rendering_system = rendering_system
	
	Factories.create_bullet_pool()
	
func _process(delta: float) -> void:
	if Cache.is_ready and not player_spawned:
		Factories.create_player(Vector2.ZERO)
		player_spawned = true
	
	events_manager.update(delta) # Automatically Clears it self at the end of the frame so order doesnt really matter
	overlay_system.update(delta)
	
	input_system.update(delta)
	
	player_controller_system.update(delta)
	
	enemy_manager.update()
	camera.update()
	homing_system.update(delta)
	
	stalking_system.update()
	movement_system.update(delta)
	
	count_down_system.update(delta)
	
	shooting_system.update(delta)
	projectile_dispatch_system.update(delta)
	impact_system.update(delta)
	damage_system.update(delta)
	health_system.update(delta)
	death_system.update(delta)
	
	bank_system.update(delta)
	
		
	
