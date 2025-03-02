extends Node2D

func _on_startgame_button_down() -> void:
	get_tree().change_scene_to_file("res://splashscreen_w_1.tscn") 
	
# Replace with function body.
func _on_endgame_button_down() -> void:
	get_tree().quit() # Replace with function body.
