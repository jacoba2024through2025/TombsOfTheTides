extends Area3D

@onready var rolling_deep: AudioStreamPlayer3D = $"../rolling_deep"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.name == "player":
		rolling_deep.play()
		


func _on_body_exited(body: Node3D) -> void:
	rolling_deep.stop()
