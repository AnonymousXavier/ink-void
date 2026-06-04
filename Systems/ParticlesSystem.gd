extends Node
class_name ParticlesSystem

var particle_pool: Array[GPUParticles2D] = []
var active_particles: Array[GPUParticles2D] = []

func _ready() -> void:
	# Pre-forge the particle emitters so we never instantiate during combat
	for i in range(50):
		var p = GPUParticles2D.new()
		p.emitting = false
		p.one_shot = true
		p.explosiveness = 1.0
		p.amount = 12
		p.lifetime = 0.4 
		
		# Configure the burst physics material
		var mat = ParticleProcessMaterial.new()
		mat.particle_flag_disable_z = true
		
		# Directional explosion controls
		mat.spread = 60.0 # Restricts it to a cone rather than a full circle
		mat.direction = Vector3(-1, 0, 0) # Base direction (we manipulate rotation on spawn)
		
		# Velocity and acceleration (The snap factor)
		mat.initial_velocity_min = 150.0
		mat.initial_velocity_max = 300.0
		mat.gravity = Vector3(0, 0, 0) # No gravity 
		mat.damping_min = 200.0 # sparks to slow down over time
		mat.damping_max = 300.0
		
		# sizing/scaling over time
		mat.scale_min = 2.0
		mat.scale_max = 5.0
		
		# Fade out cleanly over lifetime
		var alpha_curve = Curve.new()
		alpha_curve.add_point(Vector2(0, 1.0)) # Fully opaque at spawn
		alpha_curve.add_point(Vector2(1.0, 0.0)) # Dissolves into nothingness at end
		
		var texture_curve = CurveTexture.new()
		texture_curve.curve = alpha_curve
		mat.alpha_curve = texture_curve
		
		p.process_material = mat
		
		p.top_level = false 
		
		p.process_material = mat
		
		# Create a solid 3x3 white square image buffer
		var img = Image.create(2, 2, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE) # Gives the pixels solid data to modulate
		
		p.texture = ImageTexture.create_from_image(img)
		
		particle_pool.append(p)
		# 2. Attach them to the main world container, bypassing the rendering_system's matrix matrix offsets completely
		get_tree().current_scene.call_deferred("add_child", p)

func update(delta: float) -> void:
	# Catch the impact events
	for event in SceneInstances.events_manager.events:
		if event.type == Enums.EVENT_TYPES.SPAWN_IMPACT_PARTICLE:
			_trigger_burst(event.get("pos", Vector2.ZERO), event.get("color", Color.WHITE))
			
	# Reclaim finished particles safely back to the pool
	for i in range(active_particles.size() - 1, -1, -1):
		var p = active_particles[i]
		
		# If the node is sitting in the active array but isn't emitting, 
		# it has fully finished its 0.4s lifetime cycle!
		if not p.emitting:
			active_particles.remove_at(i)
			particle_pool.append(p)

func _trigger_burst(pos: Vector2, color: Color) -> void:
	if particle_pool.is_empty(): return 
	
	var p = particle_pool.pop_back()
	var screen_size = SceneInstances.camera.get_size()
	var top_left = SceneInstances.camera._top_left
	var bottom_right = top_left + screen_size
	
	pos = pos - top_left
	
	# Clean global coordinates snap onto your bullet impact vectors smoothly now!
	p.global_position = pos 
	p.modulate = color
	
	var angle = 0.0
	var threshold = 15.0
	
	# The edge detection math still evaluates beautifully using the absolute world coordinates
	if abs(pos.x - top_left.x) <= threshold:
		angle = 0.0
	elif abs(pos.x - bottom_right.x) <= threshold:
		angle = PI
	elif abs(pos.y - top_left.y) <= threshold:
		angle = PI / 2.0
	elif abs(pos.y - bottom_right.y) <= threshold:
		angle = -PI / 2.0
	else:
		angle = randf_range(0, 2 * PI)
		
	p.global_rotation = angle
	p.restart() 
	
	active_particles.append(p)
