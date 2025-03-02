extends Node
class_name HealthComponent

@export var start_health: int
signal Death

var current_health

func _ready() -> void:
	current_health = start_health

func take_damage(dmg: int): 
	current_health -= dmg
	
	if (current_health <= 0):
		Death.emit()
