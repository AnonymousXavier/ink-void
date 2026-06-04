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
	var shield_data = ShieldData.new()

	shield_data.is_active = false
	
	transform_data.position = spawn_pos
	render_data.texture = Cache.textures_dict[Enums.ENTITY_TYPES.PLAYER]
	health_data.health = 1
	health_data.maxHealth = 1
	alignment_data.alignment = Enums.ALIGNMENTS.PLAYER
	velocity_data.speed = 400.0
	
	entity_manager.render_components[id] = render_data
	entity_manager.transform_components[id] = transform_data
	entity_manager.health_components[id] = health_data
	entity_manager.countdown_components[id] = countdown_data
	entity_manager.alignment_components[id] = alignment_data
	entity_manager.parry_components[id] = parry_data
	entity_manager.velocity_components[id] = velocity_data
	entity_manager.dash_components[id] = dash_data
	entity_manager.shield_components[id] = shield_data
	
	# META-PERK INJECTION
	# We read the active loadout and safely mutate the baseline stats
	for perk_id in MetaEconomy.active_perks:
		if Constants.PERKS.has(perk_id):
			var p_data = Constants.PERKS[perk_id]
			match p_data["stat_id"]:
				"max_hp":
					health_data.maxHealth += p_data["value"]
					health_data.health = health_data.maxHealth
				"move_speed":
					velocity_data.speed += p_data["value"]
	
	entity_manager.active_entities.append(id)
	entity_manager.player_id = id
	entity_manager.player_input_data = PlayerInputData.new()
	
	SceneInstances.entity_manager.next_entity_id += 1
	
	return id

func create_enemy(type: Enums.ENTITY_TYPES, pos: Vector2i) -> int:
	var id = SceneInstances.entity_manager.next_entity_id
	var entity_manager: EntityManager = SceneInstances.entity_manager
	
	# Fetch raw numerical stats from our profile registry
	var profile = Stats.ENEMY_PROFILES[type]
	
	var transform_data = TransformData.new()
	var render_data = RenderingData.new()
	var countdown_data = CountDownData.new()
	var goldvalue_data = GoldValueData.new()
	var alignment_data = AlignmentData.new()
	var velocity_data = VelocityData.new()
	var stalker_data = StalkerData.new()
	var ai_data = AIData.new()
	
	# Dynamic safety checks for component arrays
	var meele_data = Stats.meele_data[type].duplicate() if type in Stats.meele_data else MeeleData.new()
	var health_data = Stats.health_data[type].duplicate() if type in Stats.health_data else HealthData.new()
	var projectile_weapon_data = Stats.projectile_weapon_datas[type].duplicate(true) if type in Stats.projectile_weapon_datas else ProjectileWeaponData.new()
	
	transform_data.position = pos
	velocity_data.speed = profile["speed"]
	alignment_data.alignment = Enums.ALIGNMENTS.ENEMY
	stalker_data.target_id = entity_manager.player_id
	
	# Map values from the profile dictionary directly to components
	health_data.maxHealth = profile["health"]
	health_data.health = profile["health"]
	meele_data.damage = profile["damage"]
	if "mass" in profile:
		meele_data.mass = profile["mass"] 
	if "gold" in profile:
		goldvalue_data.gold = profile["gold"]
	
	# Fetch the textures instantly without utilizing 'await' hooks
	render_data.texture = Cache.textures_dict[type]
	render_data.modulate = Cache.base_colors[type]
	
	# Setup weapon fire cooldown loops based on archetype configs
	var fire_rate = profile["fire_rate"] if "fire_rate" in profile else 1.0
	countdown_data.wait_time = 1.0 / fire_rate
	countdown_data.action = Enums.COUNTDOWN_ACTIONS.ATTACK
	
	# Bind instances back to the central entity arrays
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
	entity_manager.ai_components[id] = ai_data
	
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
	
func create_bullet_pool():
	var number_of_bullets = 500
	var start_id = SceneInstances.entity_manager.next_entity_id
	var entity_manager: EntityManager = SceneInstances.entity_manager
	
	for id in range(number_of_bullets):
		var current_bullet_id = start_id + id
		
		# Store them ONLY in the INACTIVE dictionaries so systems ignore them!
		entity_manager.inactive_bullet_entities.append(current_bullet_id)
		entity_manager.inactive_bullet_transform_components[current_bullet_id] = TransformData.new()
		entity_manager.inactive_bullet_render_components[current_bullet_id] = RenderingData.new()
		entity_manager.inactive_bullet_meele_components[current_bullet_id] = MeeleData.new()
		entity_manager.inactive_bullet_velocity_components[current_bullet_id] = VelocityData.new()
		
		var alignmentData = AlignmentData.new()
		alignmentData.alignment = Enums.ALIGNMENTS.PLAYER
		entity_manager.inactive_bullet_alignment_components[current_bullet_id] = alignmentData
		
	entity_manager.next_entity_id += number_of_bullets

