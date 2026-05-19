extends Node
class_name LoadSystem

func execute_load() -> void:
	if not FileAccess.file_exists(Constants.SAVE_PATH):
		print("NO SAVE FOUND. Initializing fresh economy.")
		return # MetaEconomy variables remain at their defaults
		
	var file = FileAccess.open(Constants.SAVE_PATH, FileAccess.READ)
	var json_str = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(json_str)
	if typeof(data) == TYPE_DICTIONARY:
		# Populate the Global Vault!
		if data.has("total_gold"): MetaEconomy.total_gold = data["total_gold"]
		if data.has("unlocked_perks"): MetaEconomy.unlocked_perks = data["unlocked_perks"]
		if data.has("active_perks"): MetaEconomy.active_perks = data["active_perks"]
		print("SAVE LOADED SUCCESSFULLY.")
