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
	
	# Bridge the ECS data to the Shader
	var bg_material = SceneInstances.BG.material as ShaderMaterial
	if bg_material:
		bg_material.set_shader_parameter("camera_position", camera_pos)
		bg_material.set_shader_parameter("camera_zoom", zoom)
		bg_material.set_shader_parameter("screen_center", screen_center)
		bg_material.set_shader_parameter("cell_width", Constants.TILE_SIZE)
		
	for entity_id in SceneInstances.entity_manager.render_components:
		if entity_id not in SceneInstances.entity_manager.transform_components:
			continue
				
		var render_data = SceneInstances.entity_manager.render_components[entity_id]
		var transform_data = SceneInstances.entity_manager.transform_components[entity_id]
			
		var texture: Texture2D = render_data.texture
			# 1. Calculate true world distance, then scale it by zoom
		var distance_from_cam = (transform_data.position - camera_pos) * zoom
			
			# 2. Lock it to the center of the physical screen
		var final_screen_pos = screen_center + distance_from_cam
		var offset = Vector2.ZERO
		var core_scale = render_data.rendering_scale * zoom
		var bloom_scale = core_scale * 1.125
		
		# pull the bloom backward so its center perfectly aligns with the core's center
		var scale_difference = 1.125 - 1.0 # 12.5% larger
		var center_of_texture = offset + (texture.get_size() / 2.0)
		var bloom_shift = center_of_texture * core_scale * scale_difference
		
		var bloom_screen_pos = final_screen_pos - bloom_shift
			
		# Draw Bloom (Shifted backward, scaled up)
		draw_set_transform(bloom_screen_pos, transform_data.rotation, bloom_scale)
		draw_texture(texture, offset, Color(1, 1, 1, 0.2))

		# Draw Core (Normal position, normal scale)
		draw_set_transform(final_screen_pos, transform_data.rotation, core_scale)
		draw_texture(texture, offset)
