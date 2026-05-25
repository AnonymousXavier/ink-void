extends Node2D

@onready var bg: ColorRect = $BG
@onready var ui_manager: UIManager = $UIManager 

# Initialize Core Systems
var audio_system: AudioSystem = AudioSystem.new("tutorial_bgm")
var rendering_system: RenderingSystem = RenderingSystem.new()
var input_system: InputSystem = InputSystem.new()
var events_manager: EventsManager = EventsManager.new()
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
var overlay_system: OverlaySystem = OverlaySystem.new()
var player_controller_system: PlayerControllerSystem = PlayerControllerSystem.new()
var stalking_system: StalkingSystem = StalkingSystem.new()
var parry_system: ParrySystem = ParrySystem.new()
var splatter_canvas: SplatterCanvas = SplatterCanvas.new()
var camera_shake_system: CameraShakeSystem = CameraShakeSystem.new()
var flash_system: FlashSystem = FlashSystem.new()
var dash_system: DashSystem = DashSystem.new()
var shockwave_system: ShockwaveSystem = ShockwaveSystem.new()
var particles_system: ParticlesSystem = ParticlesSystem.new()
var hitstop_system: HitStopSystem = HitStopSystem.new()

# Initialize Tutorial-Specific Systems
var boundary_system: BoundarySystem = BoundarySystem.new(Rect2(-300, -300, 1000, 1000))
var tutorial_system: TutorialSystem = TutorialSystem.new()

var player_spawned: bool = false

func _ready() -> void:
	SceneInstances.viewport = get_viewport()
	
	SceneInstances.camera = camera
	SceneInstances.BG = bg
	SceneInstances.events_manager = events_manager
	SceneInstances.entity_manager = entity_manager
	SceneInstances.rendering_system = rendering_system
	SceneInstances.splatter_canvas = splatter_canvas
	SceneInstances.ui_manager = ui_manager
	
	# Nullify the wave system so the UI manager doesn't crash trying to read the timer
	SceneInstances.wave_system = null 
	
	Factories.create_bullet_pool()
	add_systems_to_scene()
	
func add_systems_to_scene():
	add_child(splatter_canvas)
	add_child(rendering_system)
	add_child(particles_system)
	add_child(tutorial_system)
	add_child(audio_system)
	
func _process(delta: float) -> void:
	if Cache.is_ready and not player_spawned:
		Factories.create_player(Vector2.ZERO)
		player_spawned = true
		
	rendering_system.update()
	events_manager.update(delta) 
	overlay_system.update(delta)
	
	input_system.update()
	
	parry_system.update(delta)
	dash_system.update(delta)
	player_controller_system.update(delta)
	
	# Environmental tracking
	homing_system.update(delta)
	stalking_system.update(delta)
	
	movement_system.update(delta)
	boundary_system.update() # CLAMP THE PLAYER AFTER THEY MOVE
	
	# Combat logic
	count_down_system.update(delta)
	shooting_system.update(delta)
	projectile_dispatch_system.update(delta)
	impact_system.update()
	hitstop_system.update()
	particles_system.update(delta)
	flash_system.update(delta)
	damage_system.update()
	health_system.update()
	death_system.update()
	
	# Visual juice
	shockwave_system.update(delta)
	camera_shake_system.update(delta)
	camera.update()
	
	audio_system.update(delta)
	
	# The Director watches everything
	tutorial_system.update(delta)
