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
		var final_screen_pos = screen_center + distance_from_cam
		
		# 2. THE SECRET MATH: Offset by negative half the size to draw perfectly from the center
		var offset = -texture.get_size() / 2.0 
		var core_scale = render_data.rendering_scale * zoom
		
		# Optional: Check if entity has FlashData here to override color!
		var draw_color = Color.WHITE
		
		# 3. Draw Bloom (Scales perfectly from center!)
		draw_set_transform(final_screen_pos, transform_data.rotation, core_scale * 1.3)
		draw_texture(texture, offset, Color(draw_color.r, draw_color.g, draw_color.b, 0.15))

		# 4. Draw Core
		draw_set_transform(final_screen_pos, transform_data.rotation, core_scale)
		draw_texture(texture, offset, draw_color)
