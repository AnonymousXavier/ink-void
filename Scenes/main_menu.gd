extends Node2D

@onready var events_manager: EventsManager = $EventsManager
@onready var input_system: InputSystem = $InputSystem
@onready var player_controller_system: PlayerControllerSystem = $PlayerControllerSystem
@onready var movement_system: MovementSystem = $MovementSystem
@onready var interaction_system: InteractionSystem = $InteractionSystem
@onready var rendering_system: RenderingSystem = $RenderingSystem
@onready var entity_manager: EntityManager = $EntityManager
@onready var main_menu_ui_manager: Node = $MainMenuUIManager
@onready var bg: ColorRect = $BG
@onready var camera: Camera = $Camera 

var has_spawned_player = false

func _ready() -> void:
	SceneInstances.events_manager = events_manager
	SceneInstances.entity_manager = entity_manager
	SceneInstances.main_menu_ui_manager = main_menu_ui_manager
	SceneInstances.rendering_system = rendering_system
	SceneInstances.BG = bg
	SceneInstances.camera = camera 
	
	_update_gold_display()

func _spawn_objects():
	var screen_center = get_viewport_rect().size / 2.0
	Factories.create_player(screen_center)
	
	# The Shop
	_spawn_terminal(
		screen_center - Vector2(0, 150), # 150px Above Player
		Color(0.2, 0.8, 0.2), 
		Enums.EVENT_TYPES.OPEN_PERK_SHOP
	)
	
	# The Breach / Airlock (Crimson Red)
	_spawn_terminal(
		screen_center + Vector2(0, 150), # 150px Below Player
		Color(0.8, 0.1, 0.1), 
		Enums.EVENT_TYPES.ENTER_ARENA
	)

func _process(delta: float) -> void:
	if not Cache.is_ready: return
	
	if Cache.is_ready and not has_spawned_player:
		_spawn_objects()
		has_spawned_player = true
		
	# 1. Clear the queue
	events_manager.update(delta)
	
	# 2. Process Input and Physics
	input_system.update(delta)
	player_controller_system.update(delta)
	movement_system.update(delta)
	
	interaction_system.update()
	camera.update()
	
	# 4. Listeners catch the events in the same frame
	main_menu_ui_manager.update()
	
	for event in events_manager.events:
		if event.type == Enums.EVENT_TYPES.ENTER_ARENA:
			SceneInstances.time_scale = 1.0 
			get_tree().change_scene_to_file("res://Scenes/world.tscn")
			return # Stop processing immediately
	main_menu_ui_manager.update()

func _spawn_terminal(pos: Vector2, color: Color, event_type: int) -> void:
	var em = SceneInstances.entity_manager
	var t_id = em.next_entity_id
	em.next_entity_id += 1
	
	var t_transform = TransformData.new()
	t_transform.position = pos
	em.transform_components[t_id] = t_transform
	
	var t_render = RenderingData.new()
	t_render.texture = Cache.textures_dict[Enums.ENTITY_TYPES.PLAYER] 
	t_render.modulate = color
	em.render_components[t_id] = t_render
	
	var t_interact = InteractableData.new()
	t_interact.interaction_radius = 60.0
	t_interact.event_to_fire = event_type
	t_interact.base_color = color
	t_interact.hover_color = color.lightened(0.2)
	em.interactable_components[t_id] = t_interact
	
	em.active_entities.append(t_id)

func _update_gold_display() -> void:
	pass
