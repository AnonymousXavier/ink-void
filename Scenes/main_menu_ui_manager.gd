extends CanvasLayer
class_name MainMenuUIManager

# --- UI REFERENCES ---
@onready var gold_label: Label = $Control/GoldLabel
@onready var close_shop_btn: Button = $Control/ShopOverlay/VBoxContainer/CloseButton
@onready var shop_grid: GridContainer = $Control/ShopOverlay/VBoxContainer/ScrollContainer/GridContainer
@onready var shop_overlay: ColorRect = $Control/ShopOverlay

func _ready() -> void:
	shop_overlay.hide()
	close_shop_btn.pressed.connect(_close_shop)
	_update_gold_display()

func update() -> void:
	# The Hub Room UI only listens for one specific event
	for event in SceneInstances.events_manager.events:
		if event.type == Enums.EVENT_TYPES.OPEN_PERK_SHOP:
			_generate_and_open_shop()

func _generate_and_open_shop() -> void:
	# 1. THE SHIELD: If the shop is already open, ignore the event!
	if shop_overlay.visible:
		return 

	for child in shop_grid.get_children():
		shop_grid.remove_child(child) 
		child.queue_free()
		
	for perk_id in Constants.PERKS:
		var data = Constants.PERKS[perk_id]
		var card = Cache.UPGRADE_CARD_SCENE.instantiate() as UpgradeCard
		
		shop_grid.add_child(card)
		card.setup(perk_id, data) 
		
		# 2. THE BIND: Godot 4 lambdas in loops capture by reference, meaning 
		# clicking ANY card might accidentally pass the data for the last card in the loop. 
		# .bind() permanently locks the exact data into the signal.
		card.pressed.connect(_on_perk_clicked.bind(perk_id, data))
		
	_refresh_shop_visuals()
	shop_overlay.show()
	
func _refresh_shop_visuals() -> void:
	for card in shop_grid.get_children():
		# Safety check just in case a scrollbar sneaks into the loop
		if not card is UpgradeCard: continue 
		
		# 2. Read the internal variable you set in card.setup(), not the node name
		var perk_id = card.upgrade_id 
		var data = Constants.PERKS[perk_id]
		
		if MetaEconomy.active_perks.has(perk_id):
			card.desc_label.text = data["desc"] + "\n\n[ EQUIPPED ]"
			card.modulate = data["color"] 
		elif MetaEconomy.unlocked_perks.has(perk_id):
			card.desc_label.text = data["desc"] + "\n\n[ CLICK TO EQUIP ]"
			card.modulate = Color(0.4, 0.4, 0.4) 
		else:
			card.desc_label.text = data["desc"] + "\n\nCOST: " + str(data["cost"]) + " Gold"
			card.modulate = Color(0.8, 0.2, 0.2)

func _on_perk_clicked(perk_id: String, data: Dictionary) -> void:
	if MetaEconomy.active_perks.has(perk_id):
		MetaEconomy.active_perks.erase(perk_id)
	elif MetaEconomy.unlocked_perks.has(perk_id):
		if MetaEconomy.active_perks.size() >= 2:
			MetaEconomy.active_perks.pop_front()
		MetaEconomy.active_perks.append(perk_id)
	else:
		if MetaEconomy.total_gold >= data["cost"]:
			MetaEconomy.total_gold -= data["cost"]
			MetaEconomy.unlocked_perks.append(perk_id)
			MetaEconomy.save_data()
			print("PURCHASED: ", perk_id)
		else:
			print("INSUFFICIENT FUNDS!")
			return 
			
	SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SAVE_REQUESTED})
	_refresh_shop_visuals()
	_update_gold_display()

func _close_shop() -> void:
	shop_overlay.hide()
	SceneInstances.time_scale = 1.0
	
	var em = SceneInstances.entity_manager
	var input = em.player_input_data
	if input: input.fire_pressed = false

func _update_gold_display() -> void:
	gold_label.text = "VAULT: " + str(MetaEconomy.total_gold)
