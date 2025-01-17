extends RigidBody3D

var velocity = 3



@onready var box_impact: AudioStreamPlayer3D = $BoxImpact



func _on_body_entered(body: Node) -> void:
	if abs(self.linear_velocity.x) > velocity or abs(self.linear_velocity.y) > velocity or abs(self.linear_velocity.z) > velocity:
		box_impact.play()
	




func _on_box_impact_finished() -> void:
	pass # Replace with function body.
