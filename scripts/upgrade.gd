class_name Upgrade
extends Resource

@export var name: String
@export var desc: String
@export var base_cost: int
@export var base_value: int
@export var effect: String
@export var level: int = 0

func setup(p_name: String, p_cost: int, p_effect: String, p_value: int) -> Upgrade:
	name = p_name
	base_cost = p_cost
	effect = p_effect
	base_value = p_value
	return self

func get_current_cost() -> int:
	return int(base_cost + level)

func try_buy() -> bool:
	var cost = get_current_cost()
	if Global.points < cost:
		return false
	Global.points -= cost
	level += 1
	apply_effect()
	return true

func apply_effect() -> void:
	if effect == "click_damage":
		Global.amount_per_click += base_value
		Global.emit_signal("amount_per_click_changed", Global.amount_per_click)
	elif effect == "passive":
		Global.passive_income += base_value
		Global.emit_signal("passive_income_changed", Global.passive_income)
