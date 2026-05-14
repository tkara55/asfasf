extends VBoxContainer
@onready var label: Label = $Label

func _ready() -> void:
	Global.points_changed.connect(_on_points_changed)
	
func _on_points_changed(new_points: int):
	label.text = str(new_points)+ "$"  # kendi node isminle
