extends Node3D
@onready var spike_trap: Node3D = $SpikeTrap
@onready var spike_trap_animations: AnimationPlayer = $SpikeTrap/AnimationPlayer
@onready var spike_up: AudioStreamPlayer3D = $SpikeUp
@onready var spike_down: AudioStreamPlayer3D = $SpikeDown

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spike_trap_animations.play("Idle")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_spikedetection_body_entered(body: Node3D) -> void:
	if body.name == "player":
		spike_trap_animations.play("Up")
		spike_up.play()
		Global.spikeAttack = true


func _on_spikedetection_body_exited(body: Node3D) -> void:
	if body.name == "player":
		spike_trap_animations.play("Down")
		spike_down.play()
		Global.spikeAttack = false
