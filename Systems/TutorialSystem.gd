extends Node
class_name TutorialSystem

# Added DASH_FAILED and PARRY_FAILED states!
enum Phase { WELCOME, DASH_TEST, DASH_FAILED, PARRY_TEST, PARRY_FAILED, COMPLETE }
var current_phase: Phase = Phase.WELCOME

var has_moved: bool = false
var has_slashed: bool = false
var phase_timer: float = 0.0

var instruction_label: Label
var tutorial_enemy_id: int = -1

func _ready() -> void:
	instruction_label = Label.new()
	var style = LabelSettings.new()
	style.font_size = 32
	style.font_color = Color(1, 1, 1, 0.8)
	instruction_label.label_settings = style
	instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction_label.text = "CALIBRATING...\nWASD TO MOVE. [L-CLICK] TO SLASH."
	
	var canvas = CanvasLayer.new()
	canvas.add_child(instruction_label)
	add_child(canvas)

func update(delta: float) -> void:
	var em = SceneInstances.entity_manager
	var player_id = em.player_id
	if player_id == -1: return
	
	_ensure_player_immortality(player_id, em)
	_monitor_events(player_id)
	
	var input = em.player_input_data
	if not input: return
	
	# Keep text centered
	instruction_label.position = (get_viewport().get_visible_rect().size / 2.0) - (instruction_label.size / 2.0)
	instruction_label.position.y -= 150
	
	match current_phase:
		Phase.WELCOME:
			if input.direction != Vector2.ZERO: has_moved = true
			if input.fire_pressed: has_slashed = true
				
			if has_moved and has_slashed:
				_transition_to_dash_test()
				
		Phase.DASH_TEST:
			phase_timer -= delta
			# Timer shortened! They can't outrun it anymore.
			if phase_timer <= 0:
				_transition_to_parry_test()
				
		Phase.DASH_FAILED:
			# Explicit retry loop
			instruction_label.text = "FAILED. YOU ARE ONLY INVINCIBLE *WHILE* DASHING.\n[ L-CLICK ] TO TRY AGAIN."
			if input.fire_pressed:
				input.fire_pressed = false # Consume the input
				_transition_to_dash_test()
				
		Phase.PARRY_TEST:
			pass
			
		Phase.PARRY_FAILED:
			# Explicit retry loop
			instruction_label.text = "FAILED. SLASH THE BULLET *BEFORE* IT HITS YOU.\n[ L-CLICK ] TO TRY AGAIN."
			if input.left_click_pressed:
				input.left_click_pressed = false # Consume the input
				_transition_to_parry_test()
				
		Phase.COMPLETE:
			pass

# ==========================================
# PHASE TRANSITIONS & LOGIC
# ==========================================
func _transition_to_dash_test() -> void:
	current_phase = Phase.DASH_TEST
	phase_timer = 1.5 # Shortened to 1.5s so they have to react fast
	instruction_label.text = "FATAL ANOMALY DETECTED.\n[SPACEBAR] TO QUICKSILVER DASH THROUGH IT."
	SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SCREEN_SHAKE, "intensity": 0.5})
	
	_spawn_bullet_wall()

func _spawn_bullet_wall() -> void:
	var player_pos = SceneInstances.entity_manager.transform_components[SceneInstances.entity_manager.player_id].position
	var start_pos = player_pos + Vector2(500, -600)
	
	# Cranked the speed to 800.0 so they physically cannot run away from it!
	for i in range(30):
		var spawn_pos = start_pos + Vector2(0, i * 40)
		Factories.spawn_bullet(spawn_pos, Vector2.LEFT, 1.0, SceneInstances.entity_manager.player_id, 800.0, Color(1.0, 0.2, 0.2))

func _transition_to_parry_test() -> void:
	current_phase = Phase.PARRY_TEST
	instruction_label.text = "EXCELLENT. NOW, SLASH ENEMY BULLETS\nTO PARRY THEM BACK."
	
	var em = SceneInstances.entity_manager
	var player_pos = em.transform_components[em.player_id].position
	
	tutorial_enemy_id = Factories.create_enemy(Enums.ENTITY_TYPES.NORMAL_ENEMY, player_pos + Vector2(400, 0))
	
	var vel_data = em.velocity_components.get(tutorial_enemy_id)
	if vel_data: vel_data.speed = 0.0

func _transition_to_complete() -> void:
	current_phase = Phase.COMPLETE
	instruction_label.text = "CALIBRATION COMPLETE.\nGRANTING 100 SOULS. RETURNING TO LOBBY..."
	instruction_label.label_settings.font_color = Color(0.2, 1.0, 0.2) 
	
	SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SCREEN_SHAKE, "intensity": 1.0})
	_clear_all_bullets()
	
	MetaEconomy.total_gold += 100 
	
	get_tree().create_timer(3.0).timeout.connect(func():
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	)

# ==========================================
# EVENT MONITORS & FAIL SAFES
# ==========================================
func _monitor_events(player_id: int) -> void:
	for event in SceneInstances.events_manager.events:
		if event.type == Enums.EVENT_TYPES.DAMAGE_ATTEMPT:
			
			# 1. PLAYER GOT HIT
			if event.get("id") == player_id:
				if current_phase == Phase.DASH_TEST:
					current_phase = Phase.DASH_FAILED
					_clear_all_bullets()
					
				elif current_phase == Phase.PARRY_TEST:
					current_phase = Phase.PARRY_FAILED
					_clear_all_bullets()
					_clear_tutorial_enemy() # Wipe the drone out so they can reset
					
			# 2. DRONE GOT HIT
			elif event.get("id") == tutorial_enemy_id and current_phase == Phase.PARRY_TEST:
				_transition_to_complete()

func _ensure_player_immortality(player_id: int, em: EntityManager) -> void:
	var health = em.health_components.get(player_id)
	if health and health.health < health.maxHealth:
		health.health = health.maxHealth 
		SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SCREEN_SHAKE, "intensity": 0.8})
		
func _clear_all_bullets() -> void:
	var em = SceneInstances.entity_manager
	var bullet_ids = em.is_a_bullet.keys()
	for b_id in bullet_ids:
		Factories.despawn_bullet(b_id)

func _clear_tutorial_enemy() -> void:
	if tutorial_enemy_id != -1:
		var em = SceneInstances.entity_manager
		
		# Set its gold value to 0 so the player can't farm infinite Souls by intentionally failing!
		if em.gold_value_components.has(tutorial_enemy_id):
			em.gold_value_components[tutorial_enemy_id].gold = 0
			
		# Fire a kill event so your DeathSystem cleans it up naturally
		SceneInstances.events_manager.add_event({
			"type": Enums.EVENT_TYPES.ENTITY_KILLED,
			"id": tutorial_enemy_id
		})
		tutorial_enemy_id = -1
