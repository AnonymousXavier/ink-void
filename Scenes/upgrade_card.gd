extends Button
class_name UpgradeCard

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var desc_label: Label = $VBoxContainer/DescLabel

var upgrade_id: String

# The UI Manager will call this to inject the specific card's data
func setup(id: String, data: Dictionary) -> void:
	upgrade_id = id
	title_label.text = data["title"]
	desc_label.text = data["desc"]
