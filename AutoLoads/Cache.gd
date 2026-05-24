extends Node

var is_ready: bool

# RENDERING DATA
@onready var textures_dict: Dictionary[Enums.ENTITY_TYPES, ImageTexture]
@onready var base_colors: Dictionary[Enums.ENTITY_TYPES, Color]

const UPGRADE_CARD_SCENE = preload("uid://du424w1sbe728")

func _ready() -> void:
	# 1. Define the true default colors of your entities here so Factories can read them!
	base_colors = {
		Enums.ENTITY_TYPES.NORMAL_ENEMY: Color("ff2244"),
		Enums.ENTITY_TYPES.TANK_ENEMY: Color("ff8800"),
		Enums.ENTITY_TYPES.SNIPER_ENEMY: Color("aa22ff"),
		Enums.ENTITY_TYPES.BULLET: Color("ff0033"),
		Enums.ENTITY_TYPES.PLAYER: Color.WHITE,
		Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY: Color("444455")
	}

	# 2. Bake everything in pure Color.WHITE (The Modulate property will do the heavy lifting later)
	var render_info = {
		Enums.ENTITY_TYPES.NORMAL_ENEMY: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.CIRCLE, 6, Color.WHITE, int(Constants.TILE_SIZE * 0.8), int(Constants.TILE_SIZE * 0.8), true),
		Enums.ENTITY_TYPES.TANK_ENEMY: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.SQUARE, 0, Color.WHITE, int(Constants.TILE_SIZE * 1.2), int(Constants.TILE_SIZE * 1.2), false),
		Enums.ENTITY_TYPES.SNIPER_ENEMY: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.CIRCLE, 4, Color.WHITE, int(Constants.TILE_SIZE * 0.6), int(Constants.TILE_SIZE * 0.6), true),
		Enums.ENTITY_TYPES.BULLET: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.CIRCLE, 0, Color.WHITE, int(Constants.TILE_SIZE * 0.15), int(Constants.TILE_SIZE * 0.15), false),
		Enums.ENTITY_TYPES.PLAYER: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.SQUARE, 0, Color.WHITE, int(Constants.TILE_SIZE * 0.4), int(Constants.TILE_SIZE * 0.4), false),
		Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.SQUARE, 4, Color.WHITE, Constants.TILE_SIZE, Constants.TILE_SIZE, true)
	}

	textures_dict = {
		Enums.ENTITY_TYPES.NORMAL_ENEMY: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.NORMAL_ENEMY]),
		Enums.ENTITY_TYPES.TANK_ENEMY: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.TANK_ENEMY]), 
		Enums.ENTITY_TYPES.SNIPER_ENEMY: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.SNIPER_ENEMY]), 
		Enums.ENTITY_TYPES.BULLET: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.BULLET]),
		Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY]),
		Enums.ENTITY_TYPES.PLAYER: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.PLAYER])
	}

	is_ready = true
