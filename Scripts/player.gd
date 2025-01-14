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

#All grab variables
var picked_object
var pull_power = 4

var rotation_power = 0.05
var locked = false




# grab variables end



var current_speed = 5.0
const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0
var last_velocity = Vector3.ZERO
var climbing_speed = 150.0
#Sliding vars
var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO
var slide_speed = 10.0

# States

var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false

#Tilt
var free_look_tilt_amount = 8.5

const jump_velocity = 4.5
var lerp_speed = 10.0
var air_lerp_speed = 3.0
const mouse_sens = 0.25
var crouching_depth = -0.5
var direction = Vector3.ZERO

#Head bob
const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0

#Intensity of the head bob
const head_bobbing_sprinting_intensity = 0.2
const head_bobbing_walking_intensity = 0.1
const head_bobbing_crouching_intensity = 0.05

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func pick_object():
	var collider = interaction.get_collider()
	if collider != null and collider is RigidBody3D:
		picked_object = collider
		joint.set_node_b(picked_object.get_path())

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
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	
	
	if Input.is_action_pressed("crouch") || sliding:
		head.position.y = lerp(head.position.y, 1.8 + crouching_depth, delta*lerp_speed)
		current_speed = lerp(current_speed, crouching_speed, delta * lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		# Begin slide logic
		
		
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
			eyes.rotation.z = lerp(eyes.rotation.z, -deg_to_rad(7.0), delta * lerp_speed		)
			
		else:
			eyes.rotation.z = -deg_to_rad(nek.rotation.y * free_look_tilt_amount)
	else:
		free_looking = false
		nek.rotation.y = lerp(nek.rotation.y, 0.0, delta*lerp_speed)
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta*lerp_speed)
		
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			print("Sliding Disabled	")
			free_looking = false
		
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
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity/2.0),delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*head_bobbing_current_intensity,delta*lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0,delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x	, 0.0,delta*lerp_speed)
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		sliding = false
		animation_player.play("jump")
	
	# Handle landing
	if is_on_floor():
		if last_velocity.y < 0.0:
			animation_player.play("landing")
			print(last_velocity.y)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*air_lerp_speed)
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x,0,slide_vector.y)).normalized()
		
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
	
	
