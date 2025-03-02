extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	animation_player.play("idle")
	
func _on_yes_pressed() -> void:
	get_tree().change_scene_to_file("res://splashscreen_w_1.tscn")

func _on_no_pressed() -> void:
	get_tree().change_scene_to_file("res://startscreen.tscn")
