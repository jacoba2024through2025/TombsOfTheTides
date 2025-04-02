extends Node3D

@onready var opensound: AudioStreamPlayer3D = $opensound
@onready var closesound: AudioStreamPlayer3D = $closesound

var toggle = false
var bodies_entered = 0
var open_clamp = 2.6
var close_clamp = 0.0
var open_close_speed = 2

var target_position = close_clamp
var last_toggle_state = false



#func enter_trigger(body):
	#if body is CharacterBody3D:
		#bodies_entered += 1
		#if !toggle:
			#toggle = true
			#opensound.play()
	
		
#func exit_trigger(body):
	#if body is CharacterBody3D:
		#bodies_entered -= 1
		#if bodies_entered == 0:
			#if toggle:
				#toggle = false
				#closesound.play()
				
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if toggle:
		target_position = open_clamp  # Move to open position
	else:
		target_position = close_clamp  # Move to closed position

	# Use lerp to smoothly interpolate between the current position and target position
	$StaticBody3D.position.x = lerp($StaticBody3D.position.x, target_position, open_close_speed * delta)

	# Check for state change and play sound accordingly
	if toggle != last_toggle_state:
		if toggle:
			opensound.play()  # Play open sound only once when toggling to open
		else:
			closesound.play()  # Play close sound only once when toggling to close

	last_toggle_state = toggle  # Update last state

	# Handle button presses to toggle the door
	if Global.buttonTimes == 2:
		toggle = true
	else:
		toggle = false
