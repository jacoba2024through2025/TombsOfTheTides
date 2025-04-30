extends RayCast3D

@export var speed : float = 50.0
@onready var remote_transform := RemoteTransform3D.new()
# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	position += global_basis * Vector3.FORWARD * speed * delta
	target_position = Vector3.FORWARD * speed * delta
	force_raycast_update()
	var collider = get_collider()
	
	print(collider, "yes")
	
	if is_colliding():
		global_position = get_collision_point()
		set_physics_process(false)
		collider.add_child(remote_transform)
		remote_transform.global_transform = global_transform
		remote_transform.remote_path = remote_transform.get_path_to(self)
		
		if collider.name == "player":
			Global.spikeShoot = true
	
		
func cleanup() -> void:
	Global.spikeShoot = false
	queue_free()



	
