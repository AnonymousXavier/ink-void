extends Node

# BACKGROUND AND WORLD STATS
const TILE_SIZE = 32
const CHUNK_SIZE = 512
const BG_BORDER_WIDTH = 1 # px
const PARRY_RADIUS: float = TILE_SIZE / 2.0

var RNG = RandomNumberGenerator.new()

const UPGRADES: Dictionary = {
	"hyper_dash": {
		"title": "Hyper Dash", 
		"desc": "+600 Dash Speed.\n-1.0s Cooldown.",
		"max_level": 2,
		"speed_inc": 600.0,
		"cd_dec": 1.0
	},
	"thick_blood": {
		"title": "Thick Blood", 
		"desc": "+1 Max HP.\nFully restore Health.",
		"max_level": 5,
		"hp_inc": 1
	},
	"railgun_pierce": {
		"title": "Railgun Pierce", 
		"desc": "+3 Parried Bullet Pierce.",
		"max_level": 3,
		"pierce_inc": 3
	}
}
