extends Node

func create_enemy(type: Enums.ENTITY_TYPES, pos: Vector2i):
	var id = SceneInstances.entity_manager.next_entity_id
	var entity_manager: EntityManager = SceneInstances.entity_manager
	
	var transform_data = TransformData.new()
	var render_data = RenderingData.new()
	var meele_data = Stats.meele_data[type].clone()
	var health_data = Stats.health_data[type].clone()
	var countdown_data = CountDownData.new()
	var goldvalue_data = GoldValueData.new()
	var alignment_data = AlignmentData.new()
	
	render_data.texture = Cache.textures_dict[type]
	countdown_data.wait_time = 1 / meele_data.fire_rate
	countdown_data.action = Enums.COUNTDOWN_ACTIONS.ATTACK
	transform_data.position = pos
	alignment_data.alignment = Enums.ALIGNMENTS.ENEMY
	
	entity_manager.meele_components[id] = meele_data
	entity_manager.render_components[id] = render_data
	entity_manager.transform_components[id] = transform_data
	entity_manager.health_components[id] = health_data
	entity_manager.countdown_components[id] = countdown_data
	entity_manager.gold_value_components[id] = goldvalue_data
	entity_manager.alignment_components[id] = alignment_data
	
	entity_manager.active_entities.append(id)
	entity_manager.is_an_enemy[id] = true
	
	entity_manager.next_entity_id += 1
	
	return id
	
func create_overlay_effect():
	var id = SceneInstances.entity_manager.next_entity_id
	var entity_manager = SceneInstances.entity_manager
	
	var render_data = RenderingData.new()
	render_data.texture = Cache.textures_dict[Enums.ENTITY_TYPES.CELL_HOVER_OVERLAY]
	
	entity_manager.transform_components[id] = TransformData.new()
	entity_manager.render_components[id] = render_data
	
	entity_manager.next_entity_id += 1
	entity_manager.cell_overlay_id = id
	return id
	
func create_tower(type: Enums.ENTITY_TYPES, pos: Vector2i):
	var id = SceneInstances.entity_manager.next_entity_id
	var entity_manager: EntityManager = SceneInstances.entity_manager
	
	# Define The Componentes it contains
	var transform_data = TransformData.new()
	var render_data = RenderingData.new()
	var countdown_data = CountDownData.new()
	var projectile_data = Stats.projectile_weapon_data[type].clone()
	var health_data = Stats.health_data[type].clone()
	var grid_footprint_data = GridFootprintData.new()
	var alignment_data = AlignmentData.new()
	
	# Update their values
	render_data.texture = Cache.textures_dict[type]
	countdown_data.wait_time = 1 / projectile_data.fire_rate
	countdown_data.action = Enums.COUNTDOWN_ACTIONS.SHOOT
	transform_data.position = pos
	grid_footprint_data.grid_size = Vector2i(Constants.TILE_SIZE, Constants.TILE_SIZE)
	
	# Store them
	entity_manager.projectile_weopon_components[id] = projectile_data
	entity_manager.render_components[id] = render_data
	entity_manager.transform_components[id] = transform_data
	entity_manager.health_components[id] = health_data
	entity_manager.countdown_components[id] = countdown_data
	entity_manager.grid_footprint_components[id] = grid_footprint_data
	entity_manager.alignment_components[id] = alignment_data
	
	entity_manager.is_a_tower[id] = true
	entity_manager.base_tower_id = id
	
	entity_manager.active_entities.append(id)
	SceneInstances.entity_manager.add_entity_to_a_chunk(pos, id)
	
	# Return id - Best Practice
	entity_manager.next_entity_id += 1
	
	return id
	
func create_base(pos: Vector2i):
	var id = SceneInstances.entity_manager.next_entity_id
	var entity_manager: EntityManager = SceneInstances.entity_manager
	
	# Define The Componentes it contains
	var transform_data = TransformData.new()
	var render_data = RenderingData.new()
	var grid_footprint_data = GridFootprintData.new()
	var health_data = Stats.health_data[Enums.ENTITY_TYPES.BASE].clone()
	var alignment_data = AlignmentData.new()
	
	render_data.texture = Cache.textures_dict[Enums.ENTITY_TYPES.BASE]
	transform_data.position = pos
	grid_footprint_data.grid_size = Vector2i(Constants.TILE_SIZE, Constants.TILE_SIZE) * 2
	
	# Store them
	entity_manager.render_components[id] = render_data
	entity_manager.transform_components[id] = transform_data
	entity_manager.health_components[id] = health_data
	entity_manager.bank_data = BankData.new()
	entity_manager.is_a_tower[id] = true
	entity_manager.grid_footprint_components[id] = grid_footprint_data
	entity_manager.alignment_components[id] = alignment_data
	
	entity_manager.active_entities.append(id)
	SceneInstances.entity_manager.add_entity_to_a_chunk(pos, id)
	
	# Return id - Best Practice
	entity_manager.next_entity_id += 1
	
	return id
	
