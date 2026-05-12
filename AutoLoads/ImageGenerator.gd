extends Node2D

func generate_texture_for(render_profile: RenderProfile):
	match render_profile.shape_type:
		Enums.SHAPE_TYPES.CIRCLE:
			return await generate_circle_texture(render_profile)
		Enums.SHAPE_TYPES.SQUARE:
			return await generate_square_texture(render_profile)

func generate_circle_texture(render_profile: RenderProfile) -> ImageTexture:
	var radius = render_profile.size
	var color = render_profile.core_color
	var border_width = render_profile.border_width
	
	# 1. Setup a Viewport (the "Canvas")
	var viewport = SubViewport.new()
	viewport.size = Vector2i(radius * 2, radius * 2)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# 2. Create a drawing node
	var drawer = Node2D.new()
	drawer.draw.connect(func(): 
		var is_filled = not render_profile.is_hollow
		# If filled, border_width is ignored. If hollow, use border_width.
		drawer.draw_circle(Vector2(radius, radius), radius - border_width, color, is_filled, border_width)
	)
	
	# 3. Add to scene tree so it can render
	add_child(viewport)
	viewport.add_child(drawer)
	
	# 4. Wait for the frame to render
	await RenderingServer.frame_post_draw
	
	# 5. Capture the "Saved" image
	var img = viewport.get_texture().get_image()
	var texture = ImageTexture.create_from_image(img)
	
	# Cleanup
	viewport.queue_free()
	
	return texture

func generate_square_texture(render_profile: RenderProfile) -> ImageTexture:
	var width = render_profile.size
	var color = render_profile.core_color
	var border_width = render_profile.border_width
	
	# 1. Setup a Viewport (the "Canvas")
	var viewport = SubViewport.new()
	viewport.size = Vector2i(width, width)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# 2. Create a drawing node
	var drawer = Node2D.new()
	drawer.draw.connect(func(): 
		var is_filled = not render_profile.is_hollow
		drawer.draw_rect(Rect2(0, 0, width, width), color, is_filled, border_width)
	)
	
	# 3. Add to scene tree so it can render
	add_child(viewport)
	viewport.add_child(drawer)
	
	# 4. Wait for the frame to render
	await RenderingServer.frame_post_draw
	
	# 5. Capture the "Saved" image
	var img = viewport.get_texture().get_image()
	var texture = ImageTexture.create_from_image(img)
	
	# Cleanup
	viewport.queue_free()
	
	return texture
	
static func create_render_profile(shape_type: Enums.SHAPE_TYPES, border_width: int, core_color: Color,  size: int, is_hollow: bool):
	var render_profile = RenderProfile.new()
	
	render_profile.border_width = border_width
	render_profile.core_color = core_color
	render_profile.size = size
	render_profile.shape_type = shape_type
	render_profile.is_hollow = is_hollow
	
	return render_profile
