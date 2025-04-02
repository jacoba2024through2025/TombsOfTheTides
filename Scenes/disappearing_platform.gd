extends StaticBody3D

@onready var timer: Timer = $Timer
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D  # Assuming you have a MeshInstance3D for the visual
@onready var rockfall_1: AudioStreamPlayer3D = $rockfall1
@onready var rockfall_2: AudioStreamPlayer3D = $rockfall2
@onready var boomsound: AudioStreamPlayer3D = $boomsound


var platform_disappeared = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "player":
		print("timer started")
		play_rockfall_sounds()
		collision_shape_3d.disabled = false
		timer.stop()
		timer.start()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "player":
		print("resetting platform")
		await get_tree().create_timer(0.5).timeout
		reset_platform()
		

func _on_timer_timeout() -> void:
	if not platform_disappeared:
		
		mesh_instance.visible = false
		
		collision_shape_3d.disabled = true
		print(collision_shape_3d.disabled)
		
		
		platform_disappeared = true
func play_rockfall_sounds() -> void:
	rockfall_1.play()
	await get_tree().create_timer(1).timeout
	
	rockfall_2.play()
	await get_tree().create_timer(1).timeout		
	
	boomsound.play()
		
func reset_platform():
	mesh_instance.visible = true
	collision_shape_3d.disabled = false
	print(collision_shape_3d.disabled)
	
	
	timer.stop()
	platform_disappeared = false
