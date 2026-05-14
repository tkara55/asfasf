extends HBoxContainer

@onready var upgrade_button: Button = $VBoxContainer2/UpgradeButton
@onready var cost_label: Label      = $VBoxContainer2/UpgradeCostText
@onready var name_label: Label      = $VBoxContainer/UpgradeName
@onready var level_label: Label     = $VBoxContainer/LevelLabel

var upgrade: Upgrade

func setup(u: Upgrade) -> void:
	upgrade = u
	_refresh_ui()

func _refresh_ui() -> void:
	name_label.text  = upgrade.name
	cost_label.text  = str(upgrade.get_current_cost()) + "$"
	level_label.text = "Seviye: " + str(upgrade.level)

func _on_upgrade_button_pressed() -> void:
	if upgrade.try_buy():
		Global.emit_signal("points_changed", Global.points)
		_refresh_ui()

func _on_color_rect_mouse_entered() -> void:
	Global.emit_signal("show_tooltip", upgrade, global_position)

func _on_description_hover_mouse_exited() -> void:
	Global.emit_signal("hide_tooltip")
