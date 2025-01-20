extends GPUParticles3D

@export var rotation_speed = 0.25

func _process(delta):
	rotate_y(delta * rotation_speed)
