extends StaticBody3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var buttonpressed: AudioStreamPlayer3D = $buttonpressed
@onready var buttonreleased: AudioStreamPlayer3D = $buttonreleased



	
	
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	
	if body.name != "ButCol" and body.name == "player" or body.name == "box":
		if body:
			print(body.name, "name")
		
		anim.play("press_down")
		Global.buttonTimes += 1
		buttonpressed.play()
		Global.boxStopping = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body:
		print(body.name, "name")
	
	if body.name != "ButCol" and body.name == "player" or body.name == "box":
		anim.play("press_up")
		Global.buttonTimes -= 1
		buttonreleased.play()
		Global.boxStopping = false
