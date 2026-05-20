extends Node

var is_ready: bool

# Keep separate dictionaries to prevent key collisions between base assets and chrono states
@onready var render_info: Dictionary[Enums.ENTITY_TYPES, RenderProfile] = {}
@onready var textures_dict: Dictionary = {} # Maps ENUMS to baked textures
@onready var frozen_textures_dict: Dictionary = {}

const UPGRADE_CARD_SCENE = preload("uid://du424w1sbe728")

func _ready() -> void:
	# BASE STATIC COMPONENT
	render_info = {
		Enums.ENTITY_TYPES.BULLET: ImageGenerator.create_render_profile(
			Enums.SHAPE_TYPES.CIRCLE, 0, Color("ff0033"), Constants.TILE_SIZE * 0.15, Constants.TILE_SIZE * 0.15, false
		),
		Enums.ENTITY_TYPES.PLAYER: ImageGenerator.create_render_profile(
			Enums.SHAPE_TYPES.SQUARE, 0, Color.WHITE, Constants.TILE_SIZE * 0.4, Constants.TILE_SIZE * 0.4, false
		),
		Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY: ImageGenerator.create_render_profile(
			Enums.SHAPE_TYPES.SQUARE, 4, Color("444455"), Constants.TILE_SIZE, Constants.TILE_SIZE, true
		)
	}
	
	# Bake static textures
	textures_dict[Enums.ENTITY_TYPES.BULLET] = await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.BULLET])
	textures_dict[Enums.ENTITY_TYPES.PLAYER] = await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.PLAYER])
	textures_dict[Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY] = await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY])

	# Static frozen bullet
	var frozen_bullet_info = ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.CIRCLE, 0, Color(0.3, 0.3, 0.3), Constants.TILE_SIZE * 0.15, Constants.TILE_SIZE * 0.15, false)
	frozen_textures_dict[Enums.ENTITY_TYPES.BULLET] = await ImageGenerator.generate_texture_for(frozen_bullet_info)

	# DYNAMIC GEOMETRIC PROFILE BAKE LOOP
	# We iterate through your profiles and register textures directly using enemy type keys
	for enemy_type in Stats.ENEMY_PROFILES.keys():
		var profile = Stats.ENEMY_PROFILES[enemy_type]
		
		# Bake Active Variant Render Info
		# The Sniper uses TRIANGLE, Tank uses SQUARE
		var active_profile = ImageGenerator.create_render_profile(
			profile["shape"], 6, profile["color"], Constants.TILE_SIZE * 0.8, Constants.TILE_SIZE * 0.8, true
		)
		textures_dict[enemy_type] = await ImageGenerator.generate_texture_for(active_profile)
		
		# Bake Muted Chrono/Frozen Profile (Desaturated Gray variants)
		var frozen_profile = ImageGenerator.create_render_profile(
			profile["shape"], 6, Color(0.3, 0.3, 0.3), Constants.TILE_SIZE * 0.8, Constants.TILE_SIZE * 0.8, true
		)
		frozen_textures_dict[enemy_type] = await ImageGenerator.generate_texture_for(frozen_profile)
	
	is_ready = true
