extends CharacterBody3D

@onready var nek: Node3D = $nek
@onready var camera_3d: Camera3D = $nek/head/eyes/Camera3D
@onready var head: Node3D = $nek/head
@onready var standing_collision_shape: CollisionShape3D = $standing_collision_shape
@onready var crouching_collision_shape: CollisionShape3D = $crouching_collision_shape
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var eyes: Node3D = $nek/head/eyes
@onready var animation_player: AnimationPlayer = $nek/head/eyes/AnimationPlayer
@onready var interaction: RayCast3D = $nek/head/eyes/Camera3D/Interaction
@onready var hand: Marker3D = $nek/head/eyes/Camera3D/hand
@onready var joint: Generic6DOFJoint3D = $nek/head/eyes/Camera3D/Generic6DOFJoint3D
@onready var staticbody: StaticBody3D = $nek/head/eyes/Camera3D/StaticBody3D
@onready var footstep: AudioStreamPlayer3D = $Footstep
@onready var water_sound: AudioStreamPlayer3D = $WaterSound
@onready var jumping: AudioStreamPlayer3D = $Jumping
@onready var landing: AudioStreamPlayer3D = $Landing
@onready var slide: AudioStreamPlayer3D = $Slide
@onready var object_pickup: AudioStreamPlayer3D = $ObjectPickup
@onready var object_throw: AudioStreamPlayer3D = $ObjectThrow
@onready var water: MeshInstance3D = $"../Water"
@onready var box: RigidBody3D = $"../box"
@onready var object_splash: AudioStreamPlayer3D = $"../ObjectSplash"

var picked_object
var pull_power = 4
var rotation_power = 0.05
var locked = false
var current_speed = 5.0
const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0
var last_velocity = Vector3.ZERO
var climbing_speed = 150.0
var water_speed = 0.05
var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO
var slide_speed = 10.0
var played_sound = false
var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false
var free_look_tilt_amount = 8.5
const jump_velocity = 4.5
var lerp_speed = 10.0
var air_lerp_speed = 3.0
const mouse_sens = 0.25
var crouching_depth = -0.5
var direction = Vector3.ZERO
const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0
const head_bobbing_sprinting_intensity = 0.2
const head_bobbing_walking_intensity = 0.1
const head_bobbing_crouching_intensity = 0.05
var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0
var water_entered = false
var buoyancy_force = Vector3(0, 100, 0)  # Buoyancy force for the box
var water_surface_height = 0.0  # Height of the water's surface (you can adjust this depending on your scene)

# Fall damage threshold (you can adjust this value)
const FALL_DAMAGE_THRESHOLD = -13.0

##Fall damage
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if box:
		print(box.mass, "yeah")
		# Set water surface height (could be dynamic if the water moves up/down)
		water_surface_height = water.position.y

func _play_footstep_audio():
	if water_entered:
		if !water_sound.playing:
			water_sound.pitch_scale = randf_range(0.8, 1.2)
			water_sound.play()
	else:
		if sprinting:
			footstep.pitch_scale = randf_range(1.2, 1.5)
			footstep.play()
		elif crouching:
			footstep.pitch_scale = randf_range(0.4, 0.6)
			footstep.play()
		else:
			footstep.pitch_scale = randf_range(0.5, 0.7)
			footstep.play()

func pick_object():
	var collider = interaction.get_collider()
	if collider != null and collider is RigidBody3D:
		picked_object = collider
		joint.set_node_b(picked_object.get_path())
		object_pickup.play()

func rotate_object(event):
	if picked_object != null:
		if event is InputEventMouseMotion:
			staticbody.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			staticbody.rotate_y(deg_to_rad(event.relative.x * rotation_power))

func remove_object():
	if picked_object != null:
		picked_object = null
		joint.set_node_b(joint.get_path())

