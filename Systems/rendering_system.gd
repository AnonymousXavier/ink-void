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
	
	# Find the bullet we are holding (so its not gray)
	var player_id = SceneInstances.entity_manager.player_id
	var hijacked_id = -1
	
	if is_frozen and player_id != -1:
		var parry = SceneInstances.entity_manager.parry_components.get(player_id)
		hijacked_id = parry.hijacked_bullet_id
	
	# 3. Handle the Background Grid Shader
	var bg_material = SceneInstances.BG.material as ShaderMaterial
	var grid_color = Color("333333") if is_frozen else Color("1c1c28") 
	bg_material.set_shader_parameter("border_color", grid_color)
		
	# 4. The Entity Loop
	for entity_id in SceneInstances.entity_manager.render_components:
		if entity_id not in SceneInstances.entity_manager.transform_components: continue
				
		var render_data = SceneInstances.entity_manager.render_components[entity_id]
		var transform_data = SceneInstances.entity_manager.transform_components[entity_id]
			
		var core_color = render_data.modulate
		var active_texture = render_data.texture
		
		# If time is frozen, and this ISN'T the player, and this ISN'T the hijacked bullet...
		if is_frozen and entity_id != player_id and entity_id != hijacked_id:
			if render_data.frozen_texture:
				active_texture = render_data.frozen_texture # Turn it dead gray!
		
		# Now draw using the active_texture (with the Double-Draw center math from before!)
		var distance_from_cam = (transform_data.position - camera_pos) * zoom
		var final_screen_pos = screen_center + distance_from_cam
		var offset = -active_texture.get_size() / 2.0 
		var core_scale = render_data.rendering_scale * zoom
		
		# Halo
		draw_set_transform(final_screen_pos, transform_data.rotation, core_scale * 1.3)
		draw_texture(active_texture, offset, Color(1.0, 1.0, 1.0, 0.15))

		# Flash
		# If the entity is currently screaming in pain, overdrive the glow
		if SceneInstances.entity_manager.flash_components.has(entity_id):
			core_color = Color(8.0, 8.0, 8.0, 1.0) # Overblown pure white
			
		# Core
		draw_set_transform(final_screen_pos, transform_data.rotation, core_scale)
		draw_texture(active_texture, offset, core_color)
		
		# --- THE SHOCKWAVE (WHOOSH) ---

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
