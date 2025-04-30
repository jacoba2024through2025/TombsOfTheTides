extends Area3D

@onready var level_music: AudioStreamPlayer3D = $"../level_music"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_body_entered(body: Node3D) -> void:
	if body.name == "player":
		level_music.play()
		


func _on_body_exited(body: Node3D) -> void:
	
	level_music.stop()
