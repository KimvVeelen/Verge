extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	animation_player.play("idle")
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://game_over.tscn")
