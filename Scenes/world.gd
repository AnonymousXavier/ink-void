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
@onready var parry_system: ParrySystem = $ParrySystem
@onready var splatter_canvas: SplatterCanvas = $SplatterCanvas
@onready var camera_shake_system: CameraShakeSystem = $CameraShakeSystem
@onready var flash_system: FlashSystem = $FlashSystem
@onready var dash_system: DashSystem = $DashSystem
@onready var wave_system: WaveSystem = $WaveSystem
@onready var shockwave_system: ShockwaveSystem = $ShockwaveSystem
@onready var ui_manager: UIManager = $UIManager
@onready var upgrade_system: UpgradeSystem = $UpgradeSystem
@onready var game_over_system: GameOverSystem = $GameOverSystem
@onready var load_system: LoadSystem = $LoadSystem
@onready var save_system: SaveSystem = $SaveSystem


var player_spawned: bool = false
var shader_material: ShaderMaterial

func _ready() -> void:
	SceneInstances.camera = camera
	SceneInstances.BG = bg
	SceneInstances.events_manager = events_manager
	SceneInstances.entity_manager = entity_manager
	SceneInstances.rendering_system = rendering_system
	SceneInstances.splatter_canvas = splatter_canvas
	SceneInstances.ui_manager = ui_manager
	SceneInstances.save_system = save_system
	SceneInstances.load_system = load_system
	
	Factories.create_bullet_pool()
	
func _process(delta: float) -> void:
	if Cache.is_ready and not player_spawned:
		Factories.create_player(Vector2.ZERO)
		player_spawned = true
	
	events_manager.update(delta) # Automatically Clears it self at the end of the frame so order doesnt really matter
	overlay_system.update(delta)
	
	input_system.update(delta)
	
	parry_system.update(delta)
	dash_system.update(delta)
	
	player_controller_system.update(delta)
	
	enemy_manager.update()
	
	wave_system.update(delta)
	shockwave_system.update(delta)
	camera_shake_system.update(delta)
	camera.update()
	
	homing_system.update(delta)

	stalking_system.update()
	movement_system.update(delta)
	
	count_down_system.update(delta)
	
	shooting_system.update(delta)
	projectile_dispatch_system.update(delta)
	impact_system.update(delta)
	flash_system.update(delta)
	damage_system.update()
	health_system.update()
	
	death_system.update()
	bank_system.update(delta)
	upgrade_system.update()
	
	game_over_system.update(delta)
	save_system.update()
