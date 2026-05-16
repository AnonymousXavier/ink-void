extends CanvasLayer
class_name UIManager

@onready var timer_label: Label = $Control/TimerLabel

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if not Cache.is_ready or not SceneInstances.wave_system: return
	
	var time_left = SceneInstances.wave_system.time_left
	
	# Format the float into a clean MM:SS string
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	
	timer_label.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
	
	# Optional: Make it pulse red in the last 5 seconds!
	if time_left <= 5.0 and SceneInstances.wave_system.is_wave_active:
		timer_label.modulate = Color.RED if int(time_left * 10) % 2 == 0 else Color.WHITE
	else:
		timer_label.modulate = Color.WHITE
