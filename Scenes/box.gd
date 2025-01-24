extends RigidBody3D

var velocity = 3

@onready var box: RigidBody3D = $"."

signal bodycollided
var direction = Vector3(1,0,0)
@onready var box_impact: AudioStreamPlayer3D = $BoxImpact

func _physics_process(delta: float) -> void:
	var collision = get_colliding_bodies()
	for body in collision:
		if body in get_tree().get_nodes_in_group("wallsFloorsCeilings"):
			#apply_impulse(Vector3.ZERO, direction * 10)
			emit_signal("bodycollided", body)
	apply_impulse(Vector3.ZERO, Vector3(10,0,0))
	
			


func _on_body_entered(body: Node) -> void:
	if abs(self.linear_velocity.x) > velocity or abs(self.linear_velocity.y) > velocity or abs(self.linear_velocity.z) > velocity:
		box_impact.play()
	




func _on_box_impact_finished() -> void:
	pass # Replace with function body.