func _input(event):
	if Input.is_action_just_pressed("interact"):
		if picked_object == null:
			pick_object()
		elif picked_object != null:
			remove_object()
	if Input.is_action_pressed('rclick'):
		locked = true
		rotate_object(event)
		print("Function being called", "Locked:", locked)
	if Input.is_action_just_released('rclick'):
		locked = false
		print("Function not called", locked)
		
	if Input.is_action_just_pressed("throw"):
		if picked_object != null:
			var knockback = picked_object.global_position - global_position
			picked_object.apply_central_impulse(knockback * 5)
			object_throw.play()
			remove_object()
	if event is InputEventMouseMotion:
		if free_looking:
			nek.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			nek.rotation.y = clamp(nek.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	if water_entered:
		current_speed = walking_speed
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var is_moving = input_dir != Vector2.ZERO || velocity.length() > 0.1
	
	if Input.is_action_pressed("crouch") || sliding:
		head.position.y = lerp(head.position.y, 1.8 + crouching_depth, delta*lerp_speed)
		current_speed = lerp(current_speed, crouching_speed, delta * lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		if sprinting && input_dir != Vector2.ZERO:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
			print("Sliding Enabled")
		
		walking = false
		sprinting = false
		crouching = true
		
	elif !ray_cast_3d.is_colliding():
		crouching_collision_shape.disabled = true
		standing_collision_shape.disabled = false
		head.position.y = lerp(head.position.y, 0.0, delta*lerp_speed)
		head.position.y = 1.8
		if Input.is_action_pressed("sprint"):
			current_speed = lerp(current_speed, sprinting_speed, delta * lerp_speed)
			walking = false
			sprinting = true
			crouching = false
		else:
			current_speed = lerp(current_speed, walking_speed, delta * lerp_speed)
			walking = true
			sprinting = false
			crouching = false
	
	if Input.is_action_pressed("free_look") || sliding:
		free_looking = true
		if sliding:
			eyes.rotation.z = lerp(eyes.rotation.z, -deg_to_rad(7.0), delta * lerp_speed)
		else:
			eyes.rotation.z = -deg_to_rad(nek.rotation.y * free_look_tilt_amount)
	else:
		free_looking = false
		nek.rotation.y = lerp(nek.rotation.y, 0.0, delta*lerp_speed)
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta*lerp_speed)
	
	if is_on_floor() and !sliding:
		if is_moving and !footstep.playing:
			_play_footstep_audio()
		elif !is_moving and footstep.playing:
			footstep.stop()
	
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			print("Sliding Disabled")
			slide.stop()
			free_looking = false
			played_sound = false
		elif played_sound == false:
			played_sound = true
			slide.play()
	
	# Handle headbob
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed*delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed*delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed*delta
	
	if is_on_floor() && !sliding && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity/2.0), delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*head_bobbing_current_intensity, delta*lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta*lerp_speed)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		sliding = false
		animation_player.play("jump")
		jumping.play()
	
	# Handle landing and fall damage
	if is_on_floor():
		if last_velocity.y < 0.0:
			# Fall damage logic
			print(last_velocity.y, "This is the last velocity")
			if last_velocity.y < FALL_DAMAGE_THRESHOLD:
				
				print("Taking damage")  # Print fall damage message
			landing.play()
			animation_player.play("landing")
			print(last_velocity.y)
			if jumping.playing:
				jumping.stop()
	
	# Get the input direction and handle the movement/deceleration.
	if is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*air_lerp_speed)
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
		current_speed = (slide_timer + 0.1) * slide_speed
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a)*pull_power)
	
	last_velocity = velocity
	move_and_slide()

# Handle water entry
func _on_sound_detection_body_entered(body: Node3D) -> void:
	if body == box:
		print("Box entered water!")
		object_splash.play()
		if body is RigidBody3D:
			body.gravity_scale = 0  # Disable gravity while it's underwater
			body.apply_impulse(Vector3.ZERO, buoyancy_force)

	if body.name == "player":
		water_entered = true
		current_speed = water_speed
		print(current_speed, "This is the water speed")

# Handle water exit
func _on_sound_detection_body_exited(body: Node3D) -> void:
	if body == box:
		print("Box exited water!")
		if body is RigidBody3D:
			body.gravity_scale = 1  # Restore gravity when it exits the water
			body.apply_impulse(Vector3.ZERO, Vector3(0, -100, 0))  # Small downward force if needed

	if body.name == "player":
		water_entered = false
		current_speed = walking_speed
		print("Restored speed", current_speed)
