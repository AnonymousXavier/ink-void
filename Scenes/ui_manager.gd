extends CanvasLayer
class_name UIManager

@onready var timer_label: Label = $Control/TimerLabel
@onready var cards_container: HBoxContainer = $Control/HBoxContainer

func _ready() -> void:
	cards_container.hide()

func _process(_delta: float) -> void:
	if not Cache.is_ready or not SceneInstances.wave_system: return
	
	var time_left = SceneInstances.wave_system.time_left
	
	# Format the float into a clean MM:SS string
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	
	timer_label.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
	
	# Optional: Make it pulse red in the last 5 seconds!
	if time_left <= 5.0 and SceneInstances.wave_system.is_wave_active:
		timer_label.modulate = Color.RED if int(time_left * 10) % 2 == 0 else Color.WHITE
	else:
		timer_label.modulate = Color.WHITE

func show_cards() -> void:
	SceneInstances.time_scale = 0.0 # Pause reality
	
	# 1. Scrub the old deck from the table
	for child in cards_container.get_children():
		child.queue_free()
		
	# 2. Shuffle and Deal
	var all_keys = Constants.UPGRADES.keys()
	all_keys.shuffle()
	var dealt_keys = all_keys.slice(0, 3) # Grab the first 3 unique keys
	
	# 3. Spawn the Visual Cards
	for key in dealt_keys:
		var card_data = Constants.UPGRADES[key]
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
