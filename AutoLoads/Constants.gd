extends Node

# BACKGROUND AND WORLD STATS
const TILE_SIZE = 64
const CHUNK_SIZE = 512
const BG_BORDER_WIDTH = 1 # px

# TURRET STATS
const MAX_TURRET_BASE_HEALTH: int     = 10 # Value of high
const MAX_TURRET_BASE_DAMAGE: float   = 1 # Value of high
const MAX_TURRET_BASE_RANGE: int      = 5 # Value of high
const MAX_TURRET_BASE_FIRE_RATE: int  = 5 # Value of high

# ENEMY STATS
const MAX_ENEMY_BASE_HEALTH: int      = 50 # Value of high
const MAX_ENEMY_BASE_DAMAGE: float    = 1 # Value of high
const MAX_ENEMY_BASE_RANGE: int       = 5 # Value of high
const MAX_ENEMY_BASE_FIRE_RATE: int   = 10 # Value of high

var RNG = RandomNumberGenerator.new()
