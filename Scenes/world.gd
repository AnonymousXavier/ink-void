extends Node2D

@onready var bg: ColorRect = $BG
@onready var ui_manager: UIManager = $UIManager

# Initialize Systems
var rendering_system: RenderingSystem = RenderingSystem.new()
var input_system: InputSystem = InputSystem.new()
var events_manager: EventsManager = EventsManager.new()
var enemy_manager: EnemyManager = EnemyManager.new()
var camera: Camera = Camera.new()
var homing_system: HomingSystem = HomingSystem.new()
var movement_system: MovementSystem = MovementSystem.new()
var entity_manager: EntityManager = EntityManager.new()
var shooting_system: ShootingSystem = ShootingSystem.new()
var count_down_system: CountDownSystem = CountDownSystem.new()
var projectile_dispatch_system: ProjectileDispatchSystem = ProjectileDispatchSystem.new()
var impact_system: ImpactSystem = ImpactSystem.new()
var damage_system: DamageSystem = DamageSystem.new()
var health_system: HealthSystem = HealthSystem.new()
var death_system: DeathSystem = DeathSystem.new()
var bank_system: BankSystem = BankSystem.new()
var overlay_system: OverlaySystem = OverlaySystem.new()
var player_controller_system: PlayerControllerSystem = PlayerControllerSystem.new()
var stalking_system: StalkingSystem = StalkingSystem.new()
var parry_system: ParrySystem = ParrySystem.new()
var splatter_canvas: SplatterCanvas = SplatterCanvas.new()
var camera_shake_system: CameraShakeSystem = CameraShakeSystem.new()
var flash_system: FlashSystem = FlashSystem.new()
var dash_system: DashSystem = DashSystem.new()
var wave_system: WaveSystem = WaveSystem.new()
var shockwave_system: ShockwaveSystem = ShockwaveSystem.new()
var upgrade_system: UpgradeSystem = UpgradeSystem.new()
var game_over_system: GameOverSystem = GameOverSystem.new()
var load_system: LoadSystem = LoadSystem.new()
var save_system: SaveSystem = SaveSystem.new()
var revive_system: ReviveSystem = ReviveSystem.new()
var particles_system: ParticlesSystem = ParticlesSystem.new()

# Define Variables
var player_spawned: bool = false
var shader_material: ShaderMaterial

func _ready() -> void:
	SceneInstances.viewport = get_viewport()
	
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
	add_systems_to_scene()
	
func add_systems_to_scene():
	add_child(splatter_canvas)
	add_child(rendering_system)
	
	add_child(wave_system)
	add_child(particles_system)
	
func _process(delta: float) -> void:
	if Cache.is_ready and not player_spawned:
		Factories.create_player(Vector2.ZERO)
		player_spawned = true
		
	rendering_system.update()
	
	events_manager.update(delta) # Automatically Clears it self at the end of the frame so order doesnt really matter
	overlay_system.update(delta)
	
	input_system.update()
	
	parry_system.update(delta)
	dash_system.update(delta)
	
	player_controller_system.update(delta)
	
	enemy_manager.update()
	
	wave_system.update(delta)
	shockwave_system.update(delta)
	camera_shake_system.update(delta)
	camera.update()
	
	homing_system.update(delta)

	stalking_system.update(delta)
	movement_system.update(delta)
	
	count_down_system.update(delta)
	
	shooting_system.update(delta)
	projectile_dispatch_system.update(delta)
	impact_system.update()
	particles_system.update(delta)
	flash_system.update(delta)
	damage_system.update()
	health_system.update()
	
	death_system.update()
	bank_system.update(delta)
	upgrade_system.update()
	revive_system.update()
	
	if not game_over_system.game_ended: game_over_system.update(delta)
	save_system.update()
