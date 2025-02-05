extends Control

@onready var input_button_scene = preload("res://input_button.tscn")
@onready var action_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList
@onready var MAIN_MENU = load("res://scenes/main_menu.tscn")
var is_remapping = false
var action_to_remap = null
var remapping_button = null
@onready var hover: AudioStreamPlayer3D = $Hover

var input_actions = {
	"forward": "Forward",
	"backward": "Backward",
	"left": "Left",
	"right": "Right",
	"sprint": "Sprint",
	"crouch": "Crouch/Slide",
	"free_look": "Free look",
	"interact": "Interact",
	
	"pause": "Pause game",
	"swim": "Swim",
	"jump": "Jump"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_keybindings_from_settings()
	_create_action_list()
func _load_keybindings_from_settings():
	var keybindings = ConfigFileHandler.load_keybindings()
	for action in keybindings.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybindings[action])
func _create_action_list():
	
	for item in action_list.get_children():
		item.queue_free()

	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
			
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))
		
func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press key to bind..."
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if is_remapping:
		if (
			event is InputEventKey ||
			(event is InputEventMouseButton && event.pressed)
		):
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
			
			
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			ConfigFileHandler.save_keybinding(action_to_remap, event)
			_update_action_list(remapping_button, event)
			
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()
			
func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	print("Changing back to main menu")
	
	$".".visible = false


func _on_reset_button_pressed() -> void:
	InputMap.load_from_project_settings()
	for action in input_actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			ConfigFileHandler.save_keybinding(action, events[0])
	_create_action_list()





func _on_reset_button_mouse_entered() -> void:
	
	hover.play()


func _on_button_mouse_entered() -> void:
	
	hover.play()
