extends Node

const SAVE_PATH = "user://meta_save.json"

# BACKGROUND AND WORLD STATS
const TILE_SIZE = 32
const CHUNK_SIZE = 512
const BG_BORDER_WIDTH = 1 # px

const PARRY_RADIUS: float = TILE_SIZE / 2.0 # Players Hitbox
const PARRY_WAIT_TIME: float = 0.2
const PARRY_MISSED_PENALTY_TIME = 0.5
const PARRY_DEFLECTION_ARK_RADIUS = 30.0 # of 360

var RNG = RandomNumberGenerator.new()

# PERKS (Permanent Meta-Upgrades bought in Lobby)
const PERKS: Dictionary = {
	"iron_skin": {
		"title": "Iron Skin",
		"desc": "Start Wave 1 with +1 Max HP.",
		"sigil": "[+]",
		"color": Color(0.2, 1.0, 0.2), # Green
		"cost": 50,
		"stat_id": "max_hp",
		"value": 1.0
	},
	"kinetic_soles": {
		"title": "Kinetic Soles",
		"desc": "Start Wave 1 with +15% Move Speed.",
		"sigil": ">>",
		"color": Color(0.0, 1.0, 1.0), # Cyan
		"cost": 75,
		"stat_id": "move_speed",
		"value": 60.0 # +60 flat speed to the base 400
	},
	"void_battery": {
		"title": "Void Battery",
		"desc": "Start Wave 1 with +1 Max Parry Charge.",
		"sigil": "[O]",
		"color": Color(1.0, 0.2, 1.0), # Magenta
		"cost": 150,
		"stat_id": "max_parry",
		"value": 1.0
	},
	"neural_accelerator": {
		"title": "Neural Accelerator",
		"desc": "Reduce Dash Cooldown by 0.5s.",
		"sigil": "~",
		"color": Color(0.8, 0.8, 1.0), # White/Ice Blue
		"cost": 120,
		"stat_id": "dash_cooldown",
		"value": -0.5 
	},
	"bounty_hunter": {
		"title": "Greed",
		"desc": "Enemies drop 20% more Souls.",
		"sigil": "$",
		"color": Color(1.0, 0.8, 0.2), # Gold
		"cost": 200,
		"stat_id": "soul_multiplier",
		"value": 1.2
	}
}

# UPGRADES (In-Run Roguelike Cards)
const UPGRADES: Dictionary = {
	"hyper_dash": {
		"title": "Hyper Dash", 
		"desc": "+600 Dash Speed.\n-1.0s Cooldown.",
		"sigil": ">>", 
		"color": Color(0.0, 1.0, 1.0), # Cyan
		"max_level": 2,
		"speed_inc": 600.0,
		"cd_dec": 1.0
	},
	"railgun_pierce": {
		"title": "Railgun Pierce", 
		"desc": "+3 Parried Bullet Pierce.",
		"sigil": "—", # Em-dash
		"color": Color(1.0, 0.2, 0.2), # Red
		"max_level": 3,
		"pierce_inc": 3
	},
	"heavy_caliber": {
		"title": "Heavy Caliber", 
		"desc": "+1 Parry Damage.\n-10% Bullet Speed.",
		"sigil": "O", 
		"color": Color(1.0, 0.4, 0.0), # Orange
		"max_level": 3,
		"dmg_inc": 1,
		"speed_mult": 0.9 
	},
	"thick_blood": {
		"title": "Thick Blood", 
		"desc": "+1 Max HP.\nFully restore Health.",
		"sigil": "+", 
		"color": Color(0.2, 1.0, 0.2), # Green
		"max_level": 5,
		"hp_inc": 1
	}
}
