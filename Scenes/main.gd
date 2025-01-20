extends Node3D
@onready var level_music: AudioStreamPlayer3D = $level_music


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_music.play()
