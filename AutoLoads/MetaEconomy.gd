extends Node

const SAVE_PATH = "user://meta_progression.save"

var total_gold: int = 0
var active_perks: Array[String] = [] 
var unlocked_perks: Array[String] = []

func _ready() -> void:
	print("[MetaEconomy] System initializing...")
	_load_data()

func save_data() -> void:
	print("[MetaEconomy] Attempting to save data to: ", SAVE_PATH)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file == null:
		print("[MetaEconomy] ERROR: Failed to open save file for writing! Code: ", FileAccess.get_open_error())
		return
		
	var data_dict = {
		"total_gold": total_gold,
		"active_perks": active_perks,
		"unlocked_perks": unlocked_perks
	}
	file.store_var(data_dict)
	print("[MetaEconomy] SUCCESS: Data saved. Vault currently holds: ", total_gold)

func _load_data() -> void:
	print("[MetaEconomy] Checking for save file at: ", SAVE_PATH)
	
	if FileAccess.file_exists(SAVE_PATH):
		print("[MetaEconomy] Save file FOUND. Attempting to read...")
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		
		if file == null:
			print("[MetaEconomy] ERROR: Failed to open save file for reading! Code: ", FileAccess.get_open_error())
			return
			
		var data_dict = file.get_var()
		print("[MetaEconomy] Raw data loaded from file: ", data_dict)
		
		if typeof(data_dict) == TYPE_DICTIONARY:
			total_gold = data_dict.get("total_gold", 0)
			
			var loaded_active = data_dict.get("active_perks", [])
			active_perks.assign(loaded_active)
			
			var loaded_unlocked = data_dict.get("unlocked_perks", [])
			unlocked_perks.assign(loaded_unlocked)
			
			print("[MetaEconomy] SUCCESS: Progression loaded. Total Gold: ", total_gold)
		else:
			print("[MetaEconomy] ERROR: Save file is corrupted or not a Dictionary!")
	else:
		print("[MetaEconomy] Save file NOT FOUND. Initializing fresh save with 1000 starting gold...")
		total_gold = 1000
		save_data()
