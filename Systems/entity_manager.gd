extends Node
class_name EntityManager

var next_entity_id: int = 1
var active_entities: Array[int] = [] # Just a list of living IDs
var cluster_hash: Dictionary[Vector2i, Array] = {} # Entities are stored in chunks for quick lookups

# The Components
var transform_components: Dictionary[int, TransformData] = {} # Position, Rotation
var render_components: Dictionary[int, RenderingData] = {} # What it looks like
var meele_components: Dictionary[int, MeeleData] = {}
var velocity_components: Dictionary[int, VelocityData] = {}
var health_components: Dictionary[int, HealthData] = {}
var projectile_weopon_components: Dictionary[int, ProjectileWeaponData]= {}
var countdown_components: Dictionary[int, CountDownData] = {}
var gold_value_components: Dictionary[int, GoldValueData] = {}
var homing_components: Dictionary[int, HomingData] = {}
var grid_footprint_components: Dictionary[int, GridFootprintData] = {}
var alignment_components: Dictionary[int, AlignmentData] = {}

# Tags
var is_an_enemy: Dictionary[int, bool] = {}
var is_a_bullet: Dictionary[int, bool] = {}
var player_id: int
var cell_overlay_id: int
var bank_data: BankData

# Inactive Components - For memeory management
var inactive_bullet_entities: Array[int] = [] 
var inactive_bullet_transform_components: Dictionary[int, TransformData] = {} 
var inactive_bullet_render_components: Dictionary[int, RenderingData] = {}
var inactive_bullet_meele_components: Dictionary[int, MeeleData] = {} 
var inactive_bullet_velocity_components: Dictionary[int, VelocityData] = {} 
var inactive_bullet_homing_components: Dictionary[int, HomingData] = {} 


func add_entity_to_a_chunk(pos: Vector2i, id: int):
	var chunk_id = Vector2i(pos / Constants.CHUNK_SIZE)
	if not cluster_hash.has(chunk_id):
		cluster_hash[chunk_id] = []
		
	cluster_hash[chunk_id].append(id)
	
func rmeove_entity_from_chunk(pos: Vector2i, id: int):
	var chunk_id = Vector2i(pos / Constants.CHUNK_SIZE)
	cluster_hash[chunk_id].erase(id)

func update_chunk_map_for(prev_position: Vector2, entity_id: int):
	var entity_transform_data = transform_components[entity_id]
	
	# get approx chunk coord
	var chunk_id = Vector2i(entity_transform_data.position / Constants.CHUNK_SIZE)
	var old_chunk_id = Vector2i(prev_position / Constants.CHUNK_SIZE)
	
	if chunk_id not in cluster_hash:
		cluster_hash[chunk_id] = []
		
	if cluster_hash.has(old_chunk_id):
		cluster_hash[old_chunk_id].erase(entity_id)
		
	cluster_hash[chunk_id].append(entity_id)
