extends Node2D
class_name SplatterCanvas

var graveyard_multimesh: MultiMesh
var blood_count: int = 0
var max_blood: int = 5000

func _ready() -> void:
	z_index = -1
	
	graveyard_multimesh = MultiMesh.new()
	graveyard_multimesh.mesh = QuadMesh.new() # The 1x1 geometry
	graveyard_multimesh.transform_format = MultiMesh.TRANSFORM_2D
	graveyard_multimesh.use_colors = true
	graveyard_multimesh.instance_count = max_blood
	
	# Hide all instances initially
	for i in range(max_blood):
		graveyard_multimesh.set_instance_transform_2d(i, Transform2D(0, Vector2.ZERO, 0, Vector2.ZERO))

func _process(_delta: float) -> void:
	call_deferred("queue_redraw")

# We added 'base_color' so we know what color the enemy was!
func stamp(world_pos: Vector2, base_color: Color) -> void:
	# Use the main white texture dictionary now!
	var base_texture = Cache.textures_dict[Enums.ENTITY_TYPES.BULLET]
	var base_size = base_texture.get_size() 
	
	# Generate 3 to 5 droplets per death
	var droplet_count = randi_range(3, 5)
	
	for i in range(droplet_count):
		# Ring Buffer wrap-around check!
		if blood_count >= max_blood:
			blood_count = 0 
			
		var is_center = (i == 0)
		
		# Center pool stays put, satellites scatter randomly
		var scatter = Vector2.ZERO if is_center else Vector2(randf_range(-25, 25), randf_range(-25, 25))
		
		# Scale (Center is massive, satellites are tiny)
		var scale_multiplier = randf_range(2.5, 4.0) if is_center else randf_range(0.8, 1.5)
		var final_scale = base_size * scale_multiplier

		# Transform
		var random_rot = randf_range(0, TAU)
		var t = Transform2D(random_rot, final_scale, 0, world_pos + scatter)
		
		# Color: Multiply the enemy's base color by a darkening factor so it looks like a stained floor!
		var darken_factor = randf_range(0.4, 0.7) 
		var drop_color = Color(base_color.r * darken_factor, base_color.g * darken_factor, base_color.b * darken_factor, randf_range(0.8, 1.0))
		
		# Apply to GPU memory
		graveyard_multimesh.set_instance_transform_2d(blood_count, t)
		graveyard_multimesh.set_instance_color(blood_count, drop_color) 
		
		blood_count += 1

func _draw() -> void:
	if not Cache.is_ready: return
	
	var screen_center = get_viewport_rect().size / 2.0
	var camera_pos = SceneInstances.camera.position
	var zoom = SceneInstances.camera.zoom
	
	# Use the main white texture dictionary here too!
	var blood_tex = Cache.textures_dict[Enums.ENTITY_TYPES.BULLET] 
	
	var cam_offset = screen_center - (camera_pos * zoom)
	draw_set_transform(cam_offset, 0.0, Vector2(zoom, zoom))
	
	draw_multimesh(graveyard_multimesh, blood_tex)
	
	# Reset transform
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
