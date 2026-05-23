extends Node

var is_ready: bool

# RENDERING DATA
@onready var render_info: Dictionary[Enums.ENTITY_TYPES, RenderProfile]
@onready var textures_dict: Dictionary[Enums.ENTITY_TYPES, ImageTexture]
@onready var frozen_textures_dict: Dictionary[Enums.ENTITY_TYPES, ImageTexture]

const UPGRADE_CARD_SCENE = preload("uid://du424w1sbe728")

func _ready() -> void:
	render_info = {
		# NORMAL ENEMY: Hollow, aggressive neon crimson.
		Enums.ENTITY_TYPES.NORMAL_ENEMY: ImageGenerator.create_render_profile(
			Enums.SHAPE_TYPES.CIRCLE, 6, Color("ff2244"), Constants.TILE_SIZE * 0.8, Constants.TILE_SIZE * 0.8, true
		),
		
		# THE MISSING ENEMIES
		# TANK ENEMY: Wrap the 1.2 scale in int() to prevent canvas corruption!
		Enums.ENTITY_TYPES.TANK_ENEMY: ImageGenerator.create_render_profile(
			Enums.SHAPE_TYPES.SQUARE, 0, Color("ff8800"), int(Constants.TILE_SIZE * 1.2), int(Constants.TILE_SIZE * 1.2), false
		),
		# SNIPER ENEMY: Swapped to CIRCLE in case ImageGenerator can't draw Triangles!
		Enums.ENTITY_TYPES.SNIPER_ENEMY: ImageGenerator.create_render_profile(
			Enums.SHAPE_TYPES.CIRCLE, 4, Color("aa22ff"), int(Constants.TILE_SIZE * 0.6), int(Constants.TILE_SIZE * 0.6), true
		),
		
		# PROJECTILES
		Enums.ENTITY_TYPES.BULLET: ImageGenerator.create_render_profile(
			Enums.SHAPE_TYPES.CIRCLE, 0, Color.WHITE, Constants.TILE_SIZE * 0.15, Constants.TILE_SIZE * 0.15, false
		),
		
		# PLAYER
		Enums.ENTITY_TYPES.PLAYER: ImageGenerator.create_render_profile(
			Enums.SHAPE_TYPES.SQUARE, 0, Color.WHITE, Constants.TILE_SIZE * 0.4, Constants.TILE_SIZE * 0.4, false
		),
		
		# UI
		Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY: ImageGenerator.create_render_profile(
			Enums.SHAPE_TYPES.SQUARE, 4, Color("444455"), Constants.TILE_SIZE, Constants.TILE_SIZE, true
		)
	}

	# Bake the active textures
	textures_dict = {
		Enums.ENTITY_TYPES.NORMAL_ENEMY: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.NORMAL_ENEMY]),
		Enums.ENTITY_TYPES.TANK_ENEMY: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.TANK_ENEMY]), # Added!
		Enums.ENTITY_TYPES.SNIPER_ENEMY: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.SNIPER_ENEMY]), # Added!
		Enums.ENTITY_TYPES.BULLET: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.BULLET]),
		Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY]),
		Enums.ENTITY_TYPES.PLAYER: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.PLAYER])
	}

	var frozen_info = {
		# Flat, dead gray for frozen entities
		Enums.ENTITY_TYPES.NORMAL_ENEMY: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.CIRCLE, 6, Color(0.3, 0.3, 0.3), int(Constants.TILE_SIZE * 0.8), int(Constants.TILE_SIZE * 0.8), true),
		
		# Wrapped in int() and swapped Sniper to CIRCLE
		Enums.ENTITY_TYPES.TANK_ENEMY: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.SQUARE, 0, Color(0.3, 0.3, 0.3), int(Constants.TILE_SIZE * 1.2), int(Constants.TILE_SIZE * 1.2), false), 
		Enums.ENTITY_TYPES.SNIPER_ENEMY: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.CIRCLE, 4, Color(0.3, 0.3, 0.3), int(Constants.TILE_SIZE * 0.6), int(Constants.TILE_SIZE * 0.6), true), 
		
		Enums.ENTITY_TYPES.BULLET: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.CIRCLE, 0, Color.WHITE, int(Constants.TILE_SIZE * 0.15), int(Constants.TILE_SIZE * 0.15), false)
	}

	# Bake the frozen textures
	frozen_textures_dict = {
		Enums.ENTITY_TYPES.NORMAL_ENEMY: await ImageGenerator.generate_texture_for(frozen_info[Enums.ENTITY_TYPES.NORMAL_ENEMY]),
		Enums.ENTITY_TYPES.TANK_ENEMY: await ImageGenerator.generate_texture_for(frozen_info[Enums.ENTITY_TYPES.TANK_ENEMY]), # Added!
		Enums.ENTITY_TYPES.SNIPER_ENEMY: await ImageGenerator.generate_texture_for(frozen_info[Enums.ENTITY_TYPES.SNIPER_ENEMY]), # Added!
		Enums.ENTITY_TYPES.BULLET: await ImageGenerator.generate_texture_for(frozen_info[Enums.ENTITY_TYPES.BULLET])
	}
	
	is_ready = true
