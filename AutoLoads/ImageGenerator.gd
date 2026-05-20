extends Node2D

func generate_texture_for(render_profile: RenderProfile):
	match render_profile.shape_type:
		Enums.SHAPE_TYPES.CIRCLE:
			return await generate_circle_texture(render_profile)
		Enums.SHAPE_TYPES.SQUARE, Enums.SHAPE_TYPES.RECTANGLE:
			return await generate_rect_texture(render_profile)
		Enums.SHAPE_TYPES.TRIANGLE, Enums.SHAPE_TYPES.DIAMOND:
			return await generate_polygon_texture(render_profile)

func generate_circle_texture(render_profile: RenderProfile) -> ImageTexture:
	var radius = render_profile.width
	var color = render_profile.core_color
	var border_width = render_profile.border_width
	
	var viewport = SubViewport.new()
	viewport.size = Vector2i(radius * 2, radius * 2)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	var drawer = Node2D.new()
	drawer.draw.connect(func(): 
		var is_filled = not render_profile.is_hollow
		drawer.draw_circle(Vector2(radius, radius), radius - border_width, color, is_filled, border_width)
	)
	
	add_child(viewport)
	viewport.add_child(drawer)
	await RenderingServer.frame_post_draw
	
	var img = viewport.get_texture().get_image()
	var texture = ImageTexture.create_from_image(img)
	viewport.queue_free()
	return texture

func generate_rect_texture(render_profile: RenderProfile) -> ImageTexture:
	var width = render_profile.width
	var height = render_profile.height
	var color = render_profile.core_color
	var border_width = render_profile.border_width
	
	var viewport = SubViewport.new()
	viewport.size = Vector2i(width, height)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	var drawer = Node2D.new()
	drawer.draw.connect(func(): 
		var is_filled = not render_profile.is_hollow
		drawer.draw_rect(Rect2(0, 0, width, height), color, is_filled, border_width)
	)
	
	add_child(viewport)
	viewport.add_child(drawer)
	await RenderingServer.frame_post_draw
	
	var img = viewport.get_texture().get_image()
	var texture = ImageTexture.create_from_image(img)
	viewport.queue_free()
	return texture

# New unified method to handle complex poly geometry calculations
func generate_polygon_texture(render_profile: RenderProfile) -> ImageTexture:
	var w = float(render_profile.width)
	var h = float(render_profile.height)
	var color = render_profile.core_color
	
	var viewport = SubViewport.new()
	viewport.size = Vector2i(int(w), int(h))
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	var drawer = Node2D.new()
	drawer.draw.connect(func():
		var points: PackedVector2Array = []
		
		match render_profile.shape_type:
			Enums.SHAPE_TYPES.TRIANGLE:
				# Points mapped: Top-Center, Bottom-Right, Bottom-Left
				points.append(Vector2(w / 2.0, 0.0))
				points.append(Vector2(w, h))
				points.append(Vector2(0.0, h))
				
			Enums.SHAPE_TYPES.DIAMOND:
				# Points mapped: Top-Center, Right-Center, Bottom-Center, Left-Center
				points.append(Vector2(w / 2.0, 0.0))
				points.append(Vector2(w, h / 2.0))
				points.append(Vector2(w / 2.0, h))
				points.append(Vector2(0.0, h / 2.0))
		
		if render_profile.is_hollow:
			# For hollow geometry wireframes, we chain lines point-by-point back to start
			for i in range(points.size()):
				var next_idx = (i + 1) % points.size()
				drawer.draw_line(points[i], points[next_idx], color, render_profile.border_width)
		else:
			# Packed array colors allocation pass
			var colors = PackedColorArray([color])
			drawer.draw_polygon(points, colors)
	)
	
	add_child(viewport)
	viewport.add_child(drawer)
	await RenderingServer.frame_post_draw
	
	var img = viewport.get_texture().get_image()
	var texture = ImageTexture.create_from_image(img)
	viewport.queue_free()
	return texture

static func create_render_profile(shape_type: Enums.SHAPE_TYPES, border_width: int, core_color: Color, width: int, height: int, is_hollow: bool):
	var render_profile = RenderProfile.new()
	render_profile.border_width = border_width
	render_profile.core_color = core_color
	render_profile.width = width
	render_profile.height = height
	render_profile.shape_type = shape_type
	render_profile.is_hollow = is_hollow
	return render_profile
