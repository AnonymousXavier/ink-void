extends Node

# BACKGROUND AND WORLD STATS
const TILE_SIZE = 32
const CHUNK_SIZE = 512
const BG_BORDER_WIDTH = 1 # px
const PARRY_RADIUS: float = TILE_SIZE / 2.0

var RNG = RandomNumberGenerator.new()
