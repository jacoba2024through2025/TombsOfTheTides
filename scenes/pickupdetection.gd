extends Area3D





func _on_body_entered(body: Node3D) -> void:
	
	if body.name == "player":
		Global.boxAccess = true
	


func _on_body_exited(body: Node3D) -> void:
	
	if body.name == "player":
		Global.boxAccess = false
