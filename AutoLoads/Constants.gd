extends Node

const SAVE_PATH = "user://meta_save.json"

# BACKGROUND AND WORLD STATS
const TILE_SIZE = 32
const CHUNK_SIZE = 512
const BG_BORDER_WIDTH = 1 # px

const PARRY_RADIUS: float = TILE_SIZE / 2.0 # Players Hitbox
const PARRY_WAIT_TIME: float = 0.2
const PARRY_MISSED_PENALTY_TIME = 0.5

var RNG = RandomNumberGenerator.new()

const UPGRADES: Dictionary = {
	"hyper_dash": {
		"title": "Hyper Dash", 
		"desc": "+600 Dash Speed.\n-1.0s Cooldown.",
		"sigil": ">>", 
		"color": Color(0.0, 1.0, 1.0), # Cyan (Kinetics)
		"max_level": 2,
		"speed_inc": 600.0,
		"cd_dec": 1.0
	},
	"railgun_pierce": {
		"title": "Railgun Pierce", 
		"desc": "+3 Parried Bullet Pierce.",
		"sigil": "—", # Em-dash
		"color": Color(1.0, 0.2, 0.2), # Red (Munitions)
		"max_level": 3,
		"pierce_inc": 3
	},
	"friction_wake": {
		"title": "Friction Wake", 
		"desc": "Dash leaves a wake.\nSlows enemies by 30%.",
		"sigil": "~", 
		"color": Color(0.2, 0.5, 1.0), # Deep Blue (Kinetics)
		"max_level": 3,
		"wake_radius_inc": 80.0,
		"slow_percent_inc": 0.30
	},
	"heavy_caliber": {
		"title": "Heavy Caliber", 
		"desc": "+1 Parry Damage.\n-10% Bullet Speed.",
		"sigil": "O", 
		"color": Color(1.0, 0.4, 0.0), # Orange (Munitions)
		"max_level": 3,
		"dmg_inc": 1,
		"speed_mult": 0.9 # Multiplies speed by 0.9 (slowing it down for control)
	},
	"thick_blood": {
		"title": "Thick Blood", 
		"desc": "+1 Max HP.\nFully restore Health.",
		"sigil": "+", 
		"color": Color(0.2, 1.0, 0.2), # Green (Survival)
		"max_level": 5,
		"hp_inc": 1
	}
}