func spawn_bullet(pos: Vector2, direction: Vector2, damage: float, target_id: int, speed: float, bullet_color: Color = Color("ff0033")):
	var entity_manager: EntityManager = SceneInstances.entity_manager
	
	var bullet_id = entity_manager.inactive_bullet_entities.pop_back()
	
	var transformData: TransformData
	var renderingData: RenderingData
	var meeleData: MeeleData
	var velocityData: VelocityData
	var alignment_dta: AlignmentData
	
	if bullet_id != null:
		# Pull the memory references safely out of the dormant pool
		transformData = entity_manager.inactive_bullet_transform_components[bullet_id]
		renderingData = entity_manager.inactive_bullet_render_components[bullet_id]
		meeleData = entity_manager.inactive_bullet_meele_components[bullet_id]
		velocityData = entity_manager.inactive_bullet_velocity_components[bullet_id]
		alignment_dta = entity_manager.inactive_bullet_alignment_components[bullet_id]
		
		# Erase them from the inactive list
		entity_manager.inactive_bullet_transform_components.erase(bullet_id)
		entity_manager.inactive_bullet_render_components.erase(bullet_id)
		entity_manager.inactive_bullet_meele_components.erase(bullet_id)
		entity_manager.inactive_bullet_velocity_components.erase(bullet_id)
		entity_manager.inactive_bullet_alignment_components.erase(bullet_id)
	else:
		# Emergency fallback if pool is empty
		bullet_id = entity_manager.next_entity_id
		entity_manager.next_entity_id += 1
		transformData = TransformData.new()
		renderingData = RenderingData.new()
		meeleData = MeeleData.new()
		velocityData = VelocityData.new()
		alignment_dta = AlignmentData.new()
	
	# Push to active arrays
	entity_manager.active_entities.append(bullet_id)
	entity_manager.is_a_bullet[bullet_id] = true
	entity_manager.add_entity_to_a_chunk(pos, bullet_id)
	
	entity_manager.transform_components[bullet_id] = transformData
	entity_manager.render_components[bullet_id] = renderingData
	entity_manager.meele_components[bullet_id] = meeleData
	entity_manager.velocity_components[bullet_id] = velocityData
	entity_manager.alignment_components[bullet_id] = alignment_dta
	
	# Modify the data
	transformData.position = pos
	velocityData.direction = direction
	velocityData.speed = speed
	meeleData.damage = damage
	meeleData.target_id = target_id
	alignment_dta.alignment = Enums.ALIGNMENTS.PLAYER
	renderingData.texture = Cache.textures_dict[Enums.ENTITY_TYPES.BULLET]
	renderingData.modulate = bullet_color

func despawn_bullet(bullet_id: int):
	var entity_manager = SceneInstances.entity_manager
	
	var transformData = entity_manager.transform_components[bullet_id]
	var renderingData = entity_manager.render_components[bullet_id]
	var meeleData = entity_manager.meele_components[bullet_id]
	var velocityData = entity_manager.velocity_components[bullet_id]
	var alignmentData = entity_manager.alignment_components[bullet_id]
	
	entity_manager.rmeove_entity_from_chunk(transformData.position, bullet_id)
	
	# Transfer the memory references BACK to the inactive dicts
	entity_manager.inactive_bullet_entities.append(bullet_id)
	entity_manager.inactive_bullet_transform_components[bullet_id] = transformData
	entity_manager.inactive_bullet_render_components[bullet_id] = renderingData
	entity_manager.inactive_bullet_alignment_components[bullet_id] = alignmentData
	entity_manager.inactive_bullet_meele_components[bullet_id] = meeleData
	entity_manager.inactive_bullet_velocity_components[bullet_id] = velocityData
	
	# ERASE them from the main list so systems stop processing them!
	entity_manager.active_entities.erase(bullet_id)
	entity_manager.is_a_bullet.erase(bullet_id)
	entity_manager.transform_components.erase(bullet_id)
	entity_manager.render_components.erase(bullet_id)
	entity_manager.meele_components.erase(bullet_id)
	entity_manager.velocity_components.erase(bullet_id)
	entity_manager.alignment_components.erase(bullet_id)
