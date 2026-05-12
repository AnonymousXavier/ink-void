extends Node

var is_ready: bool

# RENDERING DATA
@onready var render_info: Dictionary[Enums.ENTITY_TYPES, RenderProfile]
@onready var textures_dict: Dictionary[Enums.ENTITY_TYPES, ImageTexture]

func _ready() -> void:
	render_info = {
		# ENEMY
		Enums.ENTITY_TYPES.NORMAL_ENEMY: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.CIRCLE, 8, Color.RED, Constants.TILE_SIZE, Constants.TILE_SIZE, true),
		# PROJECTILES
		Enums.ENTITY_TYPES.BULLET: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.CIRCLE, 0, Color.RED, Constants.TILE_SIZE * 0.1, Constants.TILE_SIZE * 0.1, false),
		# UI
		Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.SQUARE, 11, Color.GRAY, Constants.TILE_SIZE, Constants.TILE_SIZE, true),
		Enums.ENTITY_TYPES.PLAYER: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.RECTANGLE, 0, Color.WHITE, Constants.TILE_SIZE * 0.2, Constants.TILE_SIZE * 0.5,  false)
	}
	textures_dict = {
		Enums.ENTITY_TYPES.NORMAL_ENEMY: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.NORMAL_ENEMY]),
		Enums.ENTITY_TYPES.BULLET: await  ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.BULLET]),
		Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY]),
		Enums.ENTITY_TYPES.PLAYER: await  ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.PLAYER])
	}
	
	is_ready = true
