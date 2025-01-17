extends MeshInstance3D

@onready var running_water: AudioStreamPlayer3D = $RunningWater

func _ready():
	
	running_water.play()  # Play the sound
