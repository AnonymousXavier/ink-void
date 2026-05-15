extends Node

func create_player(spawn_pos: Vector2) -> int:
	var entity_manager = SceneInstances.entity_manager
	var id = entity_manager.next_entity_id
	
	var transform_data = TransformData.new()
	var render_data = RenderingData.new()
	var velocity_data = VelocityData.new()    
	var health_data = HealthData.new()
	var alignment_data = AlignmentData.new()
	var countdown_data = CountDownData.new()
	var parry_data = ParryData.new()
	var dash_data = DashData.new()
	
	transform_data.position = spawn_pos
	render_data.texture = Cache.textures_dict[Enums.ENTITY_TYPES.PLAYER]
	health_data.health = 1
	health_data.maxHealth = 1
	alignment_data.alignment = Enums.ALIGNMENTS.PLAYER
	velocity_data.speed = 400.0 # High base speed for action gameplay
	
	entity_manager.render_components[id] = render_data
	entity_manager.transform_components[id] = transform_data
	entity_manager.health_components[id] = health_data
	entity_manager.countdown_components[id] = countdown_data
	entity_manager.alignment_components[id] = alignment_data
	entity_manager.parry_components[id] = parry_data
	entity_manager.velocity_components[id] = velocity_data
	entity_manager.dash_components[id] = dash_data
	
	entity_manager.active_entities.append(id)
	entity_manager.player_id = id
	entity_manager.player_input_data = PlayerInputData.new()
	
	SceneInstances.entity_manager.next_entity_id += 1
	
	return id

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
	var velocity_data = VelocityData.new()
	var stalker_data = StalkerData.new()
	var projectile_weapon_data = Stats.projectile_weapon_datas[type]
	
	velocity_data.speed = 100.0
	render_data.texture = Cache.textures_dict[type]
	render_data.frozen_texture = Cache.frozen_textures_dict[Enums.ENTITY_TYPES.NORMAL_ENEMY]
	countdown_data.wait_time = 1 / meele_data.fire_rate
	countdown_data.action = Enums.COUNTDOWN_ACTIONS.ATTACK
	transform_data.position = pos
	alignment_data.alignment = Enums.ALIGNMENTS.ENEMY
	stalker_data.target_id = SceneInstances.entity_manager.player_id
	
	entity_manager.meele_components[id] = meele_data
	entity_manager.render_components[id] = render_data
	entity_manager.transform_components[id] = transform_data
	entity_manager.health_components[id] = health_data
	entity_manager.countdown_components[id] = countdown_data
	entity_manager.gold_value_components[id] = goldvalue_data
	entity_manager.alignment_components[id] = alignment_data
	entity_manager.velocity_components[id] = velocity_data
	entity_manager.stalker_components[id] = stalker_data
	entity_manager.projectile_weopon_components[id] = projectile_weapon_data
	
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
	
func spawn_bullet(pos: Vector2, direction: Vector2, damage: float, target_id: int, speed: float):
	var entity_manager: EntityManager = SceneInstances.entity_manager
	
	# Fetch Bullet from inactive list or create new data
	var bullet_id = entity_manager.inactive_bullet_entities.pop_back()
	
	var transformData: TransformData
	var renderingData: RenderingData
	var meeleData: MeeleData
	var velocityData: VelocityData
	# var homingData: HomingData
	var alignment_dta: AlignmentData
	
	if bullet_id != null:
		transformData = entity_manager.inactive_bullet_transform_components[bullet_id]
		renderingData = entity_manager.inactive_bullet_render_components[bullet_id]
		meeleData = entity_manager.inactive_bullet_meele_components [bullet_id]
		velocityData = entity_manager.inactive_bullet_velocity_components[bullet_id]
		# homingData = entity_manager.inactive_bullet_homing_components[bullet_id]
		alignment_dta = entity_manager.inactive_bullet_alignment_components[bullet_id]
	else:
		bullet_id = SceneInstances.entity_manager.next_entity_id
		transformData = TransformData.new()
		renderingData = RenderingData.new()
		meeleData = MeeleData.new()
		velocityData = VelocityData.new()
		# homingData = HomingData.new()
		alignment_dta = AlignmentData.new()
		
		SceneInstances.entity_manager.next_entity_id += 1
	
	# Transfer them to the main dict
	entity_manager.active_entities.append(bullet_id)
	SceneInstances.entity_manager.add_entity_to_a_chunk(pos, bullet_id)
	
	# Do the exact same thing inside create_enemy() using NORMAL_ENEMY!
	
	entity_manager.is_a_bullet[bullet_id] = true
	entity_manager.transform_components[bullet_id] = transformData
	entity_manager.render_components[bullet_id] = renderingData
	entity_manager.meele_components[bullet_id] = meeleData
	entity_manager.velocity_components[bullet_id] = velocityData
	# entity_manager.homing_components[bullet_id] = homingData
	entity_manager.alignment_components[bullet_id] = alignment_dta
	
	renderingData.texture = Cache.textures_dict[Enums.ENTITY_TYPES.BULLET]
	renderingData.frozen_texture = Cache.frozen_textures_dict[Enums.ENTITY_TYPES.BULLET]
	
	# Delete them
	entity_manager.inactive_bullet_transform_components.erase(bullet_id)
	entity_manager.inactive_bullet_render_components.erase(bullet_id)
	entity_manager.inactive_bullet_meele_components.erase(bullet_id)
	entity_manager.inactive_bullet_velocity_components.erase(bullet_id)
	entity_manager.inactive_bullet_alignment_components.erase(bullet_id)
	# entity_manager.inactive_bullet_homing_components.erase(bullet_id)
	
	# Modify the data
	transformData.position = pos
	velocityData.direction = direction
	velocityData.speed = speed
	meeleData.damage = damage
	meeleData.target_id = target_id
	alignment_dta.alignment = Enums.ALIGNMENTS.PLAYER
	# homingData.target_id = target_id
	renderingData.texture = Cache.textures_dict[Enums.ENTITY_TYPES.BULLET]
	
func despawn_bullet(bullet_id: int):
	var entity_manager = SceneInstances.entity_manager
	
	var transformData = entity_manager.transform_components[bullet_id]
	var renderingData = entity_manager.render_components[bullet_id]
	var meeleData = entity_manager.meele_components[bullet_id]
	var velocityData = entity_manager.velocity_components.get(bullet_id)
	var homingData = entity_manager.homing_components.get(bullet_id)
	var alignmentData = entity_manager.alignment_components.get(bullet_id)
	
	# Transfer them to the inactive dict
	entity_manager.inactive_bullet_entities.append(bullet_id)
	entity_manager.inactive_bullet_transform_components[bullet_id] = transformData
	entity_manager.inactive_bullet_render_components[bullet_id] = renderingData
	entity_manager.inactive_bullet_alignment_components[bullet_id] = alignmentData
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
	entity_manager.alignment_components.erase(bullet_id)
	
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
		var alignmentData: AlignmentData = AlignmentData.new()
		
		alignmentData.alignment = Enums.ALIGNMENTS.PLAYER
		
		# Add them to the inactive pool
		entity_manager.inactive_bullet_entities.append(current_bullet_id)
		entity_manager.inactive_bullet_meele_components[current_bullet_id] = meeleData
		entity_manager.inactive_bullet_render_components[current_bullet_id] = renderingData
		entity_manager.inactive_bullet_transform_components[current_bullet_id] = transformData
		entity_manager.inactive_bullet_velocity_components[current_bullet_id] = velocityData
		entity_manager.inactive_bullet_alignment_components[current_bullet_id] = alignmentData
		
	entity_manager.next_entity_id += number_of_bullets
