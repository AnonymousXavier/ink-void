extends Node2D
class_name RenderingSystem

var screen_center: Vector2
var has_spawned_overlay: bool



func update() -> void:
	if not has_spawned_overlay and Cache.is_ready:
		Factories.create_overlay_effect()
		has_spawned_overlay = true
		
	call_deferred("queue_redraw")
	
func _draw() -> void:
	screen_center = get_viewport_rect().size / 2.0
	var camera_pos = SceneInstances.camera.position
	var zoom = SceneInstances.camera.zoom
	
	# 1. Check if the world is frozen
	var is_frozen = SceneInstances.time_scale < 1.0
	
	var player_id = SceneInstances.entity_manager.player_id
	
	# 3. Handle the Background Grid Shader
	var bg_material = SceneInstances.BG.material as ShaderMaterial
	var grid_color = Color("333333") if is_frozen else Color("1c1c28") 
	bg_material.set_shader_parameter("border_color", grid_color)
		
	# The Entity Loop (Sorted for Z-Index)
	var entities_to_draw = SceneInstances.entity_manager.render_components.keys()
	
	# Pluck the player out and push them to the very end of the array 
	# so they are guaranteed to be drawn on top of everything else!
	if player_id in entities_to_draw:
		entities_to_draw.erase(player_id)
		entities_to_draw.append(player_id)
		
	for entity_id in entities_to_draw:
		if entity_id not in SceneInstances.entity_manager.transform_components: continue
		
		var render_data = SceneInstances.entity_manager.render_components[entity_id]
		var transform_data = SceneInstances.entity_manager.transform_components[entity_id]
		var active_texture = render_data.texture
		
		if active_texture == null: continue

		# THE COLOR OVERRIDE PIPELINE
		var active_color = render_data.modulate # 1. Start with the entity's true color
		
		# Time Freeze Overrides Everything (Except Player)
		if is_frozen and entity_id != player_id:
			active_color = Color(0.3, 0.3, 0.3, 1.0) # Dead, brutalist gray
			
		# Damage Flash takes ultimate priority over everything
		if SceneInstances.entity_manager.flash_components.has(entity_id):
			active_color = Color(8.0, 8.0, 8.0, 1.0) # Overblown pure white
		
		var distance_from_cam = (transform_data.position - camera_pos) * zoom
		var final_screen_pos = screen_center + distance_from_cam
		var offset = -active_texture.get_size() / 2.0 
		var core_scale = render_data.rendering_scale * zoom
		
		# Halo
		draw_set_transform(final_screen_pos, transform_data.rotation, core_scale * 1.3)
		var halo_color = active_color
		halo_color.a = 0.15 # Inherit the active color, but make it transparent
		draw_texture(active_texture, offset, halo_color)
		
		# Core
		draw_set_transform(final_screen_pos, transform_data.rotation, core_scale)
		draw_texture(active_texture, offset, active_color)
		
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE) # Reset the transforms for shockwaves
	
	# Shockwave
	for wave_id in SceneInstances.entity_manager.shockwave_components.keys():
		var wave_data = SceneInstances.entity_manager.shockwave_components[wave_id]
		var transform_data = SceneInstances.entity_manager.transform_components[wave_id]
		
		var distance_from_cam = (transform_data.position - camera_pos) * zoom
		var final_screen_pos = screen_center + distance_from_cam
		
		var fade_ratio = 1.0 - (wave_data.radius / wave_data.max_radius)
		var flash_color = Color(3.0, 3.0, 3.0, fade_ratio) 
		
		# Dynamic thickness: Erupts at 80px thick, thins out to 0px as it expands
		var ring_thickness = Constants.TILE_SIZE * fade_ratio * zoom 
		
		# draw_arc(center, radius, start_angle, end_angle, point_count, color, width, antialiased)
		# We use 64 points to keep it perfectly smooth but highly optimized for mobile!
		draw_arc(final_screen_pos, wave_data.radius * zoom, 0.0, TAU, Constants.TILE_SIZE * 0.5, flash_color, ring_thickness, true)
		
	# THE WEAPONS
	var weapons = SceneInstances.entity_manager.projectile_weopon_components
	if player_id != -1 and player_id in SceneInstances.entity_manager.transform_components:
		var p_transform = SceneInstances.entity_manager.transform_components[player_id]
		var player_screen_pos = screen_center + ((p_transform.position - camera_pos) * zoom)
		
		for w_id in weapons:
			if w_id in SceneInstances.entity_manager.transform_components:
				var e_transform = SceneInstances.entity_manager.transform_components[w_id]
				var weapon = weapons[w_id]
				var enemy_screen_pos = screen_center + ((e_transform.position - camera_pos) * zoom)
				
				# THE LASER SIGHT
				if weapon.is_aiming:
					# The laser intensifies as the timer drops to 0!
					var charge_ratio = 1.0 - (weapon.aim_timer / weapon.aim_duration)
					
					# Starts faint red, becomes bright solid red
					var laser_color = Color(1.0, 0.0, 0.0, 0.2 + (0.8 * charge_ratio))
					var laser_thickness = (0.5 + (2.0 * charge_ratio)) * zoom
					
					draw_line(enemy_screen_pos, player_screen_pos, laser_color, laser_thickness, true)

	# INTERACTABLE TERMINAL LABELS
	var default_font = ThemeDB.fallback_font
	for i_id in SceneInstances.entity_manager.interactable_components.keys():
		var i_data = SceneInstances.entity_manager.interactable_components[i_id]
		var t_data = SceneInstances.entity_manager.transform_components.get(i_id)
		
		if not t_data or i_data.terminal_name == "": continue
		
		var i_screen_pos = screen_center + ((t_data.position - camera_pos) * zoom)
		
		var text = i_data.terminal_name
		var font_size = int(16 * zoom)
		var text_size = default_font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		
		# Center the label 50 pixels above the terminal block
		var text_pos = i_screen_pos + Vector2(-text_size.x / 2.0, -50.0 * zoom)
		
		# Draw a clean, dark backing panel behind the text
		var padding = 6.0 * zoom
		var bg_rect = Rect2(text_pos + Vector2(-padding, -text_size.y - padding), text_size + Vector2(padding * 2, padding * 2))
		draw_rect(bg_rect, Color(0.05, 0.05, 0.05, 0.9), true)
		
		# Text color gets brighter when the player steps inside the radius
		var text_color = Color(1.0, 1.0, 1.0, 1.0) if i_data.is_player_in_range else Color(0.5, 0.5, 0.5, 1.0)
		draw_string(default_font, text_pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, text_color)
		
		# If the player is standing inside the activation zone, flash an input prompt!
		if i_data.is_player_in_range:
			var prompt = "[ L-CLICK ]"
			var prompt_font_size = int(12 * zoom)
			var prompt_size = default_font.get_string_size(prompt, HORIZONTAL_ALIGNMENT_CENTER, -1, prompt_font_size)
			var prompt_pos = i_screen_pos + Vector2(-prompt_size.x / 2.0, 60.0 * zoom)
			
			# Create a fast sine wave using engine time so the text pulses rapidly
			var pulse = (sin(Time.get_ticks_msec() / 100.0) + 1.0) / 2.0 
			var pulse_color = Color(1.0, 0.8, 0.2, 0.4 + (0.6 * pulse)) # Golden glow
			
			draw_string(default_font, prompt_pos, prompt, HORIZONTAL_ALIGNMENT_CENTER, -1, prompt_font_size, pulse_color)
			
		# PARRY SLASH ARC (Detached Flying Crescent)
	if player_id != -1 and player_id in SceneInstances.entity_manager.transform_components:
		var parry = SceneInstances.entity_manager.parry_components.get(player_id)
		var input = SceneInstances.entity_manager.player_input_data
		
		# Only draw the arc when the blade is active!
		if parry and parry.current_state == ParryData.State.PARRYING:
			var p_transform = SceneInstances.entity_manager.transform_components[player_id]
			var player_screen_pos = screen_center + ((p_transform.position - camera_pos) * zoom)
			
			var aim_dir = input.aim_direction.normalized()
			if aim_dir == Vector2.ZERO: aim_dir = Vector2.UP
			var aim_angle = aim_dir.angle()
			
			var progress = 1.0 - (parry.timer / Constants.PARRY_WAIT_TIME)
			progress = clamp(progress, 0.0, 1.0)
			
			# Aggressive "Ease-Out" so the swing snaps fast
			var swing_progress = 1.0 - pow(1.0 - progress, 4.0)
			
			# 1. Calculate a MUCH bigger sweeping angle (130 degrees total!)
			var arc_spread = deg_to_rad(65.0) 
			var start_angle = aim_angle - arc_spread
			var end_angle = aim_angle + arc_spread
			
			# 2. THE DETACHED SMEAR MATH
			# The head of the sword travels all the way from left to right
			var head_angle = lerp(start_angle, end_angle, swing_progress)
			
			# The motion trail dynamically grows to 80 degrees long in the middle of the swing, then shrinks!
			var current_trail = deg_to_rad(80.0) * sin(swing_progress * PI)
			var tail_angle = head_angle - current_trail
			
			# Push the visual arc slightly further out for a better sense of reach
			var base_radius = Constants.PARRY_RADIUS * 1.15 * zoom 
			
			# 3. BUILD THE CRESCENT POLYGON
			var points = PackedVector2Array()
			var segments = 16 
			
			# Forced perspective: Swells to 16 pixels thick right as it crosses your mouse cursor!
			var current_max_thickness = lerp(2.0, 16.0, sin(swing_progress * PI)) * zoom
			
			var outer_points = []
			var inner_points = []
			
			# Draw the shape from the fading tail to the sharp leading head
			for i in range(segments + 1):
				var t = float(i) / float(segments) 
				var theta = lerp(tail_angle, head_angle, t)
				
				# Taper the inner and outer edges perfectly together at both ends
				var local_thickness = current_max_thickness * sin(t * PI)
				var direction = Vector2(cos(theta), sin(theta))
				
				var outer_p = player_screen_pos + (direction * (base_radius + local_thickness))
				var inner_p = player_screen_pos + (direction * (base_radius - local_thickness))
				
				outer_points.append(outer_p)
				inner_points.append(inner_p)
				
			inner_points.reverse()
			points.append_array(outer_points)
			points.append_array(inner_points)
			
			# 4. Fade out smoothly
			var alpha = 1.0
			if progress > 0.7:
				alpha = 1.0 - ((progress - 0.7) * 3.33)
				
			var slash_color = Color(1.0, 1.0, 1.0, alpha) 
			
			# Draw the flying blade!
			if head_angle > tail_angle + 0.01: 
				draw_polygon(points, PackedColorArray([slash_color]))
					
	if not (get_tree().current_scene and get_tree().current_scene.name == "World"):
		return
			
	# ==========================================
	# THE PLAYER OVERHEAD HUD (Health, Parry, Dash)
	# ==========================================
	if player_id != -1 and player_id in SceneInstances.entity_manager.transform_components:
		var p_transform = SceneInstances.entity_manager.transform_components[player_id]
		var player_screen_pos = screen_center + ((p_transform.position - camera_pos) * zoom)
		
		# Decoupled Dimensions
		var bar_width = Constants.TILE_SIZE * zoom
		var ammo_bar_height = Constants.TILE_SIZE * 0.12 * zoom # Thin, sleek bars for cooldowns
		var health_height = Constants.TILE_SIZE * 0.15 * zoom   # Thick, chunky bar for Life
		var gap = 0 # Micro-gap to prevent color bleeding
		
		# Calculate exact stacking offsets (Working upwards from the head)
		var base_x_offset = -bar_width / 2.0
		var dash_y_offset = -(Constants.TILE_SIZE * 0.4 * zoom) # Base height above player
		var parry_y_offset = dash_y_offset - ammo_bar_height - gap
		var health_y_offset = parry_y_offset - health_height - gap
		
		# THE PLAYER HEALTH PIPS (TOP BAR)
		var health = SceneInstances.entity_manager.health_components.get(player_id)
		if health and health.maxHealth > 0:
			var pip_width = bar_width / float(health.maxHealth)
			
			for i in range(health.maxHealth):
				var pip_x = player_screen_pos.x + base_x_offset + (i * pip_width)
				
				# Notice we use health_height here instead of the ammo height!
				var pip_rect = Rect2(Vector2(pip_x, player_screen_pos.y + health_y_offset), Vector2(pip_width, health_height))
				var padded_pip = pip_rect.grow(-1.5 * zoom)
				
				if i < health.health:
					# ACTIVE HEALTH: Bright Neon Emerald Green
					draw_rect(padded_pip, Color(0.1, 0.9, 0.3, 1.0), true)
				else:
					# MISSING HEALTH: Hollow, dim red outline
					draw_rect(padded_pip, Color(0.4, 0.1, 0.1, 0.6), false, 2.0 * zoom)
		
		# THE PARRY AMMO BAR (MIDDLE BAR)
		var parry = SceneInstances.entity_manager.parry_components.get(player_id)
		if parry:
			var bar_rect = Rect2(Vector2(player_screen_pos.x + base_x_offset, player_screen_pos.y + parry_y_offset), Vector2(bar_width, ammo_bar_height))
			draw_rect(bar_rect, Color(0.1, 0.1, 0.1, 0.8), true) # Background
			
			var segment_width = bar_width / float(parry.max_charges)
			
			for i in range(parry.max_charges):
				var seg_x = bar_rect.position.x + (i * segment_width)
				var seg_rect = Rect2(Vector2(seg_x, bar_rect.position.y), Vector2(segment_width, ammo_bar_height))
				
				var padded_rect = seg_rect.grow(-1.0 * zoom)
				
				if i < parry.current_charges:
					draw_rect(padded_rect, Color(1.0, 1.0, 1.0, 1.0), true) 
				elif i == parry.current_charges and parry.current_charges < parry.max_charges:
					var recharge_ratio = 1.0 - (parry.recharge_timer / parry.recharge_time)
					var partial_width = (segment_width * recharge_ratio) - (2.0 * zoom)
					if partial_width > 0:
						var partial_rect = Rect2(padded_rect.position, Vector2(partial_width, padded_rect.size.y))
						draw_rect(partial_rect, Color(0.6, 0.8, 1.0, 0.9), true)
	
		# THE DASH COOLDOWN BAR (BOTTOM BAR)
		var dash = SceneInstances.entity_manager.dash_components.get(player_id)
		if dash:
			var bar_rect = Rect2(Vector2(player_screen_pos.x + base_x_offset, player_screen_pos.y + dash_y_offset), Vector2(bar_width, ammo_bar_height))
			draw_rect(bar_rect, Color(0.1, 0.1, 0.1, 0.8), true) # Background
			var padded_rect = bar_rect.grow(-1.0 * zoom)
			
			var fill_ratio = 1.0
			var bar_color = Color(0.0, 1.0, 1.0, 1.0)
			
			if dash.is_dashing:
				fill_ratio = dash.dash_time_left / dash.dash_duration
				bar_color = Color(1.0, 1.0, 1.0, 1.0) 
			elif dash.cooldown_time_left > 0:
				fill_ratio = 1.0 - (dash.cooldown_time_left / dash.cooldown)
				bar_color = Color(0.0, 0.6, 0.8, 0.9)
				
			if fill_ratio > 0:
				var partial_width = padded_rect.size.x * fill_ratio
				var partial_rect = Rect2(padded_rect.position, Vector2(partial_width, padded_rect.size.y))
				draw_rect(partial_rect, bar_color, true)
