extends Node
class_name SaveSystem

func update() -> void:
	for event in SceneInstances.events_manager.events:
		if event.type == Enums.EVENT_TYPES.SAVE_REQUESTED:
			_save_game()

func _save_game() -> void:
	var em = SceneInstances.entity_manager
	var player_id = em.player_id
	if player_id == -1: return
	
	var bank: BankData = em.bank_data
	if not bank: return
	
	# Update the Global Vault
	MetaEconomy.total_gold += bank.gold
	
	# Package the persistent data
	var save_dict = {
		"total_gold": MetaEconomy.total_gold,
		"unlocked_perks": MetaEconomy.unlocked_perks,
		"active_perks": MetaEconomy.active_perks
	}
	
	# Write securely to the device
	var file = FileAccess.open(Constants.SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict))
		file.close()
		print("EXTRACTION COMPLETE. Meta-Gold: ", MetaEconomy.total_gold)
