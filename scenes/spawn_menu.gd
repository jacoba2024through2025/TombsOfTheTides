extends Node3D


@onready var camera_pivot: Node3D = $CameraPivot
@onready var main_menu_music: AudioStreamPlayer3D = $main_menu_music

var rotation_speed = 8


func _ready() -> void:
	main_menu_music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camera_pivot.rotation_degrees.y += delta * rotation_speed
