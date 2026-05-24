extends CanvasLayer
class_name ReviveUI

@onready var overlay: ColorRect = $Overlay
@onready var container: Control = $CenterContainer
@onready var cost_label: Label = $CenterContainer/VBoxContainer/CostLabel
@onready var pay_button: Button = $CenterContainer/VBoxContainer/Spacer/HBoxContainer/PayButton
@onready var die_button: Button = $CenterContainer/VBoxContainer/Spacer/HBoxContainer/DieButton


func _ready() -> void:
	hide()
	pay_button.pressed.connect(_on_pay_pressed)
	die_button.pressed.connect(_on_die_pressed)

func _input(event: InputEvent) -> void:
	if not visible: return
	
	if event.is_action_pressed("parry"): 
		if not pay_button.disabled:
			_on_pay_pressed()
			get_viewport().set_input_as_handled()
			
	elif event.is_action_pressed("ui_cancel"): 
		_on_die_pressed()
		get_viewport().set_input_as_handled()

func display_ultimatum(cost: int, can_afford: bool) -> void:
	cost_label.text = "- " + str(cost) + " SOULS -"
	
	if can_afford:
		pay_button.disabled = false
		pay_button.modulate = Color.WHITE
		pay_button.text = "[ SPACE ] TRIBUTE"
	else:
		pay_button.disabled = true
		pay_button.modulate = Color.DARK_GRAY
		pay_button.text = "INSUFFICIENT SOULS"
		
	# Reset states before animating
	overlay.modulate.a = 0.0
	container.scale = Vector2(1.2, 1.2) # Start 20% larger
	container.modulate.a = 0.0
	show()
	
	var tween = create_tween().set_parallel(true)
	# Snap the dark background in almost instantly
	tween.tween_property(overlay, "modulate:a", 1.0, 0.1)
	
	# Slam the text down to normal size with an aggressive exponential curve
	tween.tween_property(container, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(container, "modulate:a", 1.0, 0.15)

func _on_pay_pressed() -> void:
	_animate_out_and_fire(Enums.EVENT_TYPES.REVIVE_CONFIRMED)

func _on_die_pressed() -> void:
	_animate_out_and_fire(Enums.EVENT_TYPES.REVIVE_REJECTED)

# A clean exit animation that fires the event exactly when the screen clears
func _animate_out_and_fire(event_type: Enums.EVENT_TYPES) -> void:
	var tween = create_tween().set_parallel(true)
	
	# Glitch-fade out quickly
	tween.tween_property(container, "scale", Vector2(1.1, 1.1), 0.15).set_trans(Tween.TRANS_SINE)
	
	# Fade the UI and the black background individually instead of trying to fade the CanvasLayer
	tween.tween_property(container, "modulate:a", 0.0, 0.15)
	tween.tween_property(overlay, "modulate:a", 0.0, 0.15)
	
	tween.finished.connect(func():
		hide()
		# We don't need to reset modulate here because your display_ultimatum() 
		# function already forces them to 0.0 before slamming them back to 1.0!
		SceneInstances.events_manager.add_event({"type": event_type})
	)
