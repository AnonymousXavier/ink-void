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
		"desc": "+600 Dash Speed.\n-1.0s Cooldown."
	},
	"thick_blood": {
		"title": "Thick Blood", 
		"desc": "+1 Max HP.\nFully restore Health."
	},
	"railgun_pierce": {
		"title": "Railgun Pierce", 
		"desc": "Parried bullets rip\nthrough all enemies."
	}
}
