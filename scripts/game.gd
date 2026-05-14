extends Control

@onready var upgrade_list: VBoxContainer  = $ScrollContainer/VBoxContainer
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var upgrades_menu_button: Button = $UpgradesMenuButton
@onready var passive_income_label: Label = $StatsPanel/PassiveIncomeLabel
@onready var amounts_per_click_label: Label = $StatsPanel/AmountsPerClickLabel
@onready var tooltip_panel: ColorRect = $TooltipPanel
@onready var tooltip_label: Label = $TooltipPanel/TooltipLabel
@onready var stats_panel: ColorRect = $StatsPanel

var save_timer: float = 0.0
var spawned_upgrades: Array = []   # hangi upgrade'in kartı eklendi

const SAVE_PATH = "user://userdata.save"
const upgrade_ui_scene = preload("res://scenes/upgrade_ui.tscn")

func _ready() -> void:
	# önce bağlantıları kur
	Global.points_changed.connect(_on_points_changed)
	Global.passive_income_changed.connect(_on_passive_income_changed)
	Global.amount_per_click_changed.connect(_on_amounts_per_click_changed)
	
	# sonra yükle (reset_effects artık dinleyici bulur)
	load_data()
	
	scroll_container.visible = false
	upgrades_menu_button.visible = false
	stats_panel.visible = false
	Global.emit_signal("points_changed", Global.points)
	Global.show_tooltip.connect(_on_show_tooltip)
	Global.hide_tooltip.connect(_on_hide_tooltip)

func _process(delta: float) -> void:
	save_timer += delta
	if save_timer >= 5.0:
		save_data()
		save_timer = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Global.points += Global.amount_per_click
			Global.emit_signal("points_changed", Global.points)

func _on_points_changed(new_points: float) -> void:
	for upgrade in Global.upgrades:
		if upgrade in spawned_upgrades:
			continue
		# base_cost: ilk açılış koşulu (level 0 fiyatı)
		# level > 0: daha önce alınmışsa her zaman göster
		if new_points >= upgrade.base_cost or upgrade.level > 0:
			var card = upgrade_ui_scene.instantiate()
			upgrade_list.add_child(card)
			card.setup(upgrade)
			spawned_upgrades.append(upgrade)
			if not upgrades_menu_button.visible:
				upgrades_menu_button.visible = true
				toggle_upgrades()
				
func _on_passive_income_changed(new_value: float) -> void:
	passive_income_label.text = "%.1f p/sec" % new_value
	
func _on_amounts_per_click_changed(new_value: float) -> void:
	amounts_per_click_label.text = "%.1f click power" % new_value
	
func _on_show_tooltip(upgrade: Upgrade, pos: Vector2) -> void:
	tooltip_panel.position = Vector2(pos.x - tooltip_panel.size.x - 10, pos.y)
	tooltip_panel.visible = true
	tooltip_label.text = upgrade.name

func _on_hide_tooltip() -> void:
	tooltip_panel.visible = false
func toggle_upgrades() -> void:
	scroll_container.visible = !scroll_container.visible

func save_data() -> void:
	var levels: Array = []
	for u in Global.upgrades:
		levels.append(u.level)
	var data = {"points": Global.points, "levels": levels}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = file.get_var()
	file.close()
	if typeof(data) != TYPE_DICTIONARY:
		save_data()
		return
	Global.points = data.get("points", 0)
	var levels: Array = data.get("levels", [])
	for i in min(levels.size(), Global.upgrades.size()):
		Global.upgrades[i].level = levels[i]
	Global.reset_effects()


func _on_upgrades_menu_button_pressed() -> void:
	toggle_upgrades()

func _on_reset_progression_button_pressed() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

	Global.points = 0
	
	for upgrade in Global.upgrades:
		upgrade.level = 0
	
	Global.reset_effects()
	
	get_tree().reload_current_scene()

func _on_stats_hover_mouse_entered() -> void:
	stats_panel.visible= true

func _on_stats_hover_mouse_exited() -> void:
	stats_panel.visible= false