func spawn_bullet(pos: Vector2, target: Vector2, damage: float, target_id: int, speed: float):
	var entity_manager = SceneInstances.entity_manager
	
	# Fetch Bullet from inactive list or create new data
	var bullet_id = entity_manager.inactive_bullet_entities.pop_back()
	
	var transformData: TransformData
	var renderingData: RenderingData
	var meeleData: MeeleData
	var velocityData: VelocityData
	var homingData: HomingData
	
	if bullet_id != null: 
		transformData = entity_manager.inactive_bullet_transform_components[bullet_id]
		renderingData = entity_manager.inactive_bullet_render_components[bullet_id]
		meeleData = entity_manager.inactive_bullet_meele_components [bullet_id]
		velocityData = entity_manager.inactive_bullet_velocity_components[bullet_id]
		homingData = entity_manager.inactive_bullet_homing_components[bullet_id]
	else:
		bullet_id = SceneInstances.entity_manager.next_entity_id
		transformData = TransformData.new()
		renderingData = RenderingData.new()
		meeleData = MeeleData.new()
		velocityData = VelocityData.new()
		homingData = HomingData.new()
		
		SceneInstances.entity_manager.next_entity_id += 1
	
	# Transfer them to the main dict
	entity_manager.active_entities.append(bullet_id)
	SceneInstances.entity_manager.add_entity_to_a_chunk(pos, bullet_id)
	
	entity_manager.is_a_bullet[bullet_id] = true
	entity_manager.transform_components[bullet_id] = transformData
	entity_manager.render_components[bullet_id] = renderingData
	entity_manager.meele_components[bullet_id] = meeleData
	entity_manager.velocity_components[bullet_id] = velocityData
	entity_manager.homing_components[bullet_id] = homingData
	
	# Delete them
	entity_manager.inactive_bullet_entities.erase(bullet_id)
	entity_manager.inactive_bullet_transform_components.erase(bullet_id)
	entity_manager.inactive_bullet_render_components.erase(bullet_id)
	entity_manager.inactive_bullet_meele_components.erase(bullet_id)
	entity_manager.inactive_bullet_velocity_components.erase(bullet_id)
	entity_manager.inactive_bullet_homing_components.erase(bullet_id)
	
	# Modify the data
	transformData.position = pos
	velocityData.target = target
	velocityData.speed = speed
	meeleData.damage = damage
	meeleData.target_id = target_id
	homingData.target_id = target_id
	renderingData.texture = Cache.textures_dict[Enums.ENTITY_TYPES.BULLET]
	
func despawn_bullet(bullet_id: int):
	var entity_manager = SceneInstances.entity_manager
	
	var transformData = entity_manager.transform_components[bullet_id]
	var renderingData = entity_manager.render_components[bullet_id]
	var meeleData = entity_manager.meele_components[bullet_id]
	var velocityData = entity_manager.velocity_components.get(bullet_id)
	var homingData = entity_manager.homing_components.get(bullet_id)
	
	# Transfer them to the inactive dict
	entity_manager.inactive_bullet_entities.append(bullet_id)
	entity_manager.inactive_bullet_transform_components[bullet_id] = transformData
	entity_manager.inactive_bullet_render_components[bullet_id] = renderingData
	entity_manager.inactive_bullet_meele_components[bullet_id] = meeleData
	entity_manager.inactive_bullet_homing_components[bullet_id] = homingData if homingData else HomingData.new()
	entity_manager.inactive_bullet_velocity_components[bullet_id] = velocityData if velocityData else VelocityData.new()
	
	# Remove them from the main list
	entity_manager.active_entities.erase(bullet_id)
	entity_manager.is_a_bullet.erase(bullet_id)
	entity_manager.transform_components.erase(bullet_id)
	entity_manager.render_components.erase(bullet_id)
	entity_manager.meele_components.erase(bullet_id)
	entity_manager.velocity_components.erase(bullet_id)
	entity_manager.homing_components.erase(bullet_id)
	
	SceneInstances.entity_manager.rmeove_entity_from_chunk(transformData.position, bullet_id)
	
func create_bullet_pool():
	var number_of_bullets = 500
	var start_id = SceneInstances.entity_manager.next_entity_id
	var entity_manager: EntityManager = SceneInstances.entity_manager
	
	for id in number_of_bullets:
		var current_bullet_id = start_id + id
		
		# Create datas
		var transformData: TransformData = TransformData.new()
		var renderingData: RenderingData = RenderingData.new()
		var meeleData: MeeleData = MeeleData.new()
		var velocityData: VelocityData = VelocityData.new()
		var homingData: HomingData = HomingData.new()
		
		# Add them to the inactive pool
		entity_manager.inactive_bullet_entities.append(current_bullet_id)
		entity_manager.inactive_bullet_meele_components[current_bullet_id] = meeleData
		entity_manager.inactive_bullet_render_components[current_bullet_id] = renderingData
		entity_manager.inactive_bullet_transform_components[current_bullet_id] = transformData
		entity_manager.inactive_bullet_velocity_components[current_bullet_id] = velocityData
		entity_manager.inactive_bullet_homing_components[current_bullet_id] = homingData
		
	entity_manager.next_entity_id += number_of_bullets
