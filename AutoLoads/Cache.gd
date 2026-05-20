extends Node

var is_ready: bool

# RENDERING DATA
@onready var render_info: Dictionary[Enums.ENTITY_TYPES, RenderProfile]
@onready var textures_dict: Dictionary[Enums.ENTITY_TYPES, ImageTexture]
@onready var frozen_textures_dict: Dictionary[Enums.ENTITY_TYPES, ImageTexture]

const UPGRADE_CARD_SCENE = preload("uid://du424w1sbe728")


func _ready() -> void:
	render_info = {
		# ENEMY: Hollow, aggressive neon crimson. Scaled to 0.8 so clustered swarms don't perfectly overlap into a single blob.
		Enums.ENTITY_TYPES.NORMAL_ENEMY: ImageGenerator.create_render_profile(
			Enums.SHAPE_TYPES.CIRCLE, 6, Color("ff2244"), Constants.TILE_SIZE * 0.8, Constants.TILE_SIZE * 0.8, true
		),
		
		# PROJECTILES: Filled, hyper-visible. Slightly larger than before (0.15) for fairness in dodging.
		Enums.ENTITY_TYPES.BULLET: ImageGenerator.create_render_profile(
			Enums.SHAPE_TYPES.CIRCLE, 0, Color("ff0033"), Constants.TILE_SIZE * 0.15, Constants.TILE_SIZE * 0.15, false
		),
		
		# PLAYER: Pure white, filled. A symmetrical 0.4 square (approx 25x25 px) for a perfectly predictable dodge hitbox.
		Enums.ENTITY_TYPES.PLAYER: ImageGenerator.create_render_profile(
			Enums.SHAPE_TYPES.SQUARE, 0, Color.WHITE, Constants.TILE_SIZE * 0.4, Constants.TILE_SIZE * 0.4, false
		),
		
		# UI
		Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY: ImageGenerator.create_render_profile(
			Enums.SHAPE_TYPES.SQUARE, 4, Color("444455"), Constants.TILE_SIZE, Constants.TILE_SIZE, true
		)
	}
	textures_dict = {
		Enums.ENTITY_TYPES.NORMAL_ENEMY: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.NORMAL_ENEMY]),
		Enums.ENTITY_TYPES.BULLET: await  ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.BULLET]),
		Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY: await ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY]),
		Enums.ENTITY_TYPES.PLAYER: await  ImageGenerator.generate_texture_for(render_info[Enums.ENTITY_TYPES.PLAYER])
	}

	var frozen_info = {
	# Flat, dead gray for frozen enemies
		Enums.ENTITY_TYPES.NORMAL_ENEMY: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.CIRCLE, 6, Color(0.3, 0.3, 0.3), Constants.TILE_SIZE * 0.8, Constants.TILE_SIZE * 0.8, true),
	# Flat, dead gray for frozen bullets
		Enums.ENTITY_TYPES.BULLET: ImageGenerator.create_render_profile(Enums.SHAPE_TYPES.CIRCLE, 0, Color(0.3, 0.3, 0.3), Constants.TILE_SIZE * 0.15, Constants.TILE_SIZE * 0.15, false)
	}

# 2. Bake the frozen textures
	frozen_textures_dict = {
		Enums.ENTITY_TYPES.NORMAL_ENEMY: await ImageGenerator.generate_texture_for(frozen_info[Enums.ENTITY_TYPES.NORMAL_ENEMY]),
		Enums.ENTITY_TYPES.BULLET: await ImageGenerator.generate_texture_for(frozen_info[Enums.ENTITY_TYPES.BULLET])
	}

	
	is_ready = true
