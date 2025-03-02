extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	animation_player.play("idle")
	
func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://world_1.tscn")
