extends VBoxContainer

const MAIN = preload("res://Scenes/main.tscn")



func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
