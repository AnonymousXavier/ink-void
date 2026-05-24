extends CanvasLayer
class_name UIManager

@onready var timer_label: Label = $LabelsMarginContainer/TimerLabel
@onready var cards_container: HBoxContainer = $Control/HBoxContainer
@onready var build_pips: HBoxContainer = $Control/MarginContainer/BuildPips
@onready var souls_label: Label = $LabelsMarginContainer/SoulsLabel

@onready var death_overlay: ColorRect = $Control/DeathOverlay
@onready var retry_button: Button = $Control/DeathOverlay/VBoxContainer/RetryButton
@onready var main_menu_button: Button = $Control/DeathOverlay/VBoxContainer/MainMenuButton

var displayed_souls: int = 0 # The visual counter that lags behind the logical bank

func _ready() -> void:
	cards_container.hide()
	death_overlay.hide()

	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func _process(_delta: float) -> void:
	if not Cache.is_ready or not SceneInstances.wave_system: return
	
	var time_left = SceneInstances.wave_system.time_left
	
	# Format the float into a clean MM:SS string
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	
	timer_label.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
	
	# Make it pulse red
	if time_left <= 5.0 and SceneInstances.wave_system.is_wave_active:
		timer_label.modulate = Color.RED if int(time_left * 10) % 2 == 0 else Color.WHITE
	else:
		timer_label.modulate = Color.WHITE

	# THE HUD LISTENER
	for event in SceneInstances.events_manager.events:
		match event.type:
			Enums.EVENT_TYPES.UPGRADE_APPLIED:
				_add_sigil_to_hud(event["upgrade_id"])
			Enums.EVENT_TYPES.SHOW_DEATH_SCREEN:
				_show_death_overlay()
			Enums.EVENT_TYPES.SHOW_REVIVE_UI:
				# This references the child node you just dropped into the tree!
				$ReviveUI.display_ultimatum(event["cost"], event["can_afford"])
			Enums.EVENT_TYPES.SOUL_COLLECTED:
				_spawn_flying_soul(event["world_pos"], event["amount"])

