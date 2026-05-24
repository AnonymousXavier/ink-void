extends Node
class_name BoundarySystem

var safe_zone: Rect2

func _init(zone_rect: Rect2) -> void:
	safe_zone = zone_rect

func update() -> void:
	var em = SceneInstances.entity_manager
	var player_id = em.player_id
	
	if player_id == -1: return
	
	var p_transform = em.transform_components.get(player_id)
	if p_transform:
		# Clamp the player's X and Y strictly within the safe zone
		p_transform.position.x = clamp(p_transform.position.x, safe_zone.position.x, safe_zone.position.x + safe_zone.size.x)
		p_transform.position.y = clamp(p_transform.position.y, safe_zone.position.y, safe_zone.position.y + safe_zone.size.y)
