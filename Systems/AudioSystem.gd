extends Node
class_name AudioSystem

var sfx_pool: Array[AudioStreamPlayer] = []
var pool_size: int = 16
var current_pool_index: int = 0

var bgm_player: AudioStreamPlayer
var current_bgm_key: String = ""

# Accept the track name when the system is created!
func _init(bgm_to_play: String = "") -> void:
	current_bgm_key = bgm_to_play
	SceneInstances.audio_system = self
	
	# 1. SETUP BGM PLAYER
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Master" 
	add_child(bgm_player)
	
	# 2. SETUP SFX POOL
	for i in range(pool_size):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		sfx_pool.append(player)
		add_child(player)

func _ready() -> void:
	# Play the specific track passed during _init
	if current_bgm_key != "" and Cache.audio_dict.has(current_bgm_key):
		bgm_player.stream = Cache.audio_dict[current_bgm_key]
		bgm_player.play()

func update(_delta: float) -> void:
	# --- HITSTOP PITCH MODULATION ---
	var current_time = SceneInstances.time_scale
	var target_pitch = max(0.1, current_time) 
	
	for player in sfx_pool:
		if player.playing:
			player.pitch_scale = target_pitch
			
	bgm_player.pitch_scale = target_pitch

	# --- EVENT LISTENER ---
	for event in SceneInstances.events_manager.events:
		match event.type:
			Enums.EVENT_TYPES.DAMAGE_ATTEMPT:
				play_sound("enemy_death")
				
			Enums.EVENT_TYPES.SOUL_COLLECTED:
				play_sound("soul_pop")
				
			Enums.EVENT_TYPES.HIT_STOP:
				play_sound("parry")
				play_sound("slash") # Layer the slash with the parry impact!

func play_sound(sound_name: String) -> void:
	if not Cache.audio_dict.has(sound_name): print("Sound doesnt exist"); return
	
	var player = sfx_pool[current_pool_index]
	player.stream = Cache.audio_dict[sound_name]
	
	var safe_time = max(0.1, SceneInstances.time_scale)
	player.pitch_scale = safe_time * randf_range(0.85, 1.15)
	player.play()
	
	current_pool_index = (current_pool_index + 1) % pool_size
