extends VBoxContainer

const MAIN = preload("res://Scenes/main.tscn")
@onready var click: AudioStreamPlayer3D = $NewGameButton/Click
@onready var CONTROLS = load("res://scenes/input_settings.tscn")


func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN)
	
	


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_new_game_button_mouse_entered() -> void:
	click.play()


func _on_load_button_mouse_entered() -> void:
	click.play()


func _on_quit_button_mouse_entered() -> void:
	click.play()


func _on_load_button_pressed() -> void:
	print("Going to controls menu")
	
	$"../CanvasLayer/InputSettings".visible = true
