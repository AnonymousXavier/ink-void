extends Node2D
class_name RenderingSystem

var screen_center: Vector2
var has_spawned_overlay: bool

func _process(_delta: float) -> void:
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
	
	# 2. Find the bullet we are holding (so we don't turn it gray!)
	var player_id = SceneInstances.entity_manager.player_id
	var hijacked_id = -1
	if is_frozen and player_id != -1:
		var parry = SceneInstances.entity_manager.parry_components.get(player_id)
		if parry:
			hijacked_id = parry.hijacked_bullet_id
	
	# 3. Handle the Background Grid Shader
	var bg_material = SceneInstances.BG.material as ShaderMaterial
	if bg_material:
		# If frozen, shift the grid lines to a dead gray. If normal, neon violet!
		var grid_color = Color("333333") if is_frozen else Color("1c1c28") 
		bg_material.set_shader_parameter("border_color", grid_color)
		# ... (keep your existing camera_pos and zoom bindings here)
		
	# 4. The Entity Loop
	for entity_id in SceneInstances.entity_manager.render_components:
		if entity_id not in SceneInstances.entity_manager.transform_components: continue
				
		var render_data = SceneInstances.entity_manager.render_components[entity_id]
		var transform_data = SceneInstances.entity_manager.transform_components[entity_id]
			
		# --- THE TEXTURE SWAP ---
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

		# Core
		draw_set_transform(final_screen_pos, transform_data.rotation, core_scale)
		draw_texture(active_texture, offset)
