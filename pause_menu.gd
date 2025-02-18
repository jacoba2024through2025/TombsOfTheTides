extends Control

@onready var my_button: Button = $InputSettings.get_node("Button")
@onready var return_pause: Button = $InputSettings/ReturnPause
@onready var click: AudioStreamPlayer3D = $Click
var mouse_pressed = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("RESET")
	var my_button: Button = $InputSettings.get_node("Button")
	my_button.connect("pressed", Callable(self, "_on_my_button_pressed"))
	return_pause.connect("pressed", Callable(self, "_on_return_pause_pressed"))

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():    
	get_tree().paused = true
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	$AnimationPlayer.play("blur")

func testTab():
	if Input.is_action_just_pressed("pause"):
		if not get_tree().paused:
			pause()
		else:
			$InputSettings.visible = false
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
			resume()

func _process(delta: float) -> void:
	testTab()

# This function will be triggered by the resume button click
func _on_resume_pressed() -> void:
	# Check if the left mouse button is pressed (button index 1 is the left mouse button)

	if mouse_pressed:
		if (not Input.is_action_just_pressed("swim")) and (not Input.is_action_just_pressed("jump")):
			resume()
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	mouse_pressed = false

func _on_controls_pressed() -> void:
	if mouse_pressed:
		$InputSettings.visible = true
		
		if get_tree().paused:
			my_button.text = "Paused"
			my_button.disabled = true
			my_button.visible = false
			return_pause.visible = true						
			
		pause()
	mouse_pressed = false

func _on_quit_pressed() -> void:
	if mouse_pressed:
		get_tree().quit()
	mouse_pressed = false
func _on_my_button_pressed():
	print("hidden it")
	$InputSettings.visible = false

func _on_return_pause_pressed():
	$InputSettings.visible = false

func _on_resume_mouse_entered() -> void:
	click.play()

func _on_controls_mouse_entered() -> void:
	click.play()

func _on_quit_mouse_entered() -> void:
	click.play()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_pressed = true
		
		
		
