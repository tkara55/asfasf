extends Node

signal points_changed(new_points: int)
signal passive_income_changed(new_value: float)
signal amount_per_click_changed(new_value: int)
signal show_tooltip(upgrade: Upgrade, position: Vector2)
signal hide_tooltip()

var points: float = 0
var amount_per_click: int = 1
var passive_income: float = 0
var upgrades_unlocked: bool = false

func _process(delta: float) -> void:
	if passive_income > 0:
		points += passive_income * delta
		emit_signal("points_changed", points)

var upgrades: Array[Upgrade] = [
	Upgrade.new().setup("Hız Kesmesi",  50,  "click_damage", 1),
	Upgrade.new().setup("Keskin Darbe", 100,  "click_damage", 2),
	Upgrade.new().setup("Kritik Vuruş", 500,  "click_damage", 5),
	Upgrade.new().setup("Pasif Gelir",  2000, "passive",      1),
	Upgrade.new().setup("Pasif Gelir",  2000, "passive",      1),
	Upgrade.new().setup("Pasif Gelir",  2000, "passive",      1),
	Upgrade.new().setup("Pasif Gelir",  2000, "passive",      1),
]

func reset_effects() -> void:
	amount_per_click = 1
	passive_income = 0
	for u in upgrades:
		for _i in u.level:
			u.apply_effect()
	emit_signal("passive_income_changed", passive_income)
	emit_signal("amount_per_click_changed", amount_per_click)
