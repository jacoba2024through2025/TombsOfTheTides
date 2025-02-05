extends Control


@onready var my_button: Button = $InputSettings.get_node("Button")
@onready var return_pause: Button = $InputSettings/ReturnPause
@onready var click: AudioStreamPlayer3D = $Click

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
	if Input.is_action_just_pressed("pause") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused == true:
		$InputSettings.visible = false
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
		resume()
		
func _process(delta: float) -> void:
	testTab()

func _on_resume_pressed() -> void:
	resume()
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)


func _on_controls_pressed() -> void:
	
	
	$InputSettings.visible = true
	
	
	if get_tree().paused:
		my_button.text = "Paused"
		my_button.disabled = true
		my_button.visible = false
		return_pause.visible = true						
		
	pause()

func _on_quit_pressed() -> void:
	get_tree().quit()


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
