extends Node3D

const PROJECTILE = preload("res://scenes/projectile.tscn")
@onready var camera_3d: Camera3D = $Camera3D
@onready var turretsound: AudioStreamPlayer3D = $turretsound

@onready var timer: Timer = $Timer
@onready var projectile_launcher: Node3D = $Camera3D/ProjectileLauncher
@onready var player: Node3D = $Player



func _on_vision_timer_timeout() -> void:
	var overlaps = $VisionArea.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.name == "player":
				var playerPosition = overlap.global_transform.origin
				$VisionRaycast.look_at(playerPosition, Vector3.UP)
				$VisionRaycast.force_raycast_update()
				
				projectile_launcher.look_at(playerPosition, Vector3.UP)
				
				if $VisionRaycast.is_colliding():
					var collider = $VisionRaycast.get_collider()
					
					if collider.name == "player":
						$VisionRaycast.debug_shape_custom_color = Color(174,0,0)
						print("I see you")
						
						if timer.is_stopped():
							fire_projectile(playerPosition)
							
					else:
						$VisionRaycast.debug_shape_custom_color = Color(0, 255, 0)
						print("I don't see you")
						
						
						
func rotate_camera_towards_player(player_position: Vector3) -> void:
	var direction_to_player = player_position - camera_3d.global_transform.origin
	direction_to_player.y = 0
	
	camera_3d.look_at(player_position, Vector3.UP)
						
func fire_projectile(target_position: Vector3) -> void:
	turretsound.play()
	var attack = PROJECTILE.instantiate()
	add_child(attack)
	attack.global_transform.origin = projectile_launcher.global_position
	
	var direction_to_player = target_position - attack.global_transform.origin
	direction_to_player.y = 0
	
	var direction = direction_to_player.normalized()
	attack.look_at(attack.global_transform.origin + direction, Vector3.UP)
	timer.start()						
					