# THE JUICE MATH
func _spawn_flying_soul(world_pos: Vector2, amount: int) -> void:
	var screen_center = get_viewport().get_visible_rect().size / 2.0
	var camera_pos = SceneInstances.camera.position
	var zoom = SceneInstances.camera.zoom
	
	var start_screen_pos = screen_center + ((world_pos - camera_pos) * zoom)
	
	# ==========================================
	# 1. CREATE A ROUND SOUL (Procedural StyleBox)
	# ==========================================
	var soul_node = Panel.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.8, 1.0, 1.0) # Solid Light Blue
	
	# Maxing out the corner radius forces the square Panel into a perfect circle
	style.corner_radius_top_left = 100
	style.corner_radius_top_right = 100
	style.corner_radius_bottom_left = 100
	style.corner_radius_bottom_right = 100
	
	# Add a glowing aura
	style.shadow_color = Color(0.2, 0.8, 1.0, 0.6)
	style.shadow_size = int(6 * zoom)
	
	soul_node.add_theme_stylebox_override("panel", style)
	soul_node.size = Vector2(12.0, 12.0) * zoom
	soul_node.position = start_screen_pos - (soul_node.size / 2.0)
	
	# ==========================================
	# 2. CREATE THE TRAIL (CPUParticles2D)
	# ==========================================
	var trail = CPUParticles2D.new()
	trail.amount = 16
	trail.lifetime = 0.3
	trail.gravity = Vector2.ZERO # No falling, just drag
	trail.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	trail.emission_sphere_radius = 2.0 * zoom
	trail.scale_amount_min = 2.0 * zoom
	trail.scale_amount_max = 8.0 * zoom
	trail.color = Color(0.2, 0.8, 1.0, 0.5) # Semi-transparent tail
	trail.position = soul_node.size / 2.0 # Anchor it strictly to the center of the circle!
	
	soul_node.add_child(trail)
	$Control.add_child(soul_node)
	
	# 3. THE FLIGHT ANIMATION
	var target_pos = souls_label.global_position
	var tween = create_tween().set_parallel(true)
	
	# Erupt outward in a chaotic spread
	var random_burst = Vector2(randf_range(-60, 60), randf_range(-60, -100)) * zoom
	var mid_pos = start_screen_pos + random_burst
	
	tween.tween_property(soul_node, "position", mid_pos, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(soul_node, "position", target_pos, 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	# 4. THE IMPACT & CLEANUP
	tween.chain().tween_callback(func():
		_increment_soul_counter(amount)
		
		# Instead of deleting it instantly (which deletes the trail abruptly),
		# we turn off the core visual, stop emitting new particles, and wait for the tail to fade!
		style.bg_color.a = 0.0
		style.shadow_color.a = 0.0
		trail.emitting = false
		
		# Safely delete the node from memory after the trail's lifetime finishes
		get_tree().create_timer(0.3).timeout.connect(soul_node.queue_free)
	)

func _increment_soul_counter(amount: int) -> void:
	displayed_souls += amount
	souls_label.text = "SOULS: " + str(displayed_souls)
	
	# Center the pivot so the scale effect expands from the middle, not the top-left corner
	souls_label.pivot_offset = souls_label.size / 2.0
	
	# Reset the scale to overblown, then smoothly bounce it back to normal
	souls_label.scale = Vector2(1.5, 1.5)
	souls_label.modulate = Color.WHITE # Flash it pure white
	
	var punch_tween = create_tween().set_parallel(true)
	punch_tween.tween_property(souls_label, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	punch_tween.tween_property(souls_label, "modulate", Color(0.2, 0.8, 1.0), 0.3) # Settle back into Light Blue

func _add_sigil_to_hud(upgrade_id: String) -> void:
	# If a pip with this exact ID already exists, update it instead of making a new one
	if build_pips.has_node(upgrade_id):
		var existing_pip = build_pips.get_node(upgrade_id)
		
		# Increment our internal UI counter
		var new_level = existing_pip.get_meta("level_count") + 1
		existing_pip.set_meta("level_count", new_level)
		
		# Update the tiny text
		var level_label = existing_pip.get_node("VBox/LevelLabel")
		level_label.text = "Lv" + str(new_level)
		
		# VGive it a tiny "heartbeat" pulse so the player knows it leveled up
		existing_pip.pivot_offset = existing_pip.size / 2.0
		var tween = create_tween()
		tween.tween_property(existing_pip, "scale", Vector2(1.3, 1.3), 0.1)
		tween.tween_property(existing_pip, "scale", Vector2(1.0, 1.0), 0.1)
		return 
		
	# THE SPAWNER (If we don't own it yet)
	var data = Constants.UPGRADES[upgrade_id]
	
	var panel = PanelContainer.new()
	panel.name = upgrade_id 
	panel.set_meta("level_count", 1) # Store our starting level
	
	var style = StyleBoxFlat.new()
	style.bg_color = data["color"] * 0.15 
	style.border_color = data["color"] 
	style.set_border_width_all(2)
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(32, 32) 
	
	# Create a VBox to stack the Sigil and the Level Counter
	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var sigil_label = Label.new()
	sigil_label.text = data["sigil"]
	sigil_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sigil_label.add_theme_font_size_override("font_size", 14)
	sigil_label.add_theme_color_override("font_color", data["color"]) 
	
	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.text = "Lv1"
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 10) # Tiny text under the sigil
	level_label.add_theme_color_override("font_color", data["color"] * 0.8) 
	
	vbox.add_child(sigil_label)
	vbox.add_child(level_label)
	panel.add_child(vbox)
	
	build_pips.add_child(panel)

func show_cards() -> void:
	SceneInstances.time_scale = 0.0 # Pause game
	
	# Remove old cards
	for child in cards_container.get_children():
		child.queue_free()
		
	# Shuffle and Deal
	var all_keys = SceneInstances.wave_system.active_deck.keys()
	all_keys.shuffle()
	var dealt_keys = all_keys.slice(0, 3) # Grab the first 3 unique keys
	
	# 3. Spawn the Visual Cards
	for key in dealt_keys:
		var card_data = SceneInstances.wave_system.active_deck[key]
		var card = Cache.UPGRADE_CARD_SCENE.instantiate() as UpgradeCard
		
		cards_container.add_child(card)
		card.setup(key, card_data) # Inject the data!
		
		# Dynamically wire the click event to fire into the ECS!
		card.pressed.connect(func(): select_upgrade(key))
		
	cards_container.show()

func select_upgrade(upgrade_id: String) -> void:
	cards_container.hide()
	
	SceneInstances.events_manager.add_event({
		"type": Enums.EVENT_TYPES.UPGRADE_APPLIED, 
		"upgrade_id": upgrade_id
	})
	
	SceneInstances.time_scale = 1.0
	SceneInstances.wave_system.start_next_wave()

func _show_death_overlay() -> void:
	SceneInstances.time_scale = 0.0 # Hard freeze the corpse swarm
	death_overlay.show()

func _on_retry_pressed() -> void:
	SceneInstances.time_scale = 1.0
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	# 1. Fetch the gold earned this run
	var run_gold = SceneInstances.entity_manager.bank_data.gold # How do we ask the BankSystem for the current run's earnings?
	
	# 2. Inject it into the permanent Meta Economy
	MetaEconomy.total_gold += run_gold
	
	# 3. Fire the Save Event BEFORE you destroy the scene!
	SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SAVE_REQUESTED})
	
	# 4. Clean up and leave
	SceneInstances.time_scale = 1.0
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
