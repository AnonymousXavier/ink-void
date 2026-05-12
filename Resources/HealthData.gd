extends Node
class_name HealthData

@export var health: float
@export var maxHealth: float

func clone():
	var health_data = HealthData.new()
	health_data.health = health
	health_data.maxHealth = maxHealth
	
	return health_data
